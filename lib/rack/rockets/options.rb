module Rack::Rockets
  module Options
    class << self
      private
      def option_accessor(key)
        define_method(key) { || read_option(key) }
        define_method("#{key}=") { |value| write_option(key, value) }
        define_method("#{key}?") { || !! read_option(key) }
      end
    end

    # Enable verbose trace logging. This option is currently enabled by
    # default but is likely to be disabled in a future release.
    option_accessor :verbose

    # path to read the files from
    option_accessor :read_path
    
    # path to write the resulting files to
    option_accessor :write_path

    # store timestamps of files from when they were last served in order to have to keep from
    # reading from the file every time will probably be tokyo, redis, memcached compliant
    option_accessor :cache_store

    # an array of the types you want to be processed, should be a symbol of the file extension
    option_accessor :types

    # The underlying options Hash. During initialization (or outside of a
    # request), this is a default values Hash. During a request, this is the
    # Rack environment Hash. The default values Hash is merged in underneath
    # the Rack environment before each request is processed.
    def options
      @env || @default_options
    end

    # Set multiple options.
    def options=(hash={})
      hash.each { |key,value| write_option(key, value) }
    end

    # Set an option. When +option+ is a Symbol, it is set in the Rack
    # Environment as "rack-cache.option". When +option+ is a String, it
    # exactly as specified. The +option+ argument may also be a Hash in
    # which case each key/value pair is merged into the environment as if
    # the #set method were called on each.
    def set(option, value=self, &block)
      if block_given?
        write_option option, block
      elsif value == self
        self.options = option.to_hash
      else
        write_option option, value
      end
    end

  private
    def read_option(key)
      options[option_name(key)]
    end

    def write_option(key, value)
      options[option_name(key)] = value
    end

    def option_name(key)
      case key
      when Symbol ; "rack-rockets.#{key}"
      when String ; key
      else raise ArgumentError
      end
    end

  private
    def initialize_options(options={})
      @default_options = {
        'rack-rockets.types'         => %w(css js)
        'rack-rockets.cache_store'   => nil,
        'rack-rockets.processors'    => {
          :js => Javascript, 
          :css => Stylesheet
        },
        'rack-rockets.read_path'     => root / 'public',
        'rack-rockets.write_path'    => root / 'public'
      }
      self.options = options
      
      options[:types].each do |format|
        key = :"#{format}_path"
        options[key] = opts[:read_path] / opts unless opts.has_key?(key)
      end
    end
  end
end