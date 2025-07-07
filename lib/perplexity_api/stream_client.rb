require 'net/http'
require 'uri'
require 'json'

module PerplexityApi
  class StreamClient
    attr_reader :config

    def initialize(api_key: nil, model: nil, options: {})
      @config = PerplexityApi.configuration.dup
      @config.api_key = api_key if api_key != nil
      @model = model || @config.default_model
      @options = @config.default_options.merge(options)
    end

    def chat(messages, &block)
      @config.validate!
      
      messages = prepare_messages(messages)
      
      uri = URI.parse("#{@config.api_base}/chat/completions")
      
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(uri.path)
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{@config.api_key}"
        request["Accept"] = "text/event-stream"
        request["Cache-Control"] = "no-cache"
        
        request_body = build_request_body(messages)
        request_body[:stream] = true
        request.body = request_body.to_json

        http.request(request) do |response|
          if response.code.to_i != 200
            raise Error, "API call failed: #{response.code} #{response.read_body}"
          end

          buffer = ""
          response.read_body do |chunk|
            buffer += chunk
            
            while (line_end = buffer.index("\n"))
              line = buffer[0...line_end]
              buffer = buffer[(line_end + 1)..-1]
              
              next if line.strip.empty?
              next unless line.start_with?("data: ")
              
              data = line[6..-1].strip
              next if data == "[DONE]"
              
              begin
                parsed = JSON.parse(data)
                block.call(parsed) if block_given?
              rescue JSON::ParserError => e
                # Skip invalid JSON
              end
            end
          end
        end
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

    def build_request_body(messages)
      body = {
        model: @model,
        messages: messages
      }

      # Basic parameters
      body[:temperature] = @options[:temperature] if @options[:temperature]
      body[:max_tokens] = @options[:max_tokens] if @options[:max_tokens]
      body[:top_p] = @options[:top_p] if @options[:top_p]
      body[:top_k] = @options[:top_k] if @options[:top_k]
      body[:frequency_penalty] = @options[:frequency_penalty] if @options[:frequency_penalty]
      body[:presence_penalty] = @options[:presence_penalty] if @options[:presence_penalty]

      # Search parameters
      body[:search_mode] = @options[:search_mode] if @options[:search_mode]
      body[:search_domain_filter] = @options[:search_domain_filter] if @options[:search_domain_filter]
      body[:search_recency_filter] = @options[:search_recency_filter] if @options[:search_recency_filter]
      body[:search_after_date_filter] = @options[:search_after_date_filter] if @options[:search_after_date_filter]
      body[:search_before_date_filter] = @options[:search_before_date_filter] if @options[:search_before_date_filter]
      body[:last_updated_after_filter] = @options[:last_updated_after_filter] if @options[:last_updated_after_filter]
      body[:last_updated_before_filter] = @options[:last_updated_before_filter] if @options[:last_updated_before_filter]

      # Beta features
      body[:return_images] = @options[:return_images] if @options[:return_images]
      body[:return_related_questions] = @options[:return_related_questions] if @options[:return_related_questions]

      # Advanced features
      body[:reasoning_effort] = @options[:reasoning_effort] if @options[:reasoning_effort]
      
      if @options[:web_search_options]
        body[:web_search_options] = @options[:web_search_options]
      end

      body
    end
  end
end