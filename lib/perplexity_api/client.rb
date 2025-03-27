require 'net/http'
require 'uri'
require 'json'

module PerplexityApi
  class Client
    attr_reader :config

    def initialize(api_key: nil, model: nil, options: {})
      @config = PerplexityApi.configuration.dup
      @config.api_key = api_key if api_key
      @model = model || @config.default_model
      @options = @config.default_options.merge(options)
    end

    # Method to send a message and get a response
    def chat(message)
      @config.validate!
      
      uri = URI.parse("#{@config.api_base}/chat/completions")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@config.api_key}"

      request.body = {
        model: @model,
        messages: [{ role: "user", content: message }],
        temperature: @options[:temperature],
        max_tokens: @options[:max_tokens],
        top_p: @options[:top_p],
        top_k: @options[:top_k]
      }.to_json

      response = http.request(request)
      
      if response.code.to_i == 200
        JSON.parse(response.body)
      else
        raise Error, "API call failed: #{response.code} #{response.body}"
      end
    end
  end
end