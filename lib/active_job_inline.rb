require "lib/active_job_inline/middlewares/rack"
require "lib/active_job_inline/middlewares/active_job"

require "lib/active_job_inline/queue_adapters/inline/with_default"
require "lib/active_job_inline/queue_adapters/inline/with_delay"

require "lib/active_job/queue_adapters/inline_with_delay_adapter"

module ActiveJobInline
  class << self
    def apply(with_delays: false, &block)
      return block.call if inline_adapter?

      thread_specific_adapter = if with_delays
                                  QueueAdapters::Inline::WithDelay.new
                                else
                                  current_adapter = ActiveJob::Base.queue_adapter
                                  default_adapter = thread_specific_adapter? ? current_adapter.default : current_adapter
                                  QueueAdapters::Inline::WithDefault.new(default_adapter)
                                end
      with_queue_adapter(thread_specific_adapter, &block)
    end

    def applied?
      return false unless thread_specific_adapter?

      ::ActiveJob::Base.queue_adapter.inline?
    end

    private

    def with_queue_adapter(adapter, &block)
      with_mutex_lock do
        if thread_specific_adapter?
          ::ActiveJob::Base.queue_adapter.register(Thread.current, adapter)
        else
          ActiveJob::Base.queue_adapter = ActiveJobInline::QueueAdapters::ThreadSpecific.new(
            default: ::ActiveJob::Base.queue_adapter,
            Thread.current => adapter
          )
        end
      end

      block.call
    ensure
      with_mutex_lock do
        if thread_specific_adapter?
          ::ActiveJob::Base.queue_adapter.after_perform
          ::ActiveJob::Base.queue_adapter.unregister(Thread.current)
          unless ActiveJob::Base.queue_adapter.any_specific?
            ::ActiveJob::Base.queue_adapter = ::ActiveJob::Base.queue_adapter.default
          end
        end
      end
    end

    def thread_specific_adapter?
      ::ActiveJob::Base.queue_adapter.is_a?(QueueAdapters::ThreadSpecific)
    end

    def with_mutex_lock(&)
      RedisMutex.with_lock(
        [Socket.gethostname, Process.pid.to_fs(16)].join("-"),
        {
          block: 60, # default 1
          sleep: 1, # default 0.1
          expire: 20 # default 10
        },
        &
      )
    end
  end
end
