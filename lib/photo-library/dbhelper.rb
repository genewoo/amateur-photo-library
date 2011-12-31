require 'sequel'
require 'singleton'

module PhotoLibrary
  class DbConnection
    include Singleton

    def initialize
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
    def db_init
    end

    def regist_model
      self.init
    end
  end
end
