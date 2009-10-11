module Rack::Rockets
  class AbstractProcessor
    attr_accessor :path
    def initialize(path, options = {}, &block)
      self.path = path
    end
    
    def call(env)
      proccess
      render
    end
    
    def process; raise NotImplementedError, 'you must implement the process method' end
    
    def render; raise NotImplementedError, 'you must implement the process method' end
  end
end