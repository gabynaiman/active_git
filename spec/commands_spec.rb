require 'spec_helper'

describe ActiveGit::Commands do

  before :each do
    @file_helper = FileHelper.new
    ActiveGit.configuration.working_path = @file_helper.create_temp_folder
    ActiveGit.init
  end

  after :each do
    @file_helper.remove_temp_folders
  end

  context 'Dump and load' do

    it 'Dump complete db to files' do
      languages = [
          Language.create!(name: 'Spanish'),
          Language.create!(name: 'English')
      ]

      @file_helper.write_file "#{ActiveGit.configuration.working_path}/test.txt", 'test'
      @file_helper.write_file "#{Language.git_folder}/0.json", 'test'

      ActiveGit.dump_db

      File.exist?("#{ActiveGit.configuration.working_path}/test.txt").should be_false

      Dir.glob("#{Language.git_folder}/*.json").should have(2).items

      languages.each do |language|
        File.exist?(language.git_file).should be_true
        json = JSON.parse(@file_helper.read_file(language.git_file))
        json['id'].should eq language.id
        json['name'].should eq language.name
      end
    end

    it 'Load all files to db' do
      languages = [
          Language.create!(name: 'Spanish'),
          Language.create!(name: 'English')
      ]

      Language.first.delete

      languages.each do |language|
        File.exist?(language.git_file).should be_true
      end

      ActiveGit.load_files

      Language.count.should be 2

      languages.each do |language|
        language.reload.should be_a Language
      end
    end

  end

  context 'Git synchronization' do

    it 'Commit all files' do
      Language.create! name: 'Spanish'

      ActiveGit.status.should_not be_empty

      ActiveGit.commit_all 'Commit for test'

      ActiveGit.status.should be_empty

      ActiveGit.log.first.subject.should eq 'Commit for test'
    end

    it 'Push and pull' do
      bare = GitWrapper::Repository.new @file_helper.create_temp_folder
      bare.init_bare

      spanish = Language.create! name: 'Spanish'
      english = Language.create! name: 'English'
      ActiveGit.commit_all 'Local commit'
      ActiveGit.add_remote 'bare', bare.location
      ActiveGit.push 'bare'

      remote = GitWrapper::Repository.new @file_helper.create_temp_folder
      remote.init
      remote.add_remote 'bare', bare.location
      remote.pull 'bare'

      to_json = Proc.new do |id, name|
        JSON.pretty_generate id: id, name: name, created_at: Time.now, updated_at: Time.now
      end
      @file_helper.write_file "#{remote.location}/languages/#{spanish.id}.json", to_json.call(spanish.id, 'Spanish 2')
      @file_helper.write_file "#{remote.location}/languages/888.json", to_json.call(888, 'Portuguese')
      @file_helper.write_file "#{remote.location}/languages/999.json", to_json.call(999, 'French')
      FileUtils.rm "#{remote.location}/languages/#{english.id}.json"

      remote.add_all
      remote.commit 'Remote commit'
      remote.push 'bare'

      Language.count.should eq 2

      ActiveGit.pull('bare').should be_true

      ActiveGit.log.first.subject.should eq 'Remote commit'
      Language.count.should eq 3
      ['Spanish 2', 'Portuguese', 'French'].each do |lang_name|
        File.exist?(Language.find_by_name(lang_name).git_file).should be_true
      end
    end

    it 'Checkout' do
      Language.create! name: 'Spanish'
      Language.create! name: 'English'

      ActiveGit.commit_all 'Commit 1'
      ActiveGit.branch 'branch_test'
      ActiveGit.checkout 'branch_test'

      Language.first.destroy
      ActiveGit.commit_all 'Commit 2'

      Language.count.should eq 1

      ActiveGit.checkout 'master'

      Language.count.should eq 2

      ActiveGit.checkout 'branch_test'

      Language.count.should eq 1
    end

    it 'Reset to specific commit' do
      spanish = Language.create! name: 'Spanish'
      ActiveGit.commit_all 'Commit 1'

      english = Language.create! name: 'English'
      ActiveGit.commit_all 'Commit 1'

      Language.count.should eq 2
      File.exist?(spanish.git_file).should be_true
      File.exist?(english.git_file).should be_true

      ActiveGit.reset ActiveGit.log.last.commit_hash

      Language.count.should eq 1
      File.exist?(spanish.git_file).should be_true
      File.exist?(english.git_file).should be_false
    end

    it 'Reset to HEAD' do
      spanish = Language.create! name: 'Spanish'
      ActiveGit.commit_all 'Commit 1'

      english = Language.create! name: 'English'

      Language.count.should eq 2
      File.exist?(spanish.git_file).should be_true
      File.exist?(english.git_file).should be_true

      ActiveGit.reset

      Language.count.should eq 1
      File.exist?(spanish.git_file).should be_true
      File.exist?(english.git_file).should be_false
    end

    it 'Resolve version conflicts' do
      bare = GitWrapper::Repository.new @file_helper.create_temp_folder
      bare.init_bare

      ActiveGit.add_remote 'bare', bare.location
      
      spanish = Language.create! name: 'Spanish'

      ActiveGit.commit_all 'commit v1'
      ActiveGit.push 'bare'

      other_repo = GitWrapper::Repository.new @file_helper.create_temp_folder
      other_repo.init
      other_repo.add_remote 'bare', bare.location
      other_repo.pull 'bare'

      @file_helper.write_file "#{other_repo.location}/languages/#{spanish.id}.json", JSON.pretty_generate(id: spanish.id, name: 'Spanish 2', created_at: Time.now, updated_at: Time.now)

      other_repo.add_all
      other_repo.commit 'commit v2'
      other_repo.push 'bare'

      spanish.update_attributes name: 'Spanish 3'
      ActiveGit.commit 'commit v3'

      ActiveGit.pull 'bare'

      spanish.reload.name.should eq 'Spanish 3'
    end

  end

end