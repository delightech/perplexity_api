# Changelog

All notable changes to this project will be documented in this file.

## [0.5.0] - 2025-01-19

### Added
- Flexible timeout configuration for API calls
  - Explicit timeout via options parameter
  - Environment variable support (`PERPLEXITY_TIMEOUT`)
  - Global configuration via `config.default_timeout`
- Intelligent timeout defaults based on operation type
  - Web search: 60s (streaming: 120s)
  - Deep research (`reasoning_effort: 'high'`): 300s (streaming: 600s)
  - Regular queries: 30s (streaming: 60s)
- Connection pooling for improved performance
- HTTP connection reuse reduces latency by ~25%

### Security
- API key protection with safe_redact method
- Input validation with message size limits (100KB per message)
- Message array size limit (max 100 messages)
- Streaming buffer management with 10MB limit

### Improved
- Error handling with detailed JSON parsing errors
- Debug logging with automatic sensitive data redaction
- Code quality improvements with RequestBuilder module
- HTTP status codes as named constants

### Fixed
- Timeout errors for long-running operations (web search, deep research)
- Memory efficiency in streaming with StringIO buffer
- Connection pool cleanup for expired connections

## [0.4.1] - 2025-01-07

### Fixed
- Corrected homepage and source code URLs in gemspec

## [0.4.0] - 2025-01-07

### Changed
- **BREAKING**: Minimum Ruby version requirement updated from 2.6.0 to 3.1.0
- Updated development dependencies:
  - Bundler from ~> 1.17 to ~> 2.0
  - Rake from ~> 10.0 to ~> 13.0

### Tested
- Verified compatibility with Ruby 3.4.4
- All 42 tests passing on Ruby 3.1.0+

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
