module ActiveGit
  class DbUpdate < DbEvent

    def synchronize(synchronizer)
      synchronizer.bulk_insert data

      synchronizer.define_job do
        ::ActiveRecord::Base.logger.debug "[ActiveGit] Deleting #{data.class.model_name} #{data.id}"
        record = data.class.find_by_id(data.id)
        record.delete if record
      end
    end

  end
end