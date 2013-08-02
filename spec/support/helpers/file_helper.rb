require 'fileutils'

class FileHelper

  def initialize
    @temp_folders = []
  end

  def create_temp_folder
    folder_name = "#{temp_path}/#{timestamp}"
    @temp_folders << folder_name
    FileUtils.mkpath folder_name
    folder_name
  end

  def remove_temp_folders
    @temp_folders.each do |folder_name|
      FileUtils.rm_rf folder_name
    end
  end

  def write_file(file_name, content)
    Dir.mkdir File.dirname(file_name) unless Dir.exist? File.dirname(file_name)
    File.open(file_name, 'w') { |f| f.puts content }
  end

  def read_file(file_name)
    File.open(file_name, 'r') { |f| f.readlines.join("\n").strip }
  end

  private

  def temp_path
    Pathname.new("#{File.dirname(__FILE__)}/../../tmp").expand_path.to_s
  end

  def timestamp
    sleep(0.01)
    (Time.now.to_f * 1000).to_i
  end

end