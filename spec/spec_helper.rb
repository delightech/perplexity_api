require "bundler/setup"
# テスト用の環境変数を設定
ENV["PERPLEXITY_API_KEY"] ||= "test-api-key"
ENV["PERPLEXITY_DEFAULT_MODEL"] ||= "sonar"
require "perplexity_api"

# デバッグモードを無効化
PerplexityApi.configure do |config|
  config.debug_mode = false
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
