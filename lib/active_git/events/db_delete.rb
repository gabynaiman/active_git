module ActiveGit
  class DbDelete < DbEvent

    def synchronize(synchronizer)
      synchronizer.db_delete model, model_id
    end

  end
end