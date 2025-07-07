require 'perplexity_api'

# Basic chat
puts "=== Basic Chat ==="
response = PerplexityApi.chat("What is Ruby programming language?")
puts response["choices"][0]["message"]["content"]
puts

# Chat with options
puts "=== Chat with Custom Options ==="
response = PerplexityApi.chat(
  "Tell me about the benefits of Ruby",
  options: {
    temperature: 0.3,
    max_tokens: 500
  }
)
puts response["choices"][0]["message"]["content"]
puts

# Using specific model
puts "=== Using Sonar Pro Model ==="
client = PerplexityApi.new(model: PerplexityApi::Models::SONAR_PRO)
response = client.chat("What are the latest features in Ruby 3.3?")
puts response["choices"][0]["message"]["content"]