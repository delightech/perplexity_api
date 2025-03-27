module PerplexityApi
  class Configuration
    attr_accessor :api_key, :api_base, :default_model, :default_options

    def initialize
      @api_key = ENV["PERPLEXITY_API_KEY"]
      @api_base = ENV["PERPLEXITY_API_BASE"] || "https://api.perplexity.ai"
      @default_model = ENV["PERPLEXITY_DEFAULT_MODEL"] || "sonar"
      @default_options = {
        temperature: ENV["PERPLEXITY_TEMPERATURE"] ? ENV["PERPLEXITY_TEMPERATURE"].to_f : 0.7,
        max_tokens: ENV["PERPLEXITY_MAX_TOKENS"] ? ENV["PERPLEXITY_MAX_TOKENS"].to_i : 1024,
        top_p: ENV["PERPLEXITY_TOP_P"] ? ENV["PERPLEXITY_TOP_P"].to_f : 0.9,
        top_k: ENV["PERPLEXITY_TOP_K"] ? ENV["PERPLEXITY_TOP_K"].to_i : 0
      }
    end

    def validate!
      raise Error, "API key is not set." unless api_key
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end
  end
end