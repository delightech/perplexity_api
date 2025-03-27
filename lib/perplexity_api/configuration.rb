module PerplexityApi
  class Configuration
    attr_accessor :api_key, :api_base, :default_model, :default_options

    def initialize
      @api_key = nil
      @api_base = "https://api.perplexity.ai"
      @default_model = "sonar"
      @default_options = {
        temperature: 0.7,
        max_tokens: 1024,
        top_p: 0.9,
        top_k: 0
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