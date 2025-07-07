require 'perplexity_api'

# Basic streaming
puts "=== Basic Streaming ==="
PerplexityApi.stream_chat("Write a haiku about programming") do |chunk|
  if chunk["choices"] && chunk["choices"][0]["delta"]["content"]
    print chunk["choices"][0]["delta"]["content"]
  end
end
puts "\n"

# Streaming with web search
puts "\n=== Streaming with Web Search ==="
client = PerplexityApi.stream(
  options: {
    search_mode: "web",
    search_recency_filter: "day"
  }
)

client.chat("What happened in tech news today?") do |chunk|
  if chunk["choices"] && chunk["choices"][0]["delta"]["content"]
    print chunk["choices"][0]["delta"]["content"]
  end
end
puts "\n"