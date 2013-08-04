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

    File.exist?(git_filename(language)).should be true

    json = JSON.parse(@file_helper.read_file(git_filename(language)))

    json['id'].should eq language.id
    json['name'].should eq language.name
  end

  it 'Update' do
    language = Language.create! name: 'Spanish'

    json = JSON.parse(@file_helper.read_file(git_filename(language)))
    json['name'].should eq 'Spanish'

    language.update_attributes name: 'English'

    json = JSON.parse(@file_helper.read_file(git_filename(language)))
    json['name'].should eq 'English'
  end

  it 'Destroy' do
    language = Language.create! name: 'Spanish'

    File.exist?(git_filename(language)).should be true

    language.destroy

    File.exist?(git_filename(language)).should be false
  end

  it 'Load from json' do
    attributes = {id: 1, name: 'Spanish', created_at: Time.now, updated_at: Time.now}
    language = Language.from_json attributes.to_json

    language.id.should eq attributes[:id]
    language.name.should eq attributes[:name]
    language.created_at.to_i.should eq attributes[:created_at].to_i
    language.updated_at.to_i.should eq attributes[:updated_at].to_i
  end

end