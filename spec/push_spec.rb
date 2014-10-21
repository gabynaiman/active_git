require 'minitest_helper'

describe ActiveGit::Database, 'Push' do

  def read_content(repo, path)
    oid = repo.index[path][:oid]
    JSON.parse repo.lookup(oid).content
  end

  it 'Default' do
    db.save :countries, id: 1, name: 'Argentina'
    db.save :countries, id: 2, name: 'Uruguay'
    db.save :countries, id: 3, name: 'Brasil'
    db.commit 'Test commit'
    db.push

    clone_repo.index.count.must_equal 0

    clone_repo.fetch 'origin'
    clone_repo.checkout 'origin/master'

    clone_repo.index.count.must_equal 3
    read_content(clone_repo, 'countries/1.json').must_equal 'id' => 1, 'name' => 'Argentina'
    read_content(clone_repo, 'countries/2.json').must_equal 'id' => 2, 'name' => 'Uruguay'
    read_content(clone_repo, 'countries/3.json').must_equal 'id' => 3, 'name' => 'Brasil'
  end

  it 'Fail' do
    clone_db.save :countries, id: 1, name: 'Argentina'
    clone_db.commit 'Clone commit'
    clone_db.push

    db.save :countries, id: 2, name: 'Uruguay'
    db.commit 'DB commit'

    error = proc { db.push }.must_raise ActiveGit::Errors::PushRejected
    error.path.must_equal repo.workdir
    error.remote.must_equal 'origin'
    error.ref_name.must_equal 'master'
    error.message.must_equal "Push rejected: origin -> master (#{repo.workdir})"
  end

  it 'Force' do
    clone_db.save :countries, id: 1, name: 'Argentina'
    clone_db.commit 'Clone commit'
    clone_db.push

    db.save :countries, id: 2, name: 'Uruguay'
    db.commit 'DB commit'
    db.push mode: :force
  end

  it 'Delete' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'Test commit'

    bare_repo.references.count.must_equal 0

    db.push

    bare_repo.references.count.must_equal 1
    bare_repo.references.first.name.must_equal 'refs/heads/master'

    db.push mode: :delete

    bare_repo.references.count.must_equal 0
  end

  it 'Branch' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'Test commit'
    db.branch 'test'

    bare_repo.references.count.must_equal 0

    db.push branch: 'test'

    bare_repo.references.count.must_equal 1
    bare_repo.references.first.name.must_equal 'refs/heads/test'
  end

  it 'Tag' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'Test commit'
    db.tag 'test'

    bare_repo.references.count.must_equal 0

    db.push tag: 'test'

    bare_repo.references.count.must_equal 1
    bare_repo.references.first.name.must_equal 'refs/tags/test'
  end

end