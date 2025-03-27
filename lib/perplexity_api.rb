require "perplexity_api/version"
require "perplexity_api/configuration"
require "perplexity_api/client"

module PerplexityApi
  class Error < StandardError; end
  
  # Helper method to create a client instance
  def self.new(api_key: nil, model: nil, options: {})
    Client.new(api_key: api_key, model: model, options: options)
  end
  
  # Helper method to directly send a message
  def self.chat(message, api_key: nil, model: nil, options: {})
    client = Client.new(api_key: api_key, model: model, options: options)
    client.chat(message)
  end
  
  # Helper method to get available models
  def self.models(api_key: nil)
    client = Client.new(api_key: api_key)
    client.models
  end
  
  # Helper method to explicitly load .env file
  def self.load_env(debug_mode: false)
    load_dotenv(debug_mode: debug_mode)
  end
end
