require 'extlib'
require 'mime/types'

module Rack
  # Automatically sets the ETag header on all String bodies
  class Rockets
    def initialize(app, options = {}, &block)
      @app = app

      instance_eval(&block) if block_given?
    end
    
    def root; @root ||= %x{pwd}.chomp end

    def call(env)
      status, headers, body = @app.call(env)

      [status, headers, body]
    end
  end
end