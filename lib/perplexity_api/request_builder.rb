module PerplexityApi
  module RequestBuilder
    
    def prepare_messages(messages)
      case messages
      when String
        validate_message_content(messages)
        [{ role: "user", content: messages }]
      when Array
        validate_message_array(messages)
        messages
      else
        raise ArgumentError, "Messages must be a string or array"
      end
    end
    
    def validate_message_content(content)
      raise ArgumentError, "Message content cannot be nil" if content.nil?
      raise ArgumentError, "Message content cannot be empty" if content.strip.empty?
      raise ArgumentError, "Message content too long" if content.length > 100000 # 100KB limit
    end
    
    def validate_message_array(messages)
      raise ArgumentError, "Messages array cannot be empty" if messages.empty?
      raise ArgumentError, "Messages array too large" if messages.length > 100 # Reasonable limit
      
      messages.each_with_index do |message, index|
        raise ArgumentError, "Message #{index} must be a hash" unless message.is_a?(Hash)
        raise ArgumentError, "Message #{index} must have a 'role' field" unless message.key?(:role) || message.key?("role")
        raise ArgumentError, "Message #{index} must have a 'content' field" unless message.key?(:content) || message.key?("content")
        
        role = message[:role] || message["role"]
        content = message[:content] || message["content"]
        
        raise ArgumentError, "Message #{index} role must be 'user', 'assistant', or 'system'" unless %w[user assistant system].include?(role.to_s)
        
        validate_message_content(content.to_s)
      end
    end

    def build_request_body(messages, options = {})
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