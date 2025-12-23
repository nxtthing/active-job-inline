require "active_job_inline/queue_adapters/inline/base"

module ActiveJobInline
  module QueueAdapters
    class ThreadSpecific
      attr_reader :default

      def initialize(default:, **specific)
        @default = default
        @specific = specific.compare_by_identity
      end

      delegate :enqueue, to: :adapter
      delegate :enqueue_at, to: :adapter

      def register(thread, adapter)
        @specific[thread] = adapter
      end

      def unregister(thread)
        @specific.delete(thread)
      end

      def any_specific?
        @specific.any?
      end

      def inline?
        return true if adapter.is_a?(Inline::Base)

        false
      end

      def after_perform
        return unless inline?

        adapter.after_perform
      end

      private

      def adapter
        @specific[Thread.current] || @default
      end
    end
  end
end

