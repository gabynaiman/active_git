module ActiveGit
  class Synchronizer

    def self.synchronize(*events)
      batch = self.new

      Array(events).flatten.each do |event|
        event.synchronize batch
      end

      batch.run
    end

    def run
      unless bulk_inserts.empty?
        define_job do
          bulk_inserts.each do |model, records|
            ActiveGit.configuration.logger.debug "[ActiveGit] Inserting #{model.model_name} models"
            import_result = model.import records, timestamps: false, validate: false
            raise SynchronizationError.new(import_result.failed_instances) unless import_result.failed_instances.empty?
          end
        end
      end

      ::ActiveRecord::Base.transaction do
        jobs.each do |job|
          job.call
        end
      end
      ActiveGit.add_all
    end

    def bulk_insert(data)
      bulk_inserts[data.class] ||= [] unless bulk_inserts.has_key? data.class
      bulk_inserts[data.class] << data
    end

    def define_job(&block)
      jobs << Proc.new(&block)
    end

    private

    def bulk_inserts
      @bulk_inserts ||= {}
    end

    def jobs
      @jobs ||= []
    end

  end

end