require 'net/http'
require 'uri'
require 'json'

module PerplexityApi
  class Client
    include RequestBuilder
    attr_reader :config

    def initialize(api_key: nil, model: nil, options: {})
      @config = PerplexityApi.configuration.dup
      @config.api_key = api_key if api_key != nil
      @model = model || @config.default_model
      @options = @config.default_options.merge(options)
      @connection_pool = ConnectionPool.new
    end

    # Method to send a message and get a response
    def chat(messages, options = {})
      @config.validate!
      
      messages = prepare_messages(messages)
      merged_options = @options.merge(options)
      
      uri = URI.parse("#{@config.api_base}/chat/completions")
      http = @connection_pool.get_connection(uri)

      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@config.api_key}"

      request_body = build_request_body(messages, merged_options)
      begin
        request.body = request_body.to_json
      rescue JSON::GeneratorError => e
        # Log the JSON generation error for debugging
        @config.debug_log("JSON generation error for request: #{e.message}")
        raise Error, "Failed to serialize request body to JSON: #{e.message}"
      end

      response = http.request(request)
      
      # Return connection to pool for reuse
      @connection_pool.return_connection(uri, http)
      
      if response.code.to_i == PerplexityApi::HTTP_STATUS_OK
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError => e
          # Log the JSON parsing error for debugging
          @config.debug_log("JSON parsing error in response: #{e.message}")
          @config.debug_log("Response body length: #{response.body.length}")
          @config.debug_log("Response body preview: #{response.body[0...200]}")
          raise Error, "Failed to parse API response as JSON: #{e.message}"
        end
      else
        # Safely redact sensitive information from error messages
        safe_error_message = @config.safe_redact(response.body)
        raise Error, "API call failed: #{response.code} #{safe_error_message}"
      end
    end

    private
  end
end