require 'spec_helper'

describe 'ActiveGit' do

  before :each do
    @file_helper = FileHelper.new
  end

  after :each do
    @file_helper.remove_temp_folders
  end

  context 'Target GIT' do

    it 'Create' do
      working_path = @file_helper.create_temp_folder

      Country.find_by_name('Argentina').should be_nil
      Country.find_by_name('Uruguay').should be_nil

      ActiveGit::batch do
        country = Country.create! name: 'Argentina'
        ActiveGit.synchronize ActiveGit::FileSave.new(country, working_path)

        File.exist?("#{working_path}/countries/#{country.id}.json").should be_false

        country = Country.create! name: 'Uruguay'
        ActiveGit.synchronize ActiveGit::FileSave.new(country, working_path)

        File.exist?("#{working_path}/countries/#{country.id}.json").should be_false
      end
      argentina = Country.find_by_name 'Argentina'
      uruguay = Country.find_by_name 'Uruguay'
      brasil = Country.create! name: 'Brasil'

      File.exist?("#{working_path}/countries/#{argentina.id}.json").should be_true
      File.exist?("#{working_path}/countries/#{uruguay.id}.json").should be_true
      File.exist?("#{working_path}/countries/#{brasil.id}.json").should be_false

      ActiveGit.synchronize ActiveGit::FileSave.new(brasil, working_path)

      File.exist?("#{working_path}/countries/#{brasil.id}.json").should be_true
    end

  end

end