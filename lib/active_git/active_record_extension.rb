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

    end

    module InstanceMethods

      def git_dump
        JSON.pretty_generate(as_json(self.class.git_options))
      end

    end

  end
end