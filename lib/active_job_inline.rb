require "active_job_inline/middlewares/rack"
require "active_job_inline/middlewares/active_job"

require "active_job_inline/queue_adapters/thread_specific"
require "active_job_inline/queue_adapters/inline/with_default"
require "active_job_inline/queue_adapters/inline/with_delay"

require "active_job/queue_adapters/inline_with_delay_adapter"

module ActiveJobInline
  class << self
    def apply(with_delays: false, &block)
      return block.call if applied?

      adapter = if with_delays
                  QueueAdapters::Inline::WithDelay.new
                else
                  default_adapter = thread_specific_adapter? ? current_adapter.default : current_adapter
                  QueueAdapters::Inline::WithDefault.new(default_adapter)
                end
      with_thread_specific_adapter(adapter, &block)
    end

    def applied?
      return false unless thread_specific_adapter?

      current_adapter.inline?
    end

    private

    def with_thread_specific_adapter(adapter, &block)
      with_mutex_lock do
        if thread_specific_adapter?
          current_adapter.register(Thread.current, adapter)
        else
          set_current_adapter(
            QueueAdapters::ThreadSpecific.new(
              default: current_adapter,
              Thread.current => adapter
            )
          )
        end
      end

      block.call
    ensure
      with_mutex_lock do
        if thread_specific_adapter?
          current_adapter.after_perform
          current_adapter.unregister(Thread.current)
          unless current_adapter.any_specific?
            set_current_adapter(::ActiveJob::Base.queue_adapter.default)
          end
        end
      end
    end

    def thread_specific_adapter?
      current_adapter.is_a?(QueueAdapters::ThreadSpecific)
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

    def current_adapter
      ::ActiveJob::Base.queue_adapter
    end

    def set_current_adapter(adapter)
      ::ActiveJob::Base.queue_adapter = adapter
    end
  end
end
