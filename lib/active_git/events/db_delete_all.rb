module ActiveGit
  class DbDeleteAll

    def initialize(model)
      @model = model
    end

    def synchronize(synchronizer)
      synchronizer.define_job do
        ActiveGit.configuration.logger.debug "[ActiveGit] Deleting all #{@model.model_name} models"
        @model.delete_all

        @model.git_included_models.each do |nested_model|
          ActiveGit.configuration.logger.debug "[ActiveGit] Deleting all #{nested_model.model_name} models (nested of #{@model.model_name})"
          nested_model.delete_all
        end
      end
    end

  end
end