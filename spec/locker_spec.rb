require 'minitest_helper'

describe ActiveGit::Locker do

  let(:locker) { ActiveGit::Locker.new repo.path }

  let(:lock_file) { File.join repo.path, 'active_git.lock' }

  def lock_id
    "#{Process.pid}-#{Thread.current.object_id}"
  end

  before do
    ActiveGit.restore_default_configuration
  end

  it 'Lock' do
    locker.lock

    IO.read(lock_file).must_equal lock_id
  end

  it 'Lock timeout' do
    ActiveGit.lock_timeout = 0.01

    File.write lock_file, '0-0'

    proc { locker.lock }.must_raise Timeout::Error
  end

  it 'Wait for lock' do
    File.write lock_file, '0-0'

    Thread.new do 
      sleep 0.01
      File.delete lock_file
    end

    locker.lock

    IO.read(lock_file).must_equal lock_id
  end

  it 'Unlock' do
    File.write lock_file, lock_id

    locker.unlock

    File.exists?(lock_file).must_equal false
  end

  it 'Unlock fail' do
    File.write lock_file, '0-0'

    error = proc { locker.unlock }.must_raise RuntimeError
    error.message.must_equal 'Database locked - PID: 0, THREAD: 0'
  end

  it 'Force unlock' do
    File.write lock_file, '0'

    locker.unlock!

    File.exists?(lock_file).must_equal false
  end

end