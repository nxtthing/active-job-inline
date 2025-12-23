require "active_job_inline/queue_adapters/inline/with_delay"

module ActiveJobInline
  module Extensions
    module ActiveRecordTestFixturesBeforeRollbackPatch
      def teardown_fixtures
        if run_in_transaction?
          ActiveJobInline::QueueAdapters::Inline::WithDelay.after_perform
        end

        super
      end
    end
  end
end
