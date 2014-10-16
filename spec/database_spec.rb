require 'minitest_helper'

describe ActiveGit::Database do

  it 'Insert' do
    db.save :countries, id: 1, name: 'Argentina'
    repo.index.count.must_equal 1
    oid = repo.index['countries/1.json'][:oid]
    JSON.parse(repo.lookup(oid).content).must_equal 'id' => 1, 'name' => 'Argentina'
  end

  it 'Update' do
    db.save :countries, id: 1, name: 'Argentina'
    repo.index.count.must_equal 1
    oid_1 = repo.index['countries/1.json'][:oid]
    JSON.parse(repo.lookup(oid_1).content).must_equal 'id' => 1, 'name' => 'Argentina'

    db.save :countries, id: 1, name: 'Uruguay'
    repo.index.count.must_equal 1
    oid_2 = repo.index['countries/1.json'][:oid]
    JSON.parse(repo.lookup(oid_2).content).must_equal 'id' => 1, 'name' => 'Uruguay'
  end

  it 'Delete' do
    db.save :countries, id: 1, name: 'Argentina'
    repo.index['countries/1.json'].wont_be_nil

    db.remove :countries, 1
    repo.index['countries/1.json'].must_be_nil
  end

  it 'Find' do
    db.save :countries, id: 1, name: 'Argentina'
    hash = db.find :countries, 1
    hash.must_equal 'id' => 1, 'name' => 'Argentina'
  end

  it 'Not found' do
    error = proc { db.find :countries, 1 }.must_raise ActiveGit::NotFound
    error.collection_name.must_equal :countries
    error.id.must_equal 1
    error.message.must_equal 'Not found countries 1'
  end

end