require 'minitest_helper'

describe ActiveGit::Database, 'Branch' do
  
  it 'Current' do
    db.current_branch.must_equal 'master'
  end

  it 'Head' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'First commit'

    db.save :countries, id: 2, name: 'Uruguay'
    db.commit 'Second commit'
    
    db.branch 'test'

    repo.branches.count.must_equal 2
    repo.branches.map(&:name).must_equal %w(master test)
    repo.branches['test'].target_id.must_equal repo.head.target_id
  end

  it 'Commit' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'First commit'

    db.save :countries, id: 2, name: 'Uruguay'
    db.commit 'Second commit'

    commit_id = repo.head.log.first[:id_new]
    db.branch 'test', commit_id

    repo.branches.count.must_equal 2
    repo.branches.map(&:name).must_equal %w(master test)
    repo.branches['test'].target_id.must_equal commit_id
  end

end