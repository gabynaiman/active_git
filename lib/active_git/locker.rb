module ActiveGit
  class Locker
  
    def initialize(path, owner=nil)
      @path = path
      @owner = owner || Process.pid
    end

    def locked?
      File.exists? lock_file
    end

    def lock
      timeout ActiveGit.lock_timeout do
        while locked?
          sleep 0.005
        end
        lock!
      end
    end

    def unlock
    end

    private

    def lock!
      File.write lock_file, @owner
    end

    def lock_file
      File.join @path, 'active_git.lock'
    end

  end
end