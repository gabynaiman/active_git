module ActiveGit
  class TransactionStack

    def initialize
      @stack = 0
    end

    def incr
      @stack += 1
    end

    def decr
      @stack -= 1
    end

    def empty?
      @stack == 0
    end

    def clear
      @stack = 0
    end

  end
end