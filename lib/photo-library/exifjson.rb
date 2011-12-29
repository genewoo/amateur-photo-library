
module PhotoLibrary
  # it's a readonly value object
  class ExifJson
    attr_accessor :json

    def initialize(json)
      self.json = json
    end
    
    def method_missing method, *args, &block
      self.json[method.to_s]
    end
  end
end
