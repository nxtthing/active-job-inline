require "active_job_inline/queue_adapters/inline/with_delay"

module ActiveJobInline
  module Middlewares
    module ActiveJob
      extend ActiveSupport::Concern

      included do
        after_perform do |_job, block|
          block.call
          ActiveJobInline::QueueAdapters::Inline::WithDelay.after_perform
        end
      end
    end
  end
end
