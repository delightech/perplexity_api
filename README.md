# PerplexityApi
[![Gem Version](https://badge.fury.io/rb/perplexity_api.svg)](https://badge.fury.io/rb/perplexity_api)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

A Ruby wrapper gem for Perplexity AI's API. This gem allows you to easily integrate Perplexity AI's powerful language models into your Ruby applications.

## Features

- API key can be configured externally
- Ability to select the latest models
- Simple interface to send messages and get results
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
    top_k: 0
  }
)

response = client.chat("Enter your complex question here...")
puts response["choices"][0]["message"]["content"]
```

## Models

For the most up-to-date list of models, refer to the [Perplexity AI official documentation](https://docs.perplexity.ai/guides/model-cards).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
