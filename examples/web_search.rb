require 'perplexity_api'

# Web search with domain filtering
puts "=== Web Search with Domain Filtering ==="
response = PerplexityApi.chat(
  "What are the latest AI research papers?",
  options: {
    search_mode: "web",
    search_domain_filter: ["arxiv.org", "openai.com", "-reddit.com"],
    search_recency_filter: "week"
  }
)
puts response["choices"][0]["message"]["content"]
puts

# Academic search
puts "=== Academic Search ==="
response = PerplexityApi.chat(
  "Find recent studies on climate change mitigation",
  options: {
    search_mode: "academic",
    search_after_date_filter: "01/01/2024",
    search_before_date_filter: "12/31/2024"
  }
)
puts response["choices"][0]["message"]["content"]
puts

# Location-based search
puts "=== Location-based Search ==="
response = PerplexityApi.chat(
  "What are the best restaurants near me?",
  options: {
    search_mode: "web",
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
puts response["choices"][0]["message"]["content"]