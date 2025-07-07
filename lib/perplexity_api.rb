require "perplexity_api/version"
require "perplexity_api/configuration"
require "perplexity_api/models"
require "perplexity_api/client"
require "perplexity_api/stream_client"

module PerplexityApi
  class Error < StandardError; end
  
  # Helper method to create a client instance
  def self.new(api_key: nil, model: nil, options: {})
    Client.new(api_key: api_key, model: model, options: options)
  end
  
  # Helper method to directly send a message
  def self.chat(messages, api_key: nil, model: nil, options: {})
    client = Client.new(api_key: api_key, model: model, options: options)
    client.chat(messages, options)
  end
  
  # Helper method to create a stream client instance
  def self.stream(api_key: nil, model: nil, options: {})
    StreamClient.new(api_key: api_key, model: model, options: options)
  end
  
  # Helper method to directly stream a message
  def self.stream_chat(messages, api_key: nil, model: nil, options: {}, &block)
    client = StreamClient.new(api_key: api_key, model: model, options: options)
    client.chat(messages, &block)
  end
  
  # Helper method to get available models
  def self.models(api_key: nil)
    client = Client.new(api_key: api_key)
    client.models
  end
end
