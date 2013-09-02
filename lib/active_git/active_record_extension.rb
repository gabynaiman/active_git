module ActiveGit
  module ActiveRecord

    module ClassMethods

      def git_versioned(options={})

        @options = options.merge root: false

        def git_options
          @options
        end

        def git_included_models
          git_included_associations.map { |a| reflections[a] ? reflections[a].klass : a.to_s.classify.constantize }
        end

        def git_included_associations
          git_deep_included_associations git_options[:include]
        end

        def git_deep_included_associations(arg)
          return [] if arg.nil?

          if arg.is_a? Array
            arg
          elsif arg.is_a? Hash
            arg.keys + git_deep_included_associations(arg.map{|k,v| v[:include]})
          else
            [arg]
          end
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