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
      if bulk_inserts.any?
        define_job do
          bulk_inserts.each do |model, records|
            records.each_slice(ActiveGit.configuration.sync_batch_size) do |batch_records|
              ActiveGit.configuration.logger.debug "[ActiveGit] Inserting #{model.model_name} models"
              import_result = model.import batch_records, timestamps: false, validate: false
              raise SynchronizationError.new(import_result.failed_instances) unless import_result.failed_instances.empty?
            end
          end
        end
      end

      ::ActiveRecord::Base.transaction do
        jobs.each(&:call)
      end

      ActiveGit.add_all
    end

    def bulk_insert(data)
      bulk_inserts[data.class] << data
    end

    def define_job(&block)
      jobs << block
    end

    private

    def bulk_inserts
      @bulk_inserts ||= Hash.new{|h,k| h[k] = []}
    end

    def jobs
      @jobs ||= []
    end

  end

end