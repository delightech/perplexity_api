require "bundler/setup"
require "dotenv"
# テスト用の環境変数を読み込む
test_env_file = File.expand_path("../.env.test", __dir__)
Dotenv.load(test_env_file) if File.exist?(test_env_file)
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
