require 'extlib'
require 'mime/types'

module Rack
  # Automatically sets the ETag header on all String bodies
  class Rockets
    def initialize(app, options = {}, &block)
      @app = app
      opts = {
        :types => [ :css, :js ],
        :processors => { 
          :js => Javascript, 
          :css => Stylesheet
        },
        :read_path => root / 'public',
        :write_path => root / 'public'
      }.merge(options)
      opts[:types].each do |format|
        opts[:"#{format}_path"] = opts[:read_path] / opts
      end
      instance_eval(&block) if block_given?
    end
    
    def root; @root ||= %x{pwd}.chomp end

    def call(env)
      status, headers, body = @app.call(env)

      [status, headers, body]
    end
  end
end