module ActiveGit
  module Errors
  
    class NotFound < StandardError
      attr_reader :collection_name, :id

      def initialize(collection_name, id)
        @collection_name = collection_name
        @id = id
      end

      def message
        "Not found #{collection_name} #{id}"
      end
    end

    class PushRejected < StandardError
      attr_reader :path, :remote, :ref_name

      def initialize(path, remote, ref_name)
        @path = path
        @remote = remote
        @ref_name = ref_name
      end

      def message
        "Push rejected: #{remote} -> #{ref_name} (#{path})"
      end      
    end

    class UpToDate < StandardError
    end
    
    class CommitPending < StandardError
    end

    class InvalidBranch < StandardError
      attr_reader :branch_name

      def initialize(branch_name)
        @branch_name = branch_name
      end

      def message
        "Invalid branch #{branch_name}"
      end
    end

  end
end