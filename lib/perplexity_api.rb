require "perplexity_api/version"
require "perplexity_api/configuration"
require "perplexity_api/models"
require "perplexity_api/request_builder"
require "perplexity_api/connection_pool"
require "perplexity_api/client"
require "perplexity_api/stream_client"

module PerplexityApi
  class Error < StandardError; end
  
  # HTTP Status Code Constants
  HTTP_STATUS_OK = 200
  HTTP_STATUS_BAD_REQUEST = 400
  HTTP_STATUS_UNAUTHORIZED = 401
  HTTP_STATUS_FORBIDDEN = 403
  HTTP_STATUS_NOT_FOUND = 404
  HTTP_STATUS_RATE_LIMITED = 429
  HTTP_STATUS_INTERNAL_SERVER_ERROR = 500
  HTTP_STATUS_BAD_GATEWAY = 502
  HTTP_STATUS_SERVICE_UNAVAILABLE = 503
  
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
