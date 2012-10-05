module ActiveGit
  module ActiveRecord

    module ClassMethods

      def has_git
        ActiveGit.models << self

        after_save do |record|
          Synchronizer.synchronize FileSave.new(record)
        end

        after_destroy do |record|
          Synchronizer.synchronize FileDelete.new(record)
        end

        def git_folder
          "#{ActiveGit.configuration.working_path}/#{table_name}"
        end

        include InstanceMethods
      end

    end

    module InstanceMethods

      def git_file
        "#{self.class.git_folder}/#{id}.json"
      end

    end

  end
end