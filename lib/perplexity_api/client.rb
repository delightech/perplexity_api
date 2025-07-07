require 'net/http'
require 'uri'
require 'json'

module PerplexityApi
  class Client
    attr_reader :config

    def initialize(api_key: nil, model: nil, options: {})
      @config = PerplexityApi.configuration.dup
      @config.api_key = api_key if api_key != nil
      @model = model || @config.default_model
      @options = @config.default_options.merge(options)
    end

    # Method to send a message and get a response
    def chat(messages, options = {})
      @config.validate!
      
      messages = prepare_messages(messages)
      merged_options = @options.merge(options)
      
      uri = URI.parse("#{@config.api_base}/chat/completions")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@config.api_key}"

      request_body = build_request_body(messages, merged_options)
      request.body = request_body.to_json

      response = http.request(request)
      
      if response.code.to_i == 200
        JSON.parse(response.body)
      else
        raise Error, "API call failed: #{response.code} #{response.body}"
      end
    end

    private

    def prepare_messages(messages)
      case messages
      when String
        [{ role: "user", content: messages }]
      when Array
        messages
      else
        raise ArgumentError, "Messages must be a string or array"
      end
    end

    def build_request_body(messages, options)
      body = {
        model: @model,
        messages: messages
      }

      # Basic parameters
      body[:temperature] = options[:temperature] if options[:temperature]
      body[:max_tokens] = options[:max_tokens] if options[:max_tokens]
      body[:top_p] = options[:top_p] if options[:top_p]
      body[:top_k] = options[:top_k] if options[:top_k]
      body[:frequency_penalty] = options[:frequency_penalty] if options[:frequency_penalty]
      body[:presence_penalty] = options[:presence_penalty] if options[:presence_penalty]
      body[:stream] = options[:stream] if options.key?(:stream)

      # Search parameters
      body[:search_mode] = options[:search_mode] if options[:search_mode]
      body[:search_domain_filter] = options[:search_domain_filter] if options[:search_domain_filter]
      body[:search_recency_filter] = options[:search_recency_filter] if options[:search_recency_filter]
      body[:search_after_date_filter] = options[:search_after_date_filter] if options[:search_after_date_filter]
      body[:search_before_date_filter] = options[:search_before_date_filter] if options[:search_before_date_filter]
      body[:last_updated_after_filter] = options[:last_updated_after_filter] if options[:last_updated_after_filter]
      body[:last_updated_before_filter] = options[:last_updated_before_filter] if options[:last_updated_before_filter]

      # Beta features
      body[:return_images] = options[:return_images] if options[:return_images]
      body[:return_related_questions] = options[:return_related_questions] if options[:return_related_questions]

      # Advanced features
      body[:reasoning_effort] = options[:reasoning_effort] if options[:reasoning_effort]
      
      if options[:web_search_options]
        body[:web_search_options] = options[:web_search_options]
      end

      body
    end
  end
end