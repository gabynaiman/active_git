module ActiveGit
  class DbUpdate < DbEvent

    def synchronize(synchronizer)
      synchronizer.bulk_insert data

      synchronizer.define_job do
        ActiveGit.configuration.logger.debug "[ActiveGit] Deleting #{model.model_name} #{model_id}"
        record = model.find_by_id(model_id)
        record.delete if record
      end
    end

  end
end