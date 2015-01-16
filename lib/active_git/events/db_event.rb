module ActiveGit
  class DbEvent

    def initialize(file_name, working_path=nil)
      @file_name = file_name
      @working_path = working_path || ActiveGit.configuration.working_path
    end

    private

    def model
      @model ||= Inflector.model(@file_name, @working_path)
    end

    def model_id
      Inflector.model_id @file_name
    end

    def create(synchronizer)
      json = File.read @file_name
      ModelParser.instances(model, json).each do |instance|
        synchronizer.bulk_insert instance
      end
    end

    def delete(synchronizer)
      synchronizer.define_job do
        instance = model.find_by_id(model_id)
        if instance
          model.git_included_associations.each do |a|
            if association = instance.reflections[a]
              if association.collection?
                instance.send(a).each do |e| 
                  ActiveGit.configuration.logger.debug "[ActiveGit] Deleting #{e.class.model_name} #{e.id}"
                  e.delete
                end
              else
                if i = instance.send(a)
                  ActiveGit.configuration.logger.debug "[ActiveGit] Deleting #{i.class.model_name} #{i.id}"
                  instance.send(a).delete
                end
              end
            end
          end
          ActiveGit.configuration.logger.debug "[ActiveGit] Deleting #{model.model_name} #{model_id}"
          instance.delete
        end
      end
    end

  end
end
