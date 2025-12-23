require "active_job_inline/queue_adapters/inline/with_delay"

module ActiveJobInline
  module Extensions
    class RackMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        response = @app.call(env)
        ActiveJobInline::QueueAdapters::Inline::WithDelay.after_perform
        response
      end
    end
  end
end
