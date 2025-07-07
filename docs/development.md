# Perplexity API Gem Development Documentation

## Overview

This document describes the implementation details of the Perplexity API Ruby gem version 0.3.0, which adds comprehensive support for all Perplexity AI API features.

## Architecture

### Core Components

1. **Client** (`lib/perplexity_api/client.rb`)
   - Main interface for synchronous API calls
   - Handles message formatting and request building
   - Supports both string and array message inputs

2. **StreamClient** (`lib/perplexity_api/stream_client.rb`)
   - Handles Server-Sent Events (SSE) streaming
   - Processes chunked responses in real-time
   - Implements proper error handling for stream interruptions

3. **Configuration** (`lib/perplexity_api/configuration.rb`)
   - Manages API keys and default settings
   - Supports environment variable configuration
   - Provides debug mode for troubleshooting

4. **Models** (`lib/perplexity_api/models.rb`)
   - Constants for all available models
   - Grouped by model family (Sonar, Llama, etc.)
   - Search-related constants

## Implementation Details

### 1. Streaming Support

The streaming implementation uses Server-Sent Events (SSE) protocol:

```ruby
# StreamClient#chat method
def chat(messages, &block)
  # Prepare HTTP request with SSE headers
  request["Accept"] = "text/event-stream"
  request["Cache-Control"] = "no-cache"
  
  # Process streaming response
  response.read_body do |chunk|
    # Parse SSE format: "data: {json}\n"
    # Handle special "[DONE]" marker
    # Yield parsed JSON chunks to block
  end
end
```

Key features:
- Non-blocking chunk processing
- Automatic JSON parsing
- Error recovery for malformed chunks
- Support for all chat parameters

### 2. Web Search Integration

Web search is implemented through additional request parameters:

```ruby
# Search parameters in build_request_body
body[:search_mode] = options[:search_mode] # "web" or "academic"
body[:search_domain_filter] = options[:search_domain_filter] # ["domain.com", "-excluded.com"]
body[:search_recency_filter] = options[:search_recency_filter] # "hour", "day", "week", "month"
```

Advanced search features:
- Date range filtering
- Location-based search
- Domain inclusion/exclusion
- Academic paper search mode

### 3. Message Array Support

The gem now supports full conversation history:

```ruby
def prepare_messages(messages)
  case messages
  when String
    [{ role: "user", content: messages }]
  when Array
    messages # Pass through for multi-turn conversations
  else
    raise ArgumentError, "Messages must be a string or array"
  end
end
```

This enables:
- System prompts
- Multi-turn conversations
- Assistant message history
- Context preservation

### 4. Request Building

The `build_request_body` method constructs API requests with all parameters:

```ruby
def build_request_body(messages, options)
  body = {
    model: @model,
    messages: messages
  }
  
  # Add only non-nil parameters
  body[:temperature] = options[:temperature] if options[:temperature]
  body[:search_mode] = options[:search_mode] if options[:search_mode]
  # ... other parameters
  
  body
end
```

This approach:
- Avoids sending unnecessary null values
- Supports all API parameters
- Maintains backward compatibility

## API Design Decisions

### 1. Backward Compatibility

The gem maintains backward compatibility:
- `chat(string)` still works for simple queries
- New `chat(messages, options)` signature for advanced usage
- Default values preserve existing behavior

### 2. Streaming Interface

Streaming uses Ruby blocks for natural iteration:
```ruby
PerplexityApi.stream_chat("Query") do |chunk|
  print chunk["choices"][0]["delta"]["content"]
end
```

### 3. Configuration Flexibility

Multiple configuration methods:
- Environment variables (recommended)
- Ruby configuration block
- Per-request overrides

### 4. Error Handling

Comprehensive error handling:
- API errors raise `PerplexityApi::Error`
- Streaming errors are caught and re-raised
- Invalid JSON in streams is skipped

## Testing Strategy

### Unit Tests

1. **Client Tests** (`spec/perplexity_api/client_spec.rb`)
   - Request formatting
   - Parameter handling
   - Error scenarios

2. **StreamClient Tests** (`spec/perplexity_api/stream_client_spec.rb`)
   - SSE parsing
   - Chunk processing
   - Error recovery

3. **Configuration Tests** (`spec/perplexity_api/configuration_spec.rb`)
   - Environment variable loading
   - Default values
   - Validation

4. **Model Tests** (`spec/perplexity_api/models_spec.rb`)
   - Constant definitions
   - Model groupings

### Test Patterns

- Mock HTTP responses for predictable testing
- Stub environment variables for configuration tests
- Test both success and failure paths

## New Features in v0.3.0

### 1. Streaming Responses
- Real-time response streaming
- Server-Sent Events support
- Chunked transfer encoding

### 2. Web Search
- Domain filtering (include/exclude)
- Date range filters
- Recency filters (hour/day/week/month)
- Location-based search

### 3. Advanced Models
- sonar-pro: Enhanced capabilities
- sonar-deep-research: In-depth analysis
- All legacy models supported

### 4. Enhanced Parameters
- frequency_penalty: Reduce repetition
- presence_penalty: Encourage topic diversity
- return_images: Get image results (beta)
- return_related_questions: Get follow-up questions (beta)

### 5. Search Modes
- Web search: General internet search
- Academic search: Scholarly articles and papers

## Usage Examples

### Basic Chat
```ruby
response = PerplexityApi.chat("Hello, world!")
```

### Streaming
```ruby
PerplexityApi.stream_chat("Tell me a story") do |chunk|
  print chunk["choices"][0]["delta"]["content"]
end
```

### Web Search
```ruby
response = PerplexityApi.chat(
  "Latest AI news",
  options: {
    search_mode: "web",
    search_recency_filter: "day"
  }
)
```

### Conversation
```ruby
messages = [
  { role: "system", content: "You are a Ruby expert" },
  { role: "user", content: "How do I create a gem?" }
]
response = PerplexityApi.chat(messages)
```

## Environment Variables

The gem supports these environment variables:

```
PERPLEXITY_API_KEY=your-api-key
PERPLEXITY_DEFAULT_MODEL=sonar-pro
PERPLEXITY_TEMPERATURE=0.7
PERPLEXITY_MAX_TOKENS=2048
PERPLEXITY_TOP_P=0.9
PERPLEXITY_TOP_K=0
PERPLEXITY_FREQUENCY_PENALTY=0.0
PERPLEXITY_PRESENCE_PENALTY=0.0
```

## Performance Considerations

1. **Streaming**: Reduces memory usage for large responses
2. **Connection Reuse**: Each request creates new connection (could be optimized)
3. **JSON Parsing**: Uses built-in JSON parser for efficiency
4. **Error Recovery**: Graceful handling prevents connection leaks

## Security Considerations

1. **API Key Storage**: Use environment variables, not hardcoded values
2. **HTTPS Only**: All connections use SSL/TLS
3. **Input Validation**: Messages are validated before sending
4. **No Logging**: Sensitive data is not logged

## Future Enhancements

Potential improvements for future versions:

1. **Connection Pooling**: Reuse HTTP connections
2. **Async Support**: Non-blocking API calls
3. **Rate Limiting**: Built-in rate limit handling
4. **Retry Logic**: Automatic retry with exponential backoff
5. **Response Caching**: Optional response caching
6. **Webhook Support**: If Perplexity adds webhook features

## Contributing

When adding new features:

1. Maintain backward compatibility
2. Add comprehensive tests
3. Update documentation
4. Follow Ruby style guidelines
5. Add examples for new features

## Debugging

Enable debug mode to see configuration details:

```ruby
PerplexityApi.configuration.debug_mode = true
```

This will output:
- Configuration loading details
- API key status (set/not set)
- Default model and parameters

## Release Process

1. Update version in `lib/perplexity_api/version.rb`
2. Update CHANGELOG.md
3. Run tests: `bundle exec rspec`
4. Build gem: `gem build perplexity_api.gemspec`
5. Push to RubyGems: `gem push perplexity_api-x.x.x.gem`

## License

MIT License - See LICENSE.txt for details