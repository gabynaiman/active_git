module ActiveGit
  class DbEvent

    def initialize(file_name, working_path=nil)
      @file_name = file_name
      @working_path = working_path || ActiveGit.configuration.working_path
    end

    def synchronize(synchronizer)
      raise 'Must implement in subclass'
    end

    private

    def model
      @model ||= Inflector.model(@file_name, @working_path)
    end

    def model_id
      Inflector.model_id @file_name
    end

    def create(synchronizer)
      json = File.read(@file_name)
      ModelParser.instances(model, json).each do |instance|
        synchronizer.bulk_insert instance
      end
    end

    def delete(synchronizer)
      synchronizer.define_job do
        ActiveGit.configuration.logger.debug "[ActiveGit] Deleting #{model.model_name} #{model_id}"
        record = model.find_by_id(model_id)
        record.delete if record
      end
    end

  end
end
