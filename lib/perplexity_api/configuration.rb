module PerplexityApi
  class Configuration
    attr_accessor :api_key, :api_base, :default_model, :default_options, :debug_mode

    def initialize(load_env: true, debug_mode: false)
      @debug_mode = debug_mode
      
      # Load .env file if dotenv is available and load_env is true
      if load_env
        load_dotenv
      end
      
      # Load configuration from environment variables
      load_from_env
    end
    
    def load_dotenv
      begin
        require "dotenv"
        if File.exist?(".env")
          Dotenv.load
          debug_log "Loaded .env file"
        else
          debug_log ".env file not found"
        end
      rescue LoadError
        debug_log "dotenv gem not available. Install it with: gem install dotenv"
      end
    end
    
    def load_from_env
      @api_key = ENV["PERPLEXITY_API_KEY"]
      @api_base = ENV["PERPLEXITY_API_BASE"] || "https://api.perplexity.ai"
      @default_model = ENV["PERPLEXITY_DEFAULT_MODEL"] || "sonar"
      @default_options = {
        temperature: ENV["PERPLEXITY_TEMPERATURE"] ? ENV["PERPLEXITY_TEMPERATURE"].to_f : 0.7,
        max_tokens: ENV["PERPLEXITY_MAX_TOKENS"] ? ENV["PERPLEXITY_MAX_TOKENS"].to_i : 1024,
        top_p: ENV["PERPLEXITY_TOP_P"] ? ENV["PERPLEXITY_TOP_P"].to_f : 0.9,
        top_k: ENV["PERPLEXITY_TOP_K"] ? ENV["PERPLEXITY_TOP_K"].to_i : 0
      }
      
      debug_log "Configuration loaded from environment variables"
      debug_log "API Key: #{@api_key ? 'Set' : 'Not set'}"
      debug_log "API Base: #{@api_base}"
      debug_log "Default Model: #{@default_model}"
    end
    
    def validate!
      raise Error, "API key is not set." unless api_key
    end
    
    private
    
    def debug_log(message)
      puts "[PerplexityApi] #{message}" if @debug_mode
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end
    
    def load_dotenv(debug_mode: false)
      configuration.debug_mode = debug_mode
      configuration.load_dotenv
      configuration.load_from_env
    end
  end
end