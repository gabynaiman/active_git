require 'minitest_helper'

describe ActiveGit::Database, 'Tag' do
  
  it 'Head' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'First commit'

    db.save :countries, id: 2, name: 'Uruguay'
    db.commit 'Second commit'
    
    db.tag 'test'

    repo.tags.count.must_equal 1
    repo.tags.first.name.must_equal 'test'
    repo.tags['test'].target_id.must_equal repo.head.target_id
  end

  it 'Commit' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'First commit'

    db.save :countries, id: 2, name: 'Uruguay'
    db.commit 'Second commit'

    commit_id = repo.head.log.first[:id_new]
    db.tag 'test', commit_id

    repo.tags.count.must_equal 1
    repo.tags.first.name.must_equal 'test'
    repo.tags['test'].target_id.must_equal commit_id
  end

  it 'Pending commit' do
    db.save :countries, id: 1, name: 'Argentina'

    proc { db.tag 'test' }.must_raise ActiveGit::Errors::CommitPending

    db.commit 'Test commit'
    db.save :countries, id: 2, name: 'Uruguay'
    
    proc { db.tag 'test' }.must_raise ActiveGit::Errors::CommitPending
  end

end