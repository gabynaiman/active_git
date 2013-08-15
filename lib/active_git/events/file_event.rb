module ActiveGit
  class FileEvent

    attr_reader :data

    def initialize(data, working_path=nil)
      @data = data
      @working_path = working_path || ActiveGit.configuration.working_path
    end

    protected

    def file_name
      Inflector.filename(@data, @working_path)
    end

  end
end