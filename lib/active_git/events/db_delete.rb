module ActiveGit
  class DbDelete < DbEvent

    def synchronize(synchronizer)
      synchronizer.define_job do
        ::ActiveRecord::Base.logger.debug "[ActiveGit] Deleting #{model.model_name} #{model_id}"
        record = model.find_by_id(model_id)
        record.delete if record
      end
    end

  end
end