require 'spec_helper'

describe ActiveGit do

  before :each do
    @file_helper = FileHelper.new
    ActiveGit.configuration.working_path = @file_helper.create_temp_folder
  end

  after :each do
    @file_helper.remove_temp_folders
  end

  context 'Manual synchornization' do

    it 'Single model' do
      argentina = Country.create! name: 'Argentina'
      brasil = Country.create! name: 'Brasil'

      working_path = @file_helper.create_temp_folder

      File.exist?("#{working_path}/countries/#{argentina.id}.json").should be false
      File.exist?("#{working_path}/countries/#{brasil.id}.json").should be false

      ActiveGit.synchronize ActiveGit::FileSave.new(argentina, working_path)

      File.exist?("#{working_path}/countries/#{argentina.id}.json").should be true
      File.exist?("#{working_path}/countries/#{brasil.id}.json").should be false

      ActiveGit.synchronize ActiveGit::FileSave.new(brasil, working_path)

      File.exist?("#{working_path}/countries/#{argentina.id}.json").should be true
      File.exist?("#{working_path}/countries/#{brasil.id}.json").should be true
    end

    it 'Batch mode' do
      argentina = Country.create! name: 'Argentina'
      brasil = Country.create! name: 'Brasil'

      working_path = @file_helper.create_temp_folder

      File.exist?("#{working_path}/countries/#{argentina.id}.json").should be false
      File.exist?("#{working_path}/countries/#{brasil.id}.json").should be false

      ActiveGit.batch do
        ActiveGit.synchronize ActiveGit::FileSave.new(argentina, working_path)
        ActiveGit.synchronize ActiveGit::FileSave.new(brasil, working_path)

        File.exist?("#{working_path}/countries/#{argentina.id}.json").should be false
        File.exist?("#{working_path}/countries/#{brasil.id}.json").should be false
      end

      File.exist?("#{working_path}/countries/#{argentina.id}.json").should be true
      File.exist?("#{working_path}/countries/#{brasil.id}.json").should be true
    end

    it 'Handle exceptions' do
      argentina = Country.create! name: 'Argentina'
      brasil = Country.create! name: 'Brasil'

      working_path = @file_helper.create_temp_folder

      File.exist?("#{working_path}/countries/#{argentina.id}.json").should be false
      File.exist?("#{working_path}/countries/#{brasil.id}.json").should be false

      expect do
        ActiveGit.batch do
          ActiveGit.synchronize ActiveGit::FileSave.new(argentina, working_path)
          ActiveGit.synchronize ActiveGit::FileSave.new(brasil, working_path)
          raise 'Force error'
        end
      end.to raise_error

      File.exist?("#{working_path}/countries/#{argentina.id}.json").should be false
      File.exist?("#{working_path}/countries/#{brasil.id}.json").should be false

      uruguay = Country.create! name: 'Uruguay'
      ActiveGit.batch do
        ActiveGit.synchronize ActiveGit::FileSave.new(uruguay, working_path)
      end

      File.exist?("#{working_path}/countries/#{argentina.id}.json").should be false
      File.exist?("#{working_path}/countries/#{brasil.id}.json").should be false
      File.exist?("#{working_path}/countries/#{uruguay.id}.json").should be true
    end
    
  end

  context 'ActiveRecord synchornization' do

    before :each do
      ActiveGit.configuration.working_path = @file_helper.create_temp_folder
    end
    
    it 'Single model' do
      language = Language.create! name: 'Spanish'

      File.exist?(git_filename(language)).should be true
    end

    it 'Batch mode' do
      spanish = nil
      english = nil

      ActiveGit.batch do
        spanish = Language.create! name: 'Spanish'
        english = Language.create! name: 'English'

        File.exist?(git_filename(spanish)).should be false
        File.exist?(git_filename(english)).should be false
      end

      File.exist?(git_filename(spanish)).should be true
      File.exist?(git_filename(english)).should be true
    end

    it 'Batch process without events' do
      Language.count.should eq 0
      ActiveGit.batch {}
    end

    it 'Handle exceptions' do
      spanish = nil
      english = nil
      portuguese = nil      

      expect do
        ActiveGit.batch do
          spanish = Language.create! name: 'Spanish'
          english = Language.create! name: 'English'

          raise 'Force error'
        end
      end.to raise_error

      ActiveGit.batch do
        portuguese = Language.create! name: 'Portuguese'
      end

      File.exist?(git_filename(spanish)).should be false
      File.exist?(git_filename(english)).should be false
      File.exist?(git_filename(portuguese)).should be true
    end

  end

end