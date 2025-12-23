require "active_job_inline/queue_adapters/inline/base"

module ActiveJobInline
  module QueueAdapters
    module Inline
      class WithDelay < Base
        def enqueue_at(job, _timestamp) # :nodoc:
          delayed_queue << job.serialize
        end

        def after_perform
          execute_delayed_queue
        end

        def self.after_perform
          adapter = ::ActiveJob::Base.queue_adapter
          adapter.after_perform if adapter.is_a?(self)
        end

        private

        def delayed_queue
          Thread.current[:delayed_queue] ||= []
        end

        def execute_delayed_queue
          loop do
            break if delayed_queue.empty?

            serialized_job = delayed_queue.shift
            execute(serialized_job)
          end
        end
      end
    end
  end
end
