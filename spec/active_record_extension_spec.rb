require 'spec_helper'

describe ActiveGit::ActiveRecord do

  before :each do
    @file_helper = FileHelper.new
    ActiveGit.configuration.working_path = @file_helper.create_temp_folder
  end

  after :each do
    @file_helper.remove_temp_folders
  end

  it 'Registered models' do
    ActiveGit.models.should include Language
  end

  it 'Create' do
    language = Language.create! name: 'Spanish'

    File.exist?(language.git_file).should be_true

    json = JSON.parse(@file_helper.read_file(language.git_file))

    json['id'].should eq language.id
    json['name'].should eq language.name
  end

  it 'Update' do
    language = Language.create! name: 'Spanish'

    json = JSON.parse(@file_helper.read_file(language.git_file))
    json['name'].should eq 'Spanish'

    language.update_attributes name: 'English'

    json = JSON.parse(@file_helper.read_file(language.git_file))
    json['name'].should eq 'English'
  end

  it 'Destroy' do
    language = Language.create! name: 'Spanish'

    File.exist?(language.git_file).should be_true

    language.destroy

    File.exist?(language.git_file).should be_false
  end

end