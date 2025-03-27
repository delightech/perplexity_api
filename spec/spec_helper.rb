require "bundler/setup"
require "dotenv"
# テスト用の環境変数を読み込む
Dotenv.load(File.expand_path("../.env.test", __dir__))
require "perplexity_api"

# テスト実行前に環境変数が正しく読み込まれていることを確認
puts "PERPLEXITY_API_KEY: #{ENV['PERPLEXITY_API_KEY']}"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
