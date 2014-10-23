require 'minitest_helper'

describe ActiveGit::Database, 'Pull' do

  def assert_empty_file_system(repository)
    Dir.glob(File.join(repository.workdir, '*')).must_be_empty
  end

  def assert_empty_status(repository)
    status = {}
    repository.status { |f,s| status[f] = s }
    status.must_be_empty
  end

  it 'Empty repo' do
    other_db.save :countries, id: 1, name: 'Argentina'
    other_db.commit 'Test commit'
    other_db.push

    repo.index.count.must_equal 0

    db.pull

    repo.head.target_id.must_equal other_repo.head.target_id
    repo.index.count.must_equal 1
    db.find(:countries, 1)['name'].must_equal 'Argentina'
    assert_empty_file_system repo
    assert_empty_status repo
  end

  it 'Up to date' do
    other_db.save :countries, id: 1, name: 'Argentina'
    other_db.commit 'Test commit'
    other_db.push

    db.pull

    proc { db.pull }.must_raise ActiveGit::Errors::UpToDate
  end

  it 'Commit pending error' do
    db.save :countries, id: 1, name: 'Argentina'

    proc { db.pull }.must_raise ActiveGit::Errors::CommitPending

    db.commit 'Test commit'
    db.save :countries, id: 2, name: 'Uruguay'
    
    proc { db.pull }.must_raise ActiveGit::Errors::CommitPending
  end

  it 'Update commit reference' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'First commit'
    db.push

    other_db.pull
    other_db.save :countries, id: 2, name: 'Uruguay'
    other_db.commit 'Second commit'
    other_db.push

    db.pull

    repo.head.target_id.must_equal other_repo.head.target_id
    repo.index.count.must_equal 2
    db.find(:countries, 1)['name'].must_equal 'Argentina'
    db.find(:countries, 2)['name'].must_equal 'Uruguay'
    assert_empty_file_system repo
    assert_empty_status repo
  end

  it 'Automatic merge' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'First commit'
    db.push

    other_db.pull
    other_db.save :countries, id: 1, name: 'Uruguay'
    other_db.commit 'Second commit'
    other_db.push

    db.save :countries, id: 2, name: 'Brasil'
    db.commit 'Third commit'

    db.pull

    repo.index.count.must_equal 2
    db.find(:countries, 1)['name'].must_equal 'Uruguay'
    db.find(:countries, 2)['name'].must_equal 'Brasil'
    assert_empty_file_system repo
    assert_empty_status repo
  end

  it 'Resolve conflicts (same ancestor)' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'First commit'
    db.push

    other_db.pull
    other_db.save :countries, id: 1, name: 'Uruguay'
    other_db.commit 'Second commit'
    other_db.push

    db.save :countries, id: 1, name: 'Brasil'
    db.commit 'Third commit'
    
    db.pull

    repo.index.count.must_equal 1
    db.find(:countries, 1)['name'].must_equal 'Brasil'
    assert_empty_file_system repo
    assert_empty_status repo
  end

  it 'Resolve conflicts (without ancestor)' do
    other_db.save :countries, id: 1, name: 'Uruguay'
    other_db.commit 'Fists commit'
    other_db.push

    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'Second commit'
    
    db.pull

    repo.index.count.must_equal 1
    db.find(:countries, 1)['name'].must_equal 'Argentina'
    assert_empty_file_system repo
    assert_empty_status repo
  end

  it 'Specific remote' do
    other_db.save :countries, id: 1, name: 'Argentina'
    other_db.commit 'Test commit'
    other_db.push remote: 'other'

    error = proc { db.pull }.must_raise ActiveGit::Errors::InvalidBranch
    error.branch_name.must_equal 'origin/master'
    error.message.must_equal 'Invalid branch origin/master'
    
    db.pull remote: 'other'

    repo.index.count.must_equal 1
    db.find(:countries, 1)['name'].must_equal 'Argentina'
    assert_empty_file_system repo
    assert_empty_status repo    
  end

end