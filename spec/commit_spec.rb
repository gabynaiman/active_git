require 'minitest_helper'

describe ActiveGit::Database, 'Commit' do

  it 'Initial' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'Test commit'

    repo.head.target.tap do |commit|
      commit.parents.must_equal []
      commit.message.must_equal 'Test commit'
      commit.tree.entries.count.must_equal 1
      
      countries_tree = repo.lookup(commit.tree['countries'][:oid])
      countries_tree.entries.count.must_equal 1
      JSON.parse(repo.lookup(countries_tree['1.json'][:oid]).content).must_equal 'id' => 1, 'name' => 'Argentina'
    end
  end

  it 'Change author and commiter' do
    author = {name: 'Test Author', email: 'author@test.com'}
    committer = {name: 'Test Committer', email: 'committer@test.com'}

    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'Change author and commiter', author: author, committer: committer

    repo.head.target.tap do |commit|
      commit.author[:name].must_equal 'Test Author'
      commit.author[:email].must_equal 'author@test.com'

      commit.committer[:name].must_equal 'Test Committer'
      commit.committer[:email].must_equal 'committer@test.com'
    end
  end

  it 'Chained' do
    db.save :countries, id: 1, name: 'Argentina'
    db.commit 'First commit'

    db.save :countries, id: 2, name: 'Uruguay'
    db.commit 'Second commit'

    tree_1 = repo.lookup(repo.lookup(repo.head.log[0][:id_new]).tree['countries'][:oid])
    tree_1.count.must_equal 1
    tree_1['1.json'].wont_be_nil
    tree_1['2.json'].must_be_nil

    tree_2 = repo.lookup(repo.lookup(repo.head.log[1][:id_new]).tree['countries'][:oid])
    tree_2.count.must_equal 2
    tree_2['1.json'].wont_be_nil
    tree_2['2.json'].wont_be_nil
  end

end