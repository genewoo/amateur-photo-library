require "pry"
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'json'

class Dummy
end

describe Dummy do
  before(:all) do
    @d = PhotoLibrary::Helper
  end

  context "folder_exists " do

    before(:each) do
      Dir.rmdir("tmp") if File.directory?("tmp")
    end
    
    it "does create folder if does not present" do
      @d.folder_exists!("tmp").should eq File.expand_path("tmp")
    end

    it "does not create folder if it does present" do
      Dir.mkdir("tmp")
      @d.folder_exists!("tmp").should eq File.expand_path("tmp")
    end

    it "does create sub-folder as mkdir -p" do
      @d.folder_exists!("tmp/2010/10/01").should eq File.expand_path("tmp/2010/10/01")
    end

  end

  context "exif_json" do
    before(:all) do
      result = @d.exif_json('test/samples/20100820_006.jpg')
      result.should_not nil
      exifinfo = JSON.parse(result)
      exifinfo[0].should_not nil
      @result = exifinfo[0]
    end

    it "get exif as a json string" do
      @result.should_not nil
      @result["City"].should eq "Cupertino"
    end


    it "will be used in a ExifJson object" do
      json = PhotoLibrary::ExifJson.load(@result)
      json.City.should eq "Cupertino"
    end
    
    
  end

  context "file_hash" do
    before(:all) do
      @result = @d.file_hash('test/samples/20100820_006.jpg')
    end

    it "will calculate sha1 of file" do
      @result.should eq "c2c939d5b529c68d696288e784b351cdf561d0cf"
    end

  end

  context "confirm" do
=begin
    #comment out since it can't be test without input
    it "does confirm by use before actual action" do
      @d.confirm "confirm by YES", do 
        true
      end.should eq true
    end
=end
  end
end

describe PhotoLibrary::PhotoModel do


  context "Initial Model by File Name" do
    before(:all) do
#      PhotoLibrary::PhotoModel.drop
#      PhotoLibrary::PhotoModel.init
      @model = PhotoLibrary::PhotoModel.load_file('test/samples/20100820_006.jpg')
#      @model = PhotoLibrary::PhotoModel.new
#      @model.load_file('test/samples/20100820_006.jpg')
      @model.save
    end

    after(:all) do
      #PhotoLibrary::PhotoModel
      #p "after all"
    end

    it "should load exif information from file" do
      @model.should_not nil
      @model.title.should eq '20100820_006.jpg'
    end

    it "should get target path correctly" do
      @model.target_path.should eq "2010/08/20/20100820_006.jpg"
    end
  end
end

describe PhotoLibrary::Config do
  context "Without indicate config file" do
    before(:all) do
      system('cp lib/photo-library/assets/photo-library.yml ~/.photo-library.yml')
      @config = PhotoLibrary::Config.new
    end

    after(:all) do
#      system('rm ~/.photo-library.yml')
    end

    it "should use default value of home folder" do
      @config.exiftool_path.should eq '/usr/bin/exiftool'
      @config.library_path.should eq File.expand_path('~/.photo-library')
    end
  end
end

