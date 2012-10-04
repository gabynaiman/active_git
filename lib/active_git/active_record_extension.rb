module ActiveGit
  module ActiveRecord

    module ClassMethods

      def has_git(path=nil)
        @git_repository_path = path

        after_create do |record|
          Synchronizer.synchronize FileCreate.new(record, path)
        end

        after_update do |record|
          Synchronizer.synchronize FileUpdate.new(record, path)
        end

        after_destroy do |record|
          Synchronizer.synchronize FileDelete.new(record, path)
        end

        include InstanceMethods

        define_singleton_method :git_repository_path do
          @git_repository_path
        end
      end

    end

    module InstanceMethods

      def git_file
        "#{self.class.git_repository_path || ActiveGit.configuration.repository_path}/#{self.class.table_name}/#{id}.json"
      end

    end

  end
end