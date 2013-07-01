require 'spec_helper'

describe ActiveGit::Inflector do

  let(:working_path) { '/home/git' }

  it 'Git path' do
    ActiveGit::Inflector.dirname(Country, working_path).should eq "#{working_path}/countries"
  end

  it 'Git path for nested model' do
    ActiveGit::Inflector.dirname(Crm::Customer, working_path).should eq "#{working_path}/crm/customers"
  end

  it 'Git relative path' do
    ActiveGit::Inflector.relative_dirname(Country).should eq "countries"
  end

  it 'Git file' do
    country = Country.create! name: 'Argentina'
    ActiveGit::Inflector.filename(country, working_path).should eq "#{working_path}/countries/#{country.id}.json"
  end

  it 'Git file for nested model' do
    customer = Crm::Customer.create! name: 'Monster Inc.'
    ActiveGit::Inflector.filename(customer, working_path).should eq "#{working_path}/crm/customers/#{customer.id}.json"
  end

  it 'Git relative file' do
    country = Country.create! name: 'Argentina'
    ActiveGit::Inflector.relative_filename(country).should eq "countries/#{country.id}.json"
  end

  it 'Model from filename' do
    ActiveGit::Inflector.model("#{working_path}/countries/1.json", working_path).should be Country
  end

  it 'Model from filename' do
    ActiveGit::Inflector.model("#{working_path}/crm/customers/1.json", working_path).should be Crm::Customer
  end

  it 'Model id' do
    ActiveGit::Inflector.model_id("#{working_path}/crm/customers/1.json").should eq '1'
  end

end