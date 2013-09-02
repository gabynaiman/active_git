module ActiveGit
  module ActiveRecord

    module ClassMethods

      def git_versioned(options={})

        @options = options.merge root: false

        def git_options
          @options
        end

        include InstanceMethods

        ActiveGit.models << self

        after_save do |record|
          ActiveGit.synchronize FileSave.new(record)
        end

        after_destroy do |record|
          ActiveGit.synchronize FileDelete.new(record)
        end

      end

      def git_included_in(model)

        after_save do
          instance = send model
          #TODO: Ver si se puede optimizar el reload para que no lo haga siempre
          ActiveGit.synchronize FileSave.new(instance.reload) if instance
        end

        after_destroy do
          instance = send model
          ActiveGit.synchronize FileSave.new(instance.reload) if instance
        end

      end

    end

    module InstanceMethods

      def git_dump
        JSON.pretty_generate(as_json(self.class.git_options))
      end

    end

  end
end