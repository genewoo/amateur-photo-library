require 'digest'

module PhotoLibrary
  module Helper

=begin
    def exit!(msg)
      puts msg
      Kernel.exit(1)
    end
=end

    def self.exif_json(filename, exiftool = nil)
      exiftool = `which exiftool` if exiftool.nil?
      exiftool.gsub!("\n", "")
      json = IO.popen("#{exiftool} -j #{filename}")
      json.readlines.join
    end

    def self.confirm(msg, &block)
      puts "#{msg} [Confirm your action by Yes / No]"
      if %w(yes Yes YES y).include?(STDIN.gets.chop)
        block.call
      else
        false
      end
    end


    def self.file_hash(file_name)
#      Digest::MD5.hexdigest(File.read(file_name)) if File.exist?(file_name)
      # seems SHA1 get less chance have data corruption
      Digest::SHA1.hexdigest(File.read(file_name)) if File.exist?(file_name)
    end

    def self.folder_exists!(folder)
      folder = File.expand_path(folder)
      target = ""
      folder.split(File::SEPARATOR).each{ |path|
        target = "/" if target.empty? && path.empty? #Unix environment
        target = File.join(target, path).to_s
        create_folder(target) if path.empty?
      }
      target
    end

    private
    def self.create_folder(folder)
      Dir.mkdir(folder) if Dir[folder].empty?
    end
  end
end
