require 'date'
require 'json'


module PhotoLibrary
  # it is a readonly value object

  PhotoLibrary::DbConnection.instance.connection

  class ExifJson
    attr_accessor :json

    #factory method
    def self.load(json)
      instance = self.new
      instance.json = json
      instance
    end
    
    def method_missing method, *args, &block
      self.json[method.to_s]
    end
  end

  class PhotoModel < Sequel::Model(:photos)

    include PhotoLibrary::Helper

#    include ExitJson

    #index_id
    attr_accessor :id #identify of record

    #index_hash_size
    attr_accessor :hash #SHA-1 code
    attr_accessor :size #Size and SHA will check duplicate
    
    attr_accessor :lib_path #relative path of library
    attr_accessor :time_taken #when do you take the photo
    attr_accessor :title # a title of picture 
    attr_accessor :notes # if you want to write something
    attr_accessor :original_path #include file name to restore it
    attr_accessor :tags #tag the picture
    attr_accessor :json #json from exiftool
    


    #transit fields
    attr_accessor :duplicated

    #json will be keep as blob


    def initialize(file_name)
      self.hash = file_hash(file_name)
      self.original_path = File.expand_path(file_name)
      self.size = File.size(file_name)
      #should check duplication
      exifinfo = JSON.parse(exif_json(file_name))
      self.json = exifinfo[0]
      self.time_taken = json["DateTimeOriginal"] # || other field
      # this is the default exiftool date time format
      self.time_taken = DateTime.strptime(self.time_taken, "%Y:%m:%d %H:%M:%S")
      self.title = json["FileName"]
      #support unix for first version YYYY/MM/DD
      self.lib_path = "%4d/%02d/%02d" % [self.time_taken.year, self.time_taken.month, self.time_taken.day]
    end

    def target_path
      File.join(self.lib_path, self.json["FileName"])
    end

    def self.check_duplicate(model)
    end

  end
end
