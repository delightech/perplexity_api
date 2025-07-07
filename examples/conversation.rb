require 'perplexity_api'

# Multi-turn conversation
puts "=== Multi-turn Conversation ==="

messages = [
  { role: "system", content: "You are a helpful Ruby programming expert." },
  { role: "user", content: "What is a Ruby gem?" }
]

# First response
response = PerplexityApi.chat(messages)
assistant_message = response["choices"][0]["message"]["content"]
puts "User: What is a Ruby gem?"
puts "Assistant: #{assistant_message}"
puts

# Add assistant response to conversation
messages << { role: "assistant", content: assistant_message }
messages << { role: "user", content: "How do I create my own gem?" }

# Second response
response = PerplexityApi.chat(messages)
puts "User: How do I create my own gem?"
puts "Assistant: #{response["choices"][0]["message"]["content"]}"
puts

# Continue the conversation
messages << { role: "assistant", content: response["choices"][0]["message"]["content"] }
messages << { role: "user", content: "What about publishing it to RubyGems?" }

response = PerplexityApi.chat(messages)
puts "User: What about publishing it to RubyGems?"
puts "Assistant: #{response["choices"][0]["message"]["content"]}"