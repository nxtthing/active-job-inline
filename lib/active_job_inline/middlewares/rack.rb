require "active_job_inline/queue_adapters/inline/with_delay"

module ActiveJobInline
  module Middlewares
    class Rack
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
        ActiveJobInline::QueueAdapters::Inline::WithDelay.after_perform
      end
    end
  end
end
