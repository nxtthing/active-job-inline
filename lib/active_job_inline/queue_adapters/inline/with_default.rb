require "active_job_inline/queue_adapters/inline/base"

module ActiveJobInline
  module QueueAdapters
    module Inline
      class WithDefault < Base
        attr_reader :default

        def initialize(default)
          @default = default
        end

        delegate :enqueue_at, to: :default
      end
    end
  end
end
