module ActiveGit
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
end