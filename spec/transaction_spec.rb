require 'minitest_helper'

describe ActiveGit::TransactionScope do
  
  it 'Commit' do
    db.transaction do
      db.save :countries, id: 1, name: 'Argentina'
      repo.index.count.must_equal 0
    end
    repo.index.count.must_equal 1
  end

  it 'Rollback' do
    silent do
      db.transaction do
        db.save :countries, id: 1, name: 'Argentina'
        raise 'Force rollback'
      end
    end
    repo.index.count.must_equal 0
  end

end