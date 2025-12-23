require "active_job_inline/queue_adapters/inline/with_delay"

module ActiveJob
  module QueueAdapters
    class InlineWithDelayAdapter < ::ActiveJobInline::QueueAdapters::Inline::WithDelay
    end
  end
end
