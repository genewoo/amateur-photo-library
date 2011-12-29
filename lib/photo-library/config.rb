require 'yaml'
#require 'ostruct'
#require 'helper'

module PhotoLibrary
  class Config #< OpenStruct
    attr_accessor :config_path, :exiftool_path, :library_path

    def initialize(config_file = nil)
      self.config_path = "~/.photo-library.yml"
      self.config_path = config_file if config_file
      self.config_path = File::expand_path(self.config_path)
      load
    end

#    def root_dir
#      "$HOME/.photo-library/"
#    end

    def load
      config = YAML.load(File.read(self.config_path))
      self.exiftool_path = config["exiftool_path"]
      self.library_path = File::expand_path(config["library_path"])
#      File.exists?(self.library_path
    end
  end
end
