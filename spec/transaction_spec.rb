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

  it 'Nested' do
    db.transaction do
      db.transaction do
        db.save :countries, id: 1, name: 'Argentina'
        repo.index.count.must_equal 0
      end

      db.transaction do
        db.save :countries, id: 2, name: 'Uruguay'
        repo.index.count.must_equal 0
      end
    end

    repo.index.count.must_equal 2
  end

  it 'Locking' do
    ActiveGit.lock_timeout = 0.01

    thread = Thread.new do
      db.transaction do |ts|
        db.save :countries, id: 1, name: 'Argentina'
        ts.enqueue { sleep 0.05 }
      end      
    end

    # Wait for thread start
    sleep 0.01

    proc do
      db.transaction do
        db.save :countries, id: 2, name: 'Uruguay'
      end
    end.must_raise Timeout::Error
  end

end