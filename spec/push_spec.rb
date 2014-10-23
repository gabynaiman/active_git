require 'minitest_helper'

describe ActiveGit::Database, 'Push' do

  it 'Default' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'Test commit'

    db.push

    bare_repo.head.target_id.must_equal repo.head.target_id
  end

  it 'Remote' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'Test commit'

    db.push remote: 'other'

    other_bare_repo.head.target_id.must_equal repo.head.target_id
  end

  it 'Fail' do
    other_db.save :countries, id: 1, name: 'Argentina'
    other_db.commit 'Clone commit'
    other_db.push

    db.save :countries, id: 2, name: 'Uruguay'
    db.commit 'DB commit'

    error = proc { db.push }.must_raise ActiveGit::Errors::PushRejected
    error.path.must_equal repo.workdir
    error.remote.must_equal 'origin'
    error.ref_name.must_equal 'master'
    error.message.must_equal "Push rejected: origin -> master (#{repo.workdir})"
  end

  it 'Force' do
    other_db.save :countries, id: 1, name: 'Argentina'
    other_db.commit 'Clone commit'
    other_db.push

    db.save :countries, id: 2, name: 'Uruguay'
    db.commit 'DB commit'
    db.push mode: :force

    bare_repo.head.target_id.must_equal repo.head.target_id
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