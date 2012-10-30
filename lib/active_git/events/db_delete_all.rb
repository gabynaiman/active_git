module ActiveGit
  class DbDeleteAll

    def initialize(model)
      @model = model
    end

    def synchronize(synchronizer)
      synchronizer.define_job do
        ActiveGit.configuration.logger.debug "[ActiveGit] Deleting all #{@model.model_name} models"
        @model.delete_all
      end
    end

  end
end