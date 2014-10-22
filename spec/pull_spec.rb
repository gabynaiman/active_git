require 'minitest_helper'

describe ActiveGit::Database, 'Pull' do

  def assert_empty_file_system(path)
    Dir.glob(File.join(path, '*')).must_be_empty
  end

  def assert_empty_status(repository)
    status = {}
    repository.status { |f,s| status[f] = s }
    status.must_be_empty
  end

  # Pull de repo vacio sin commits
  it 'Empty repo' do
    clone_db.save :countries, id: 1, name: 'Argentina'
    clone_db.commit 'Test commit'
    clone_db.push

    repo.index.count.must_equal 0

    db.pull

    repo.head.target_id.must_equal clone_repo.head.target_id
    repo.index.count.must_equal 1
    db.find(:countries, 1)['name'].must_equal 'Argentina'
    assert_empty_file_system repo.workdir
    assert_empty_status repo
  end

  # Commit > push repo1, pull > pull repo2 (el segundo no tiene que hacer nada)
  it 'Up to date'

  # Pull (commit pendiente)
  it 'Commit pending error'

  # Commit > push repo1, pull > commit > push repo2, pull repo1 (archivos diferentes, no necesita merge)
  it 'Existent branch' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'First commit'
    db.push

    clone_db.pull
    clone_db.save :countries, id: 2, name: 'Uruguay'
    clone_db.commit 'Second commit'
    clone_db.push

    db.pull

    repo.index.count.must_equal 2
    db.find(:countries, 1)['name'].must_equal 'Argentina'
    db.find(:countries, 2)['name'].must_equal 'Uruguay'
    assert_empty_file_system repo.workdir
    assert_empty_status repo
  end

  # Commit > push repo1, commit > pull repo2 (mismo archivo, merge sin conflictos)
  it 'Automatic merge' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'First commit'
    db.push

    clone_db.pull
    clone_db.save :countries, id: 1, name: 'Uruguay'
    clone_db.commit 'Second commit'
    clone_db.push

    db.pull

    repo.index.count.must_equal 1
    db.find(:countries, 1)['name'].must_equal 'Uruguay'
    assert_empty_file_system repo.workdir
    assert_empty_status repo
  end

  # Commit > push repo1, commit > pull repo2 (merge manual)
  it 'Resolve conflicts' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'First commit'
    db.push

    clone_db.pull
    clone_db.save :countries, id: 1, name: 'Uruguay'
    clone_db.commit 'Second commit'
    clone_db.push

    db.save :countries, id: 1, name: 'Brasil'
    db.commit 'Third commit'
    
    db.pull

    repo.index.count.must_equal 1
    db.find(:countries, 1)['name'].must_equal 'Brasil'
    assert_empty_file_system repo.workdir
    assert_empty_status repo
  end

end