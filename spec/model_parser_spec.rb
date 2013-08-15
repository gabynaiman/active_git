require 'spec_helper'

describe ActiveGit::ModelParser do

  LANGUAGE = {
      id: 1,
      name: 'Spanish',
      created_at: Time.now,
      updated_at: Time.now,
      countries: [
          {
              id: 1,
              name: 'Argentina',
              LANGUAGE_id: 1,
              cities: [
                  {id: 1, name: 'Buenos Aires', country_id: 1},
                  {id: 2, name: 'Rosario', country_id: 1}
              ]
          }
      ]
  }

  [LANGUAGE, LANGUAGE.to_json].each do |source|
    it "Load from #{source.class.to_s.downcase}" do
      instance = ActiveGit::ModelParser.from_json(Language, source)

      instance.id.should eq LANGUAGE[:id]
      instance.name.should eq LANGUAGE[:name]
      instance.created_at.to_i.should eq LANGUAGE[:created_at].to_i
      instance.updated_at.to_i.should eq LANGUAGE[:updated_at].to_i
    end

    it "Instances from #{source.class.to_s.downcase}" do
      instances = ActiveGit::ModelParser.instances(Language, source)

      instances.count.should eq 4
      instances[0].class.should eq Language
      instances[0].name.should eq 'Spanish'
      instances[1].class.should eq Country
      instances[1].name.should eq 'Argentina'
      instances[2].class.should eq City
      instances[2].name.should eq 'Buenos Aires'
      instances[3].class.should eq City
      instances[3].name.should eq 'Rosario'
    end
  end

  it "instances from a hash with different associations" do
    country = {
      id: 1,
      name: 'Argentina',
      language: {id: 1, name: 'Spanish'},
      cities: [
          {id: 1, name: 'Buenos Aires', country_id: 1},
          {id: 2, name: 'Rosario', country_id: 1}
      ]
    }

    instances = ActiveGit::ModelParser.instances(Country, country)
    instances.count.should eq 4
    instances[0].class.should eq Country
    instances[0].name.should eq 'Argentina'
    instances[1].class.should eq Language
    instances[1].name.should eq 'Spanish'
    instances[2].class.should eq City
    instances[2].name.should eq 'Buenos Aires'
    instances[3].class.should eq City
    instances[3].name.should eq 'Rosario'
  end

end