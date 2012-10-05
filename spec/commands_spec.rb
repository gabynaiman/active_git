require 'spec_helper'

describe ActiveGit::Commands do

  before :each do
    @file_helper = FileHelper.new
    ActiveGit.configuration.working_path = @file_helper.create_temp_folder
  end

  after :each do
    @file_helper.remove_temp_folders
  end

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