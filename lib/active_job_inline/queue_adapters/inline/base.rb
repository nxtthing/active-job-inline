module ActiveJobInline
  module QueueAdapters
    class Base
      def enqueue(job) # :nodoc:
        execute(job.serialize)
      end

      def enqueue_at(_job, _timestamp)
        raise NotImplementedError, "enqueue_at"
      end

      def after_perform
        # Do Nothing by default
      end

      protected

      def execute(serialized_job)
        ::ActiveJob::Base.execute(serialized_job)
      end
    end
  end
end
