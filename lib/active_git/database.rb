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
        raise Errors::NotFound.new collection_name, id
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
        parents: options[:parents] || (repository.empty? ? [] : [repository.head.target].compact),
        update_ref: options[:update_ref] || 'HEAD',
        tree: options[:tree] || repository.index.write_tree
      }
      
      params[:author] = options[:author] if options.key? :author
      params[:committer] = options[:committer] if options.key? :committer

      Rugged::Commit.create repository, params
    end

    def push(options={})
      remote = options[:remote] || 'origin'

      ref = 
        if options[:branch]
          repository.branches[options[:branch]]
        elsif options[:tag]
          repository.tags[options[:tag]]
        else
          repository.branches.detect(&:head?)
        end

      refspec =
        if options[:mode] == :force
          "+#{ref.canonical_name}"
        elsif options[:mode] == :delete
          ":#{ref.canonical_name}"
        else
          ref.canonical_name
        end

      repository.fetch remote, [refspec]
      repository.push remote, [refspec]

    rescue Rugged::ReferenceError
      raise Errors::PushRejected.new repository.workdir, remote, ref.name
    end

    def pull(options={})
      remote = options[:remote] || 'origin'
      repository.fetch remote
      merge "#{remote}/#{current_branch}"
    end

    def merge(branch_name)
      # TODO: Raise PendingCommit
      transaction do |ts|
        ts.enqueue do
          branch = repository.branches[branch_name]
          
          if repository.branches[current_branch]
            parent_commits = [repository.head.target_id, branch.target_id]

            merge_index = repository.merge_commits *parent_commits
            if merge_index.conflicts.any?
              # resolve_conflicts merge_index
            end

            tree = merge_index.write_tree repository

            commit "Merge #{branch.name} into #{current_branch}", parents: parent_commits, tree: tree
          else
            branch = repository.branches.create current_branch, branch.target_id
          end
          
          repository.index.read_tree repository.head.target.tree

          # Hack for remove unstaged files without write file system
          repository.index.each do |entry|
            valid_entry = {path: entry[:path], oid: entry[:oid], mode: 0100644}
            repository.index.add valid_entry if entry[:valid] == false
          end
        end
      end
    end

    def current_branch
      branch = repository.branches.detect(&:head?)
      branch ? branch.name : 'master'
    end

    def branch(name, target_id=nil)
      # TODO: Raise PendingCommit
      target_id ||= repository.head.target_id
      repository.branches.create name, target_id
    end

    def tag(name, target_id=nil)
      # TODO: Raise PendingCommit
      target_id ||= repository.head.target_id
      repository.tags.create name, target_id
    end

    private

    attr_reader :repository, :transaction_scope

    def build_path(collection_name, id)
      "#{collection_name}/#{id}.json"
    end
    
  end
end