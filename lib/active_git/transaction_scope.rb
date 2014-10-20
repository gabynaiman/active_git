module ActiveGit
  class TransactionScope

    def initialize(repository)
      @repository = repository
      @stack = TransactionStack.new
      @locker = Locker.new repository.path
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

    attr_reader :repository, :stack, :locker, :queue

    def rollback
      ActiveGit.logger.debug('ActiveGit') { "Rollback transaction (#{repository.workdir})" }
      stack.clear
      repository.index.reload
    end

    def commit
      locker.lock

      repository.index.reload

      queue.each(&:call)
      queue.clear

      ActiveGit.logger.debug('ActiveGit') { "Commit transaction (#{repository.workdir})" }
      repository.index.write

      locker.unlock
    end
    
  end
end