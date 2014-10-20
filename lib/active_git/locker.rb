module ActiveGit
  class Locker

    FILE_NAME = 'active_git.lock'
    WAIT_FOR_LOCK = 0.005

    attr_reader :path
  
    def initialize(path)
      @path = path
    end

    def lock
      return if mine?

      timeout ActiveGit.lock_timeout do
        while locked?
          sleep WAIT_FOR_LOCK
        end
        lock!
      end
    end

    def unlock
      return unless locked?

      pid, thread_id = parse_lock_file   
      raise "Database locked - PID: #{pid}, THREAD: #{thread_id}" unless mine?
      
      unlock!
    end

    def unlock!
      ActiveGit.logger.debug('ActiveGit') { "Unlock database (#{path})" }
      File.delete lock_file
    end

    private

    def locked?
      File.exists? lock_file
    end

    def mine?
      return false unless locked?
      
      pid, thread_id = parse_lock_file
      Process.pid == pid && Thread.current.object_id == thread_id
    end

    def lock!
      ActiveGit.logger.debug('ActiveGit') { "Lock database (#{path})" }
      File.write lock_file, "#{Process.pid}-#{Thread.current.object_id}"
    end

    def lock_file
      File.join path, FILE_NAME
    end

    def parse_lock_file
      IO.read(lock_file).split('-').map(&:to_i)
    end

  end
end