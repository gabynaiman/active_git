module ActiveGit
  class Database

    def initialize(path)
      @repository = Rugged::Repository.new path
      @transaction_scope = TransactionScope.new repository
    end

    def find(collection_name, id)
      path = build_path collection_name, id

      ActiveGit.logger.debug('ActiveGit') { "Find #{path} (#{repository.workdir})" }

      entry = repository.index[path]
      if entry
        blob = repository.lookup entry[:oid]
        JSON.parse blob.content
      else
        raise NotFound.new collection_name, id
      end
    end

    def save(collection_name, object)
      json = JSON.pretty_generate object
      oid = repository.write json, :blob
      ActiveGit.logger.debug('ActiveGit') { "Write object #{oid} - #{json.gsub("\n", '').gsub(" ", '')}" }

      transaction do |ts|
        ts.enqueue do
          path = build_path collection_name, object[:id] || object['id']
          
          ActiveGit.logger.debug('ActiveGit') { "Save #{path} - #{oid} (#{repository.workdir})" }
          repository.index.add path: path,
                               oid: oid,
                               mode: 0100644
        end
      end
    end

    def remove(collection_name, id)
      transaction do |ts|
        ts.enqueue do
          path = build_path collection_name, id

          ActiveGit.logger.debug('ActiveGit') { "Remove #{path} (#{repository.workdir})" }
          repository.index.remove path
        end
      end
    end

    def transaction(&block)
      @transaction_scope.call &block
    end

    def commit(message, options={})
      params = {
        message: message,
        parents: repository.empty? ? [] : [repository.head.target].compact,
        update_ref: 'HEAD',
        tree: repository.index.write_tree
      }
      
      params[:author] = options[:author] if options.key? :author
      params[:committer] = options[:committer] if options.key? :committer

      Rugged::Commit.create repository, params
    end

    private

    attr_reader :repository, :transaction_scope

    def build_path(collection_name, id)
      "#{collection_name}/#{id}.json"
    end
    
  end
end