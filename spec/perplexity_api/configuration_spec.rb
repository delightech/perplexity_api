require 'spec_helper'

RSpec.describe PerplexityApi::Configuration do
  let(:configuration) { described_class.new }
  
  describe "#initialize" do
    context "when environment variables are not set" do
      before do
        @original_env = ENV.to_hash
        ENV.delete("PERPLEXITY_API_KEY")
        ENV.delete("PERPLEXITY_API_BASE")
        ENV.delete("PERPLEXITY_DEFAULT_MODEL")
        ENV.delete("PERPLEXITY_TEMPERATURE")
        ENV.delete("PERPLEXITY_MAX_TOKENS")
        ENV.delete("PERPLEXITY_TOP_P")
        ENV.delete("PERPLEXITY_TOP_K")
      end
      
      after do
        ENV.clear
        @original_env.each { |k, v| ENV[k] = v }
      end
      
      it "sets default values" do
        new_config = described_class.new
        expect(new_config.api_key).to be_nil
        expect(new_config.api_base).to eq("https://api.perplexity.ai")
        expect(new_config.default_model).to eq("sonar")
        expect(new_config.default_options).to include(
          temperature: 0.7,
          max_tokens: 1024,
          top_p: 0.9,
          top_k: 0
        )
      end
    end
    
    context "when environment variables are set" do
      before do
        @original_env = ENV.to_hash
        ENV["PERPLEXITY_API_KEY"] = "env-api-key"
        ENV["PERPLEXITY_API_BASE"] = "https://env-api.example.com"
        ENV["PERPLEXITY_DEFAULT_MODEL"] = "env-model"
        ENV["PERPLEXITY_TEMPERATURE"] = "0.4"
        ENV["PERPLEXITY_MAX_TOKENS"] = "2000"
        ENV["PERPLEXITY_TOP_P"] = "0.8"
        ENV["PERPLEXITY_TOP_K"] = "5"
      end
      
      after do
        ENV.clear
        @original_env.each { |k, v| ENV[k] = v }
      end
      
      it "uses environment variables" do
        new_config = described_class.new
        expect(new_config.api_key).to eq("env-api-key")
        expect(new_config.api_base).to eq("https://env-api.example.com")
        expect(new_config.default_model).to eq("env-model")
        expect(new_config.default_options).to include(
          temperature: 0.4,
          max_tokens: 2000,
          top_p: 0.8,
          top_k: 5
        )
      end
    end
  end
  
  describe "#validate!" do
    context "when api_key is not set" do
      it "raises an error" do
        # 明示的に API キーを nil に設定
        config = described_class.new
        config.api_key = nil
        expect { config.validate! }.to raise_error(PerplexityApi::Error, "API key is not set.")
      end
    end
    
    context "when api_key is set" do
      it "does not raise an error" do
        configuration.api_key = "test-api-key"
        expect { configuration.validate! }.not_to raise_error
      end
    end
  end
end

RSpec.describe PerplexityApi do
  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(PerplexityApi.configuration).to be_a(PerplexityApi::Configuration)
    end
    
    it "memoizes the configuration" do
      config1 = PerplexityApi.configuration
      config2 = PerplexityApi.configuration
      expect(config1).to be(config2)
    end
  end
  
  describe ".configure" do
    after do
      # Reset configuration after test
      PerplexityApi.configure do |config|
        config.api_key = nil
        config.api_base = "https://api.perplexity.ai"
        config.default_model = "claude-3.5-sonnet"
        config.default_options = {
          temperature: 0.7,
          max_tokens: 1024,
          top_p: 0.9,
          top_k: 0
        }
      end
    end
    
    it "yields the configuration to the block" do
      expect { |b| PerplexityApi.configure(&b) }.to yield_with_args(PerplexityApi.configuration)
    end
    
    it "allows setting configuration values" do
      PerplexityApi.configure do |config|
        config.api_key = "new-api-key"
        config.api_base = "https://custom-api.example.com"
        config.default_model = "custom-model"
        config.default_options = { temperature: 0.3 }
      end
      
      config = PerplexityApi.configuration
      expect(config.api_key).to eq("new-api-key")
      expect(config.api_base).to eq("https://custom-api.example.com")
      expect(config.default_model).to eq("custom-model")
      expect(config.default_options[:temperature]).to eq(0.3)
    end
  end
end