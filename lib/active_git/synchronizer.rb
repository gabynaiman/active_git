module ActiveGit
  module Synchronizer

    def self.synchronize(*events)
      batch = Batch.new

      Array(events).flatten.each do |event|
        event.synchronize batch
      end

      batch.run
    end


    class Batch

      def db_create(data)
        bulk_insert data
      end

      def db_update(data)
        bulk_insert data

        define_job do
          record = data.class.find_by_id(data.id)
          record.delete if record
        end
      end

      def db_delete(model, id)
        define_job do
          record = model.find_by_id(id)
          record.delete if record
        end
      end

      def file_save(file_name, json)
        define_job do
          FileUtils.mkpath(File.dirname(file_name)) unless Dir.exist?(File.dirname(file_name))
          File.open(file_name, 'w') { |f| f.puts json }
        end
      end

      def file_delete(file_name)
        File.delete(file_name) if File.exist?(file_name)
      end

      def run
        unless bulk_inserts.empty?
          define_job do
            bulk_inserts.each do |model, records|
              import_result = model.import records, :timestamps => false
              raise SynchronizationError.new(import_result.failed_instances) unless import_result.failed_instances.empty?
            end
          end
        end

        ::ActiveRecord::Base.transaction do
          jobs.each do |job|
            job.call
          end
        end
      end

      private

      def bulk_insert(data)
        bulk_inserts[data.class] ||= [] unless bulk_inserts.has_key? data.class
        bulk_inserts[data.class] << data
      end

      def bulk_inserts
        @bulk_inserts ||= {}
      end

      def jobs
        @jobs ||= []
      end

      def define_job(&block)
        jobs << Proc.new(&block)
      end

    end

  end

end