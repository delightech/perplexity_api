# PerplexityApi
[![Gem Version](https://badge.fury.io/rb/perplexity_api.svg?v=0.5.0)](https://badge.fury.io/rb/perplexity_api)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

A Ruby wrapper gem for Perplexity AI's API. This gem allows you to easily integrate Perplexity AI's powerful language models into your Ruby applications.

## Features

- API key can be configured externally
- Support for all latest Perplexity models including sonar-pro and sonar-deep-research
- Simple interface to send messages and get results
- Streaming support for real-time responses
- Web search capabilities with domain filtering and date filters
- Conversation history support with full messages array
- Advanced search features including location-based search
- Beta features: image results and related questions
- Options can be customized or use defaults

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'perplexity_api'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install perplexity_api
```

## Usage

### Configuration

There are multiple ways to configure the API key:

#### 1. Using Environment Variables (Recommended)

The gem will automatically look for environment variables:

```
PERPLEXITY_API_KEY=your-api-key-here
```

A sample `.env.sample` file is included in the repository as a template for the environment variables you can use:

```
PERPLEXITY_API_KEY=your-api-key-here
PERPLEXITY_DEFAULT_MODEL=sonar
PERPLEXITY_TEMPERATURE=0.5
PERPLEXITY_MAX_TOKENS=2048
PERPLEXITY_TOP_P=0.9
PERPLEXITY_TOP_K=0
```

You can set these environment variables in your application's environment or use a method of your choice to load them from a `.env` file.

```ruby
# After setting environment variables, use the PerplexityApi gem
require 'perplexity_api'
```

#### 2. Using Ruby Configuration

To configure the API key in your code:

```ruby
PerplexityApi.configure do |config|
  config.api_key = "your-api-key"
  # Optionally change other settings
  # config.default_model = "sonar"
  # config.default_options = { temperature: 0.5, max_tokens: 2048 }
end
```

### Basic Usage

The simplest way to send a message and get a response:

```ruby
response = PerplexityApi.chat("Hello, Perplexity AI!")
puts response["choices"][0]["message"]["content"]
```

### Conversation History

You can maintain conversation context by passing an array of messages:

```ruby
messages = [
  { role: "system", content: "You are a helpful assistant." },
  { role: "user", content: "What is the capital of France?" },
  { role: "assistant", content: "The capital of France is Paris." },
  { role: "user", content: "What is its population?" }
]

response = PerplexityApi.chat(messages)
```

### Using a Client Instance

For more detailed control, you can create a client instance:

```ruby
client = PerplexityApi.new(
  api_key: "your-api-key",  # Optional if already configured
  model: "sonar",  # Override default model
  options: {
    temperature: 0.5,
    max_tokens: 2048,
    top_p: 0.9,
    top_k: 0,
    frequency_penalty: 0.1,
    presence_penalty: 0.1,
    search_mode: "web"
  }
)

response = client.chat("Enter your complex question here...")
puts response["choices"][0]["message"]["content"]
```

### Streaming Responses

For real-time streaming responses:

```ruby
PerplexityApi.stream_chat("Tell me about Ruby programming") do |chunk|
  print chunk["choices"][0]["delta"]["content"] if chunk["choices"][0]["delta"]["content"]
end
```

Or with a client instance:

```ruby
client = PerplexityApi.stream
client.chat("Explain quantum computing") do |chunk|
  # Process each chunk as it arrives
end
```

### Web Search Features

Enable web search with specific filters:

```ruby
response = PerplexityApi.chat(
  "What are the latest developments in AI?",
  options: {
    search_mode: "web",
    search_domain_filter: ["arxiv.org", "nature.com", "-reddit.com"],
    search_recency_filter: "week"
  }
)
```

### Advanced Search Options

Use date filters and location-based search:

```ruby
response = PerplexityApi.chat(
  "Find research papers on climate change",
  options: {
    search_mode: "academic",
    search_after_date_filter: "01/01/2024",
    search_before_date_filter: "12/31/2024",
    web_search_options: {
      search_context_size: "high",
      user_location: {
        country: "US",
        latitude: 37.7749,
        longitude: -122.4194
      }
    }
  }
)
```

### Beta Features

Enable image results and related questions (closed beta):

```ruby
response = PerplexityApi.chat(
  "Show me images of the Eiffel Tower",
  options: {
    return_images: true,
    return_related_questions: true
  }
)

# Access images if available
if response["images"]
  response["images"].each do |image|
    puts "Image URL: #{image["url"]}"
  end
end

# Access related questions
if response["related_questions"]
  puts "Related questions:"
  response["related_questions"].each { |q| puts "- #{q}" }
end
```

## Models

The gem includes constants for all available models:

```ruby
# Current Sonar Models
PerplexityApi::Models::SONAR              # "sonar"
PerplexityApi::Models::SONAR_PRO          # "sonar-pro"
PerplexityApi::Models::SONAR_DEEP_RESEARCH # "sonar-deep-research"

# Other Models
PerplexityApi::Models::LLAMA_3_1_70B_INSTRUCT  # "llama-3.1-70b-instruct"
PerplexityApi::Models::MISTRAL_7B              # "mistral-7b"
PerplexityApi::Models::CODELLAMA_34B           # "codellama-34b"
```

For the most up-to-date list of models, refer to the [Perplexity AI official documentation](https://docs.perplexity.ai/guides/model-cards).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
