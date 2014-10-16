require 'minitest_helper'

describe ActiveGit::Locker do

  let(:locker) { ActiveGit::Locker.new repo.path }

  let(:lock_file) { File.join repo.path, 'active_git.lock' }

  before do
    ActiveGit.restore_default_configuration
  end

  it 'Lock' do
    locker.lock

    File.exists?(lock_file).must_equal true
    IO.read(lock_file).must_equal Process.pid.to_s
  end

  it 'Lock timeout' do
    ActiveGit.lock_timeout = 0.01

    File.write lock_file, '0'

    proc { locker.lock }.must_raise Timeout::Error
  end

  it 'Wait for lock' do
    File.write lock_file, '0'

    Thread.new do 
      sleep 0.01
      File.delete lock_file
    end

    locker.lock
  end

  it 'Unlock'

  it 'Unlock fail'

  it 'Force unlock'

  it 'Current owner'

  # it 'Transaction' do
  #   locker.wont_be :locked?
  #   db.transaction do
  #     locker.must_be :locked?
  #   end
  #   locker.wont_be :locked?
  # end

end