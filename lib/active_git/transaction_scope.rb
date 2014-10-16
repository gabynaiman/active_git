module ActiveGit
  class TransactionScope

    def initialize(repository)
      @repository = repository
      @stack = TransactionStack.new
      @queue = []
    end

    def call
      stack.incr

      result = nil

      begin
        result = yield self
      rescue => ex
        rollback
        raise ex
      end

      stack.decr

      commit if stack.empty?

      result
    end

    def enqueue(&block)
      queue << block
    end

    private

    attr_reader :repository, :stack, :queue

    def rollback
      ActiveGit.logger.debug('ActiveGit') { "Rollback (#{repository.workdir})" }
      stack.clear
    end

    def commit
      repository.index.reload

      queue.each(&:call)
      queue.clear

      ActiveGit.logger.debug('ActiveGit') { "Commit (#{repository.workdir})" }
      repository.index.write
    end
    
  end
end