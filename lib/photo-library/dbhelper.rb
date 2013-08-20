require 'sequel'
require 'singleton'

module PhotoLibrary
  class DbConnection
    include Singleton
    #extend Helper


    DEFAULT_FOLDER = '~/.photo-library'
    def initialize
      Helper.folder_exists! DEFAULT_FOLDER
      @dbfile = '~/.photo-library/database.sqlite3' if @dbfile.nil?
      @dbfile = File.expand_path(@dbfile)
      unless File.exists?(@dbfile) 
        @database = Sequel.sqlite(@dbfile)
      else
        @database = Sequel.connect("sqlite://#{@dbfile}")
      end
#      @database.loggers << Logger.new('~/.photo-library/db.log')
    end 
  
    def connection
      @database
    end
  end

  module DbHelper

    DB = DbConnection.instance.connection


#    def db_init
#    end

#    def self.regist_model
#      init
#    end
    
  end
end
