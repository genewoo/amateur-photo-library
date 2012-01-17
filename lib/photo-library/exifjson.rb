require 'date'
require 'json'


module PhotoLibrary
  # it is a readonly value object

#  PhotoLibrary::DbConnection.instance.connection

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
    include PhotoLibrary::DbHelper
    include PhotoLibrary::Helper

#    include ExitJson

    #index_id
    attr_accessor :id #identify of record

    #index_hash_size
    attr_accessor :hash_code #SHA-1 code
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


    def self.exif_json(filename, exiftool = nil)
      exiftool = `type -p exiftool` if exiftool.nil?
      exiftool.gsub!("\n", "")
      json = IO.popen("#{exiftool} -j #{filename}")
      json.readlines.join
    end


    def self.load_file(file_name)
      hash_code = Digest::SHA1.hexdigest(File.read(file_name)) if File.exist?(file_name)
      result = self[:hash_code => hash_code]
      if result.nil?
        result = self.new
        result.hash_code = hash_code
        result.original_path = File.expand_path(file_name)
        result.size = File.size(file_name)
        #should check duplication
        exifinfo = JSON.parse(exif_json(file_name))
        result.json = exifinfo[0]
        result.time_taken = result.json["DateTimeOriginal"] # || other field
        # this is the default exiftool date time format
        result.time_taken = DateTime.strptime(result.time_taken, "%Y:%m:%d %H:%M:%S")
        result.title = result.json["FileName"]
        #support unix for first version YYYY/MM/DD
        result.lib_path = "%4d/%02d/%02d" % [result.time_taken.year, result.time_taken.month, result.time_taken.day]
        result.duplicated = false;
=begin
        columns.each { |c|
          next if c == :id
          result[c] = result.instance_eval(c.to_s)
          p result[c]
  #        self[c] = self.instance_eval(c.to_s) unless self.instance_variable_defined?(c.to_s)
        }
=end
      else
        result.duplicated = true
        result.after_load
      end
      result
    end

    def target_path
      File.join(self.lib_path, self.json["FileName"])
    end

    def self.drop
      DB.drop_table :photos
    end

    def self.init
      DB.create_table? :photos do
        primary_key :id
        String :hash_code, :unique => true, :null => false #SHA-1 code
#        TrueClass :active, :default => true
#        foreign_key :category_id, :categories
        
        Fixnum :size, :unsigned => true #Size and SHA will check duplicate
        
        String :lib_path #relative path of library
        DateTime :time_taken #when do you take the photo
        String :title # a title of picture
        String :notes # if you want to write something
        String :original_path, :null => false #include file name to restore it
#        :tags #tag the picture TODO
#        DateTime :created_at
        String :json, :text=>true #json from exiftool
        index [:hash_code, :size]
      end
    end

    def before_save
      columns.each { |c|
        next if [:id, :json].include? c
        self[c] = instance_eval(c.to_s)
      }
      self[:json] = JSON.dump(self.json)
      super
    end

    def after_load
      columns.each { |c|
        self.instance_variable_set("@#{c.to_s}".to_sym, self[c] )
      }
      self.json = JSON.parse(self.json)
      self
    end

    init
  end
end
