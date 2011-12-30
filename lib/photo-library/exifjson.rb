require 'date'

require 'json'

module PhotoLibrary
  # it's a readonly value object
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

  class PhotoModel < ExifJson

    include PhotoLibrary::Helper

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

    #json will be keep as blob


    def initialize(file_name)
      self.hash = file_hash(file_name)
      self.original_path = File.expand_path(file_name)
      exifinfo = JSON.parse(exif_json(file_name))
      self.json = exifinfo[0]
      self.time_taken = json["DateTimeOriginal"] # || other field
#      binding.pry
      self.time_taken = Date.parse(self.time_taken, "%Y:%m:%d %H:%M:%S")
      self.title = json["FileName"]
    end


  end
end
