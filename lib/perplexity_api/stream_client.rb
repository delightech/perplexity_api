require 'net/http'
require 'uri'
require 'json'
require 'stringio'

module PerplexityApi
  class StreamClient
    include RequestBuilder
    attr_reader :config

    def initialize(api_key: nil, model: nil, options: {})
      @config = PerplexityApi.configuration.dup
      @config.api_key = api_key if api_key != nil
      @model = model || @config.default_model
      @options = @config.default_options.merge(options)
      @connection_pool = ConnectionPool.new(max_connections: 2, timeout: 10) # Fewer connections for streaming
    end

    def chat(messages, &block)
      @config.validate!
      
      messages = prepare_messages(messages)
      
      uri = URI.parse("#{@config.api_base}/chat/completions")
      http = @connection_pool.get_connection(uri)
      
      begin
        request = Net::HTTP::Post.new(uri.path)
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{@config.api_key}"
        request["Accept"] = "text/event-stream"
        request["Cache-Control"] = "no-cache"
        
        request_body = build_request_body(messages, @options)
        request_body[:stream] = true
        begin
          request.body = request_body.to_json
        rescue JSON::GeneratorError => e
          # Log the JSON generation error for debugging
          @config.debug_log("JSON generation error for request: #{e.message}")
          raise Error, "Failed to serialize request body to JSON: #{e.message}"
        end

        http.request(request) do |response|
          if response.code.to_i != PerplexityApi::HTTP_STATUS_OK
            # Safely redact sensitive information from error messages
            error_body = response.read_body
            safe_error_message = @config.safe_redact(error_body)
            raise Error, "API call failed: #{response.code} #{safe_error_message}"
          end

          buffer = StringIO.new
          max_buffer_size = 10 * 1024 * 1024  # 10MB limit
          
          response.read_body do |chunk|
            # Check for buffer size limit before adding chunk
            if buffer.size + chunk.bytesize > max_buffer_size
              raise Error, "Stream buffer exceeded maximum size (#{max_buffer_size} bytes). Stream may be malformed."
            end
            
            buffer.write(chunk)
            
            begin
              # Process complete lines more efficiently
              buffer.rewind
              content = buffer.read
              
              # Find all complete lines
              lines = content.split("\n")
              
              # Keep the last incomplete line in the buffer
              if content.end_with?("\n")
                buffer = StringIO.new
                incomplete_line = ""
              else
                incomplete_line = lines.pop || ""
                buffer = StringIO.new
                buffer.write(incomplete_line)
              end
              
              # Process complete lines
              lines.each do |line|
                next if line.strip.empty?
                next unless line.start_with?("data: ")
                
                data = line[6..-1].strip
                next if data == "[DONE]"
                
                begin
                  parsed = JSON.parse(data)
                  block.call(parsed) if block_given?
                rescue JSON::ParserError => e
                  # Skip invalid JSON but log the error for debugging
                  @config.debug_log("JSON parsing error in stream: #{e.message}")
                end
              end
            rescue => e
              # Clear buffer on processing error to prevent accumulation
              buffer = StringIO.new
              raise Error, "Stream processing error: #{e.message}"
            end
          end
          
          # Final cleanup - ensure buffer is cleared
          buffer = StringIO.new
        end
      ensure
        # Return connection to pool for reuse
        @connection_pool.return_connection(uri, http) if http
      end
    end

    private
  end
end