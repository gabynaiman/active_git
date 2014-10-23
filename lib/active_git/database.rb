module ActiveGit
  class Database

    FILE_MODE = 0100644

    def initialize(path)
      @repository = Rugged::Repository.new path
      @transaction_scope = TransactionScope.new repository
    end

    def find(collection_name, id)
      path = build_path collection_name, id

      ActiveGit.logger.debug('ActiveGit') { "Find #{path} (#{repository.workdir})" }

      entry = repository.index[path]
      raise Errors::NotFound.new collection_name, id unless entry

      read_blob entry[:oid]
    end

    def save(collection_name, object)
      oid = write_blob object
      ActiveGit.logger.debug('ActiveGit') { "Write object #{oid} - #{json.gsub("\n", '').gsub(" ", '')}" }

      transaction do |ts|
        ts.enqueue do
          path = build_path collection_name, object[:id] || object['id']
          
          ActiveGit.logger.debug('ActiveGit') { "Save #{path} - #{oid} (#{repository.workdir})" }
          repository.index.add path: path, oid: oid, mode: FILE_MODE
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
      raise Errors::CommitPending if pending_commit?

      branch = repository.branches[branch_name]
      raise Errors::InvalidBranch.new branch_name unless branch

      transaction do |ts|
        ts.enqueue do

          if repository.branches[current_branch]
            merge_analysis = repository.merge_analysis branch.target_id

            raise Errors::UpToDate if merge_analysis.include? :up_to_date
              
            if merge_analysis.include? :fastforward
              repository.references.update repository.branches[current_branch].canonical_name, branch.target_id
            else
              parent_commits = [repository.head.target_id, branch.target_id]

              merge_index = repository.merge_commits *parent_commits

              merge_index.conflicts.each do |conflict|
                base = conflict[:ancestor] ? read_blob(conflict[:ancestor][:oid]) : {}
                ours = read_blob conflict[:ours][:oid]
                theirs = read_blob conflict[:theirs][:oid]
                
                merge = ConflictResolver.resolve base, ours, theirs
                merge_oid = write_blob merge

                merge_index.conflict_remove conflict[:ours][:path]
                merge_index.add path: conflict[:ours][:path], oid: merge_oid, mode: FILE_MODE
              end

              tree = merge_index.write_tree repository

              commit "Merge #{branch.name} into #{current_branch}", parents: parent_commits, tree: tree
            end
          else
            repository.branches.create current_branch, branch.target_id
          end
          
          reload_index
        end
      end
    end

    def current_branch
      branch = repository.branches.detect(&:head?)
      branch ? branch.name : 'master'
    end

    def branch(name, target_id=nil)
      raise Errors::CommitPending if pending_commit?

      target_id ||= repository.head.target_id
      repository.branches.create name, target_id
    end

    def tag(name, target_id=nil)
      raise Errors::CommitPending if pending_commit?

      target_id ||= repository.head.target_id
      repository.tags.create name, target_id
    end

    private

    attr_reader :repository, :transaction_scope

    def build_path(collection_name, id)
      "#{collection_name}/#{id}.json"
    end

    def reload_index
      repository.index.read_tree repository.head.target.tree

      # Hack for remove unstaged files without write file system
      repository.index.each do |entry|
        valid_entry = {path: entry[:path], oid: entry[:oid], mode: FILE_MODE}
        repository.index.add valid_entry if entry[:valid] == false
      end
    end

    def pending_commit?
      if repository.head_unborn?
        repository.index.count > 0
      else
        oid = repository.index.write_tree
        tree = repository.lookup oid
        tree.diff(repository.last_commit).count > 0
      end
    end

    def read_blob(oid)
      blob = repository.lookup oid
      JSON.parse blob.content
    end

    def write_blob(object)
      json = JSON.pretty_generate object
      repository.write json, :blob
    end
    
  end
end