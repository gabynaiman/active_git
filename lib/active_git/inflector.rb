module ActiveGit
  module Inflector

    def self.dirname(model, working_path=nil)
      "#{working_path || ActiveGit.configuration.working_path}/#{model.model_name.underscore.pluralize}"
    end

    def self.filename(instance, working_path=nil)
      "#{dirname(instance.class, working_path || ActiveGit.configuration.working_path)}/#{instance.id}.json"
    end

    def self.model(filename, working_path=nil)
      File.dirname(filename.gsub(working_path || ActiveGit.configuration.working_path, '')).classify.constantize
    end

    def self.model_id(filename)
      File.basename(filename, '.json')
    end

  end
end