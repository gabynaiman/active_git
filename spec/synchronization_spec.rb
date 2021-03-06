require 'spec_helper'

describe ActiveGit::Synchronizer do

  before :each do
    @file_helper = FileHelper.new
    ActiveGit.configuration.working_path = @file_helper.create_temp_folder
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
      @file_helper.write_file file_name, {id: 1, name: 'Argentina', created_at: Time.now, updated_at: Time.now}.to_json

      Country.count.should eq 0

      ActiveGit::Synchronizer.synchronize ActiveGit::DbCreate.new(file_name, working_path)

      Country.find(1).name.should eq 'Argentina'
    end

    it 'Create multiple models from a file with 3 nested levels' do
      working_path = @file_helper.create_temp_folder

      city1_json = {id: 1, name: "Buenos Aires", country_id: 1, created_at: Time.now, updated_at: Time.now}
      city2_json = {id: 2, name: "Rosario", country_id: 1, created_at: Time.now, updated_at: Time.now}
      country1_json = {id: 1, name: 'Argentina', language_id: 1, created_at: Time.now, updated_at: Time.now, cities:[city1_json,city2_json]}

      city1_json = {id: 3, name: "Montevideo", country_id: 2, created_at: Time.now, updated_at: Time.now}
      city2_json = {id: 4, name: "Colonia", country_id: 2, created_at: Time.now, updated_at: Time.now}
      country2_json = {id: 2, name: 'Uruguay', language_id: 1, created_at: Time.now, updated_at: Time.now, cities:[city1_json,city2_json]}

      file_name = "#{working_path}/languages/1.json"
      @file_helper.write_file file_name, {id: 1, name: 'Spanish', created_at: Time.now, updated_at: Time.now, countries:[country1_json,country2_json] }.to_json

      Language.count.should eq 0
      Country.count.should eq 0
      City.count.should eq 0

      ActiveGit::Synchronizer.synchronize ActiveGit::DbCreate.new(file_name, working_path)

      Language.count.should eq 1
      Country.count.should eq 2
      City.count.should eq 4

      spanish = Language.find_by_name 'Spanish'

      spanish.countries.count.should eq 2
      spanish.countries.should include(Country.find_by_name 'Argentina')
      spanish.countries.should include(Country.find_by_name 'Uruguay')

      argentina = Country.find_by_name 'Argentina'

      argentina.cities.count.should eq 2
      argentina.cities.should include(City.find_by_name 'Buenos Aires')
      argentina.cities.should include(City.find_by_name 'Rosario')

      uruguay = Country.find_by_name 'Uruguay'

      uruguay.cities.count.should eq 2
      uruguay.cities.should include(City.find_by_name 'Montevideo')
      uruguay.cities.should include(City.find_by_name 'Colonia')
    end

    it 'Update' do
      country = Country.create! name: 'Argentina'

      @file_helper.write_file git_filename(country), country.attributes.merge('name' => 'Brasil').to_json

      ActiveGit::Synchronizer.synchronize ActiveGit::DbUpdate.new(git_filename(country))

      country.reload.name.should eq 'Brasil'
    end

    it 'Destroy' do
      country = Country.create! name: 'Argentina'

      ActiveGit::Synchronizer.synchronize ActiveGit::DbDelete.new(git_filename(country))

      Country.find_by_id(country.id).should be_nil
    end

    it 'Destroy nested models' do
      country1 = Country.create! name: 'Argentina'
      country1.cities << City.new(name: 'Bs.As.')
      country1.cities << City.new(name: 'Rosario')

      country2 = Country.create! name: 'Uruguay'
      country2.cities << City.new(name: 'Montevideo')
      country2.cities << City.new(name: 'Colonia')

      Country.count.should eq 2
      City.count.should eq 4

      ActiveGit::Synchronizer.synchronize ActiveGit::DbDelete.new(git_filename(country1))

      Country.count.should eq 1
      City.count.should eq 2
    end

    it 'Batch size' do
      ActiveGit.configuration.sync_batch_size = 2

      countries = 10.times.map do |i|
        Country.new(name: "Country #{i}") do |country|
          country.id = i.to_s
          country.created_at = Time.now
          country.updated_at = Time.now
        end
      end
      ActiveGit::Synchronizer.synchronize countries.map {|c| ActiveGit::FileSave.new(c)}

      events = countries.map do |country|
        ActiveGit::DbCreate.new(git_filename(country))
      end

      Country.should_receive(:import).
              exactly(5).times.
              and_return(double(failed_instances: []))

      ActiveGit::Synchronizer.synchronize events
    end

  end

end