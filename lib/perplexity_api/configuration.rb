module PerplexityApi
  class Configuration
    attr_accessor :api_key, :api_base, :default_model, :default_options, :debug_mode, :default_timeout

    def initialize(debug_mode: false)
      @debug_mode = debug_mode
      
      # Load configuration from environment variables
      load_from_env
    end
    
    def load_from_env
      @api_key = ENV["PERPLEXITY_API_KEY"]
      @api_base = ENV["PERPLEXITY_API_BASE"] || "https://api.perplexity.ai"
      @default_model = ENV["PERPLEXITY_DEFAULT_MODEL"] || "sonar"
      @default_options = {
        temperature: ENV["PERPLEXITY_TEMPERATURE"] ? ENV["PERPLEXITY_TEMPERATURE"].to_f : 0.7,
        max_tokens: ENV["PERPLEXITY_MAX_TOKENS"] ? ENV["PERPLEXITY_MAX_TOKENS"].to_i : 1024,
        top_p: ENV["PERPLEXITY_TOP_P"] ? ENV["PERPLEXITY_TOP_P"].to_f : 0.9,
        top_k: ENV["PERPLEXITY_TOP_K"] ? ENV["PERPLEXITY_TOP_K"].to_i : 0,
        frequency_penalty: ENV["PERPLEXITY_FREQUENCY_PENALTY"] ? ENV["PERPLEXITY_FREQUENCY_PENALTY"].to_f : 0.0,
        presence_penalty: ENV["PERPLEXITY_PRESENCE_PENALTY"] ? ENV["PERPLEXITY_PRESENCE_PENALTY"].to_f : 0.0
      }
      @default_timeout = ENV["PERPLEXITY_TIMEOUT"] ? ENV["PERPLEXITY_TIMEOUT"].to_i : 30
      
      debug_log "Configuration loaded from environment variables"
      debug_log "API Key: #{@api_key ? 'Set' : 'Not set'}"
      debug_log "API Base: #{@api_base}"
      debug_log "Default Model: #{@default_model}"
    end
    
    def validate!
      raise Error, "API key is not set." unless api_key
    end
    
    # Public method for safe redaction of sensitive information
    def safe_redact(message)
      return message unless message.is_a?(String)
      
      # Redact API keys (Bearer tokens)
      message = message.gsub(/Bearer [a-zA-Z0-9\-_]+/, "Bearer [REDACTED]")
      
      # Redact potential API keys in various formats
      message = message.gsub(/api_key["\s]*[:=]["\s]*[a-zA-Z0-9\-_]+/, 'api_key: [REDACTED]')
      message = message.gsub(/["\']api_key["\']:\s*["\'][a-zA-Z0-9\-_]+["\']/, '"api_key": "[REDACTED]"')
      
      # Redact Authorization headers
      message = message.gsub(/Authorization["\s]*[:=]["\s]*[a-zA-Z0-9\-_\s]+/, 'Authorization: [REDACTED]')
      
      message
    end
    
    private
    
    def debug_log(message)
      puts "[PerplexityApi] #{safe_redact(message)}" if @debug_mode
    end

  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end
    
    def reload_env(debug_mode: false)
      configuration.debug_mode = debug_mode
      configuration.load_from_env
    end
  end
end