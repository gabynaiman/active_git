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

  it 'Dump' do
    brand = Brand.new name: 'Brand 1',
                      created_at: Time.parse('2012-04-20T11:24:11-03:00'),
                      updated_at: Time.parse('2012-04-20T11:24:11-03:00')

    brand.git_dump.should eq File.read("#{File.dirname(__FILE__)}/json/dump.json")
  end

  it 'Nested dump' do
    city = City.new name: 'Bs.As.'
    country = Country.new name: 'Argentina'
    country.cities << city
    language = Language.new name: 'Spanish'
    language.countries << country

    language.git_dump.should eq File.read("#{File.dirname(__FILE__)}/json/nested_dump.json")
  end

  it 'Parent and child dump' do
    language = Language.new name: 'Spanish'
    city = City.new name: 'Bs.As.'
    country = Country.new name: 'Argentina'
    country.cities << city
    country.language = language

    country.git_dump.should eq File.read("#{File.dirname(__FILE__)}/json/parent_child_dump.json")
  end

end