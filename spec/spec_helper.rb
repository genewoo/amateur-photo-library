require 'rspec'
require 'simplecov'

SimpleCov.start

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'photo-library'


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

SAMPLE_CONFIG = File.join(File.dirname(__FILE__), '..', 'lib', 'photo-library', 'assets', 'sample.yml')

RSpec.configure do |config|

end
