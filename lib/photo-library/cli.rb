require 'fileutils'

module PhotoLibrary
  class Cli

    class << self
      include PhotoLibrary::Helper

      def run *args
        if args.empty?
          self.usage
        else
          self.send(args.shift.gsub("-", "_"), *args)
        end
      end

      # print the usage string, this is a fall through method.
      def usage
        puts %{
  Usage: photo-library ACTION [Arg] 

  ACTIONS:
  add [SOURCE_PATH] [-R] [-C]
      add photo from [SOURCE_PATH], if [SOURCE_PATH] is not present, use current folder.
      alias : a / --a / --add

      [-R] recrusive processing photo in SOURCE_PATH
      [-C] clean up after processing the file, (some of files will be removed)

      After processing, it will generate a summary of processing

  list [searchable] [config]
      list information
      alias : l or ls

      [searchable] show search able exif key
      [config] show config information
      
  search ['exifkey = value']
      alias : s

      create a new project file and open it in your editor

  summary [exifkey]
      print out the library summary
      [exifkey] print out the library uniq summary for one special exif key, value and count

  help
      alias : --help / -h
      shows this help document

  version
      alias : --version
      shows photo-library version number
}
      end

      alias :help :usage
      alias :__help :usage
      alias :_h :usage

=begin
      # Open a config file, it's created if it doesn't exist already.
      def open *args
        exit!("You must specify a name for the new project") unless args.size > 0
        puts "warning: passing multiple arguments to open will be ignored" if args.size > 1
        @name = args.shift
        config_path = "#{root_dir}#{@name}.yml"
        unless File.exists?(config_path)
          template = File.exists?(user_config) ? user_config : sample_config
          erb      = ERB.new(File.read(template)).result(binding)
          tmp      = File.open(config_path, 'w') {|f| f.write(erb) }
        end
        system("$EDITOR #{config_path}")
      end
      alias :o :open
      alias :new :open
      alias :n :open
=end
      

      def summary *args
        puts "= Summary ="
      end
      alias :__summary :summary

=begin
      def copy *args
        @copy = args.shift
        @name = args.shift
        @config_to_copy = "#{root_dir}#{@copy}.yml"

        exit!("Project #{@copy} doesn't exist!")             unless File.exists?(@config_to_copy)
        exit!("You must specify a name for the new project") unless @name

        file_path = "#{root_dir}#{@name}.yml"

        if File.exists?(file_path)
          confirm!("#{@name} already exists, would you like to overwrite it? (type yes or no):") do
            FileUtils.rm(file_path)
            puts "Overwriting #{@name}"
          end
        end
        open @name
      end
      alias :c :copy

      def delete *args
        puts "warning: passing multiple arguments to delete will be ignored" if args.size > 1
        filename  = args.shift
        file_path = "#{root_dir}#{filename}.yml"

        if File.exists?(file_path)
          confirm!("Are you sure you want to delete #{filename}? (type yes or no):") do
            FileUtils.rm(file_path)
            puts "Deleted #{filename}"
          end
        else
          exit! "That file doesn't exist."
        end
      end
      alias :d :delete

      def implode *args
        exit!("delete_all doesn't accapt any arguments!") unless args.empty?
        confirm!("Are you sure you want to delete all tmuxinator configs? (type yes or no):") do
          FileUtils.remove_dir(root_dir)
          puts "Deleted #{root_dir}"
        end
      end
      alias :i :implode
=end

      def list *args
        verbose = args.include?("-v")
        puts "tmuxinator configs:"
        Dir["#{root_dir}**"].each do |path|
          next unless verbose || File.extname(path) == ".yml"
          path = path.gsub(root_dir, '').gsub('.yml','') unless verbose
          puts "    #{path}"
        end
      end

      alias :l :list
      alias :ls :list

      def version
        system("cat #{File.dirname(__FILE__) + '/../../VERSION'}")
      end
      alias :v :version

      def doctor
        print "  checking if tmux is installed ==> "
        puts system("which tmux > /dev/null") ?  "Yes" : "No"
        print "  checking if $EDITOR is set ==> "
        puts ENV['EDITOR'] ? "Yes" : "No"
        print "  checking if $SHELL is set ==> "
        puts ENV['SHELL'] ? "Yes" : "No"
      end

      # build script and run it
      def start *args
        exit!("You must specify a name for the new project") unless args.size > 0
        puts "warning: passing multiple arguments to open will be ignored" if args.size > 1
        project_name = args.shift
        config_path = "#{root_dir}#{project_name}.yml"
        config = Tmuxinator::ConfigWriter.new(config_path).render
        # replace current proccess by running compiled tmux config
        exec(config)
      end
      alias :s :start

      def method_missing method, *args, &block
        start method if File.exists?("#{root_dir}#{method}.yml")
        puts "There's no command '#{method}' in photo-library"
        usage
      end

      private #==============================

      def root_dir
        # create ~/.tmuxinator directory if it doesn't exist
        Dir.mkdir("#{ENV["HOME"]}/.tmuxinator/") unless File.directory?(File.expand_path("~/.tmuxinator"))
        sub_dir = File.join(File.expand_path(Dir.pwd), '.tmuxinator/')
        if File.directory?(sub_dir)
          return sub_dir
        else
          return "#{ENV["HOME"]}/.tmuxinator/"
        end
      end

      def sample_config
        "#{File.dirname(__FILE__)}/assets/sample.yml"
      end

      def user_config
        @config_to_copy || "#{ENV["HOME"]}/.tmuxinator/default.yml"
      end

    end

  end
end

