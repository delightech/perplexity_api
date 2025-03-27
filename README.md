# PerplexityApi

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

To configure the API key:

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
