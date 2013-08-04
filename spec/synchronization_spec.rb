require 'spec_helper'

describe ActiveGit::Synchronizer do

  before :each do
    @file_helper = FileHelper.new
  end

  after :each do
    @file_helper.remove_temp_folders
  end

  context 'Target GIT' do

    it 'Create' do
      country = Country.create! name: 'Argentina'

      working_path = @file_helper.create_temp_folder

      File.exist?("#{working_path}/countries/#{country.id}.json").should be false

      ActiveGit::Synchronizer.synchronize ActiveGit::FileSave.new(country, working_path)

      File.exist?("#{working_path}/countries/#{country.id}.json").should be true
    end

    it 'Update' do
      country = Country.create! name: 'Argentina'

      working_path = @file_helper.create_temp_folder

      file_name = "#{working_path}/countries/#{country.id}.json"
      @file_helper.write_file file_name, 'test'

      @file_helper.read_file(file_name).should eq 'test'

      ActiveGit::Synchronizer.synchronize ActiveGit::FileSave.new(country, working_path)

      json = JSON.parse @file_helper.read_file(file_name)
      json['id'].should eq country.id
      json['name'].should eq country.name
    end

    it 'Destroy' do
      country = Country.create! name: 'Argentina'

      working_path = @file_helper.create_temp_folder

      file_name = "#{working_path}/countries/#{country.id}.json"
      @file_helper.write_file file_name, 'test'

      ActiveGit::Synchronizer.synchronize ActiveGit::FileDelete.new(country, working_path)

      File.exist?("#{working_path}/countries/#{country.id}.json").should be false
    end

  end

  context 'Target DB' do

    it 'Create' do
      working_path = @file_helper.create_temp_folder

      file_name = "#{working_path}/countries/1.json"
      @file_helper.write_file file_name, {id: 1, name: 'Argentina', created_at: '2012-04-20T11:24:11-03:00', updated_at: '2012-04-20T11:24:11-03:00'}.to_json

      Country.count.should eq 0

      ActiveGit::Synchronizer.synchronize ActiveGit::DbCreate.new(file_name, working_path)

      Country.find(1).name.should eq 'Argentina'
    end

    it 'Update' do
      working_path = @file_helper.create_temp_folder

      country = Country.create! name: 'Argentina'

      file_name = "#{working_path}/countries/#{country.id}.json"
      @file_helper.write_file file_name, country.attributes.merge('name' => 'Brasil').to_json

      ActiveGit::Synchronizer.synchronize ActiveGit::DbUpdate.new(file_name, working_path)

      country.reload.name.should eq 'Brasil'
    end

    it 'Destroy' do
      working_path = @file_helper.create_temp_folder

      country = Country.create! name: 'Argentina'

      file_name = "#{working_path}/countries/#{country.id}.json"

      ActiveGit::Synchronizer.synchronize ActiveGit::DbDelete.new(file_name, working_path)

      Country.find_by_id(country.id).should be_nil
    end

  end

end