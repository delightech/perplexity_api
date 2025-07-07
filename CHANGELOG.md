# Changelog

All notable changes to this project will be documented in this file.

## [0.3.0] - 2025-01-07

### Added
- Streaming support via `StreamClient` class for real-time responses
- Web search capabilities with `search_mode` parameter (web/academic)
- Domain filtering with `search_domain_filter` (include/exclude domains)
- Date filtering with `search_after_date_filter` and `search_before_date_filter`
- Recency filtering with `search_recency_filter` (month/week/day/hour)
- Location-based search with `web_search_options`
- Support for new models: sonar-pro, sonar-deep-research
- Full conversation history support with messages array
- New parameters: `frequency_penalty` and `presence_penalty`
- Beta features: `return_images` and `return_related_questions`
- Model constants in `PerplexityApi::Models`
- Helper methods: `stream`, `stream_chat`
- Comprehensive examples directory

### Changed
- `chat` method now accepts both string and array of messages
- `chat` method accepts options parameter for per-request configuration
- Updated default configuration to include new penalty parameters

### Fixed
- Improved error handling for streaming responses

## [0.2.1] - Previous version

### Fixed
- Environment variable loading issues
- Configuration management improvements

## [0.1.0] - Initial release

### Added
- Basic chat functionality
- Configuration management
- Environment variable support
- Basic parameter support (temperature, max_tokens, top_p, top_k)