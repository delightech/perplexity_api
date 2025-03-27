require 'spec_helper'

RSpec.describe PerplexityApi::Configuration do
  let(:configuration) { described_class.new }
  
  describe "#initialize" do
    it "sets default values" do
      expect(configuration.api_key).to be_nil
      expect(configuration.api_base).to eq("https://api.perplexity.ai")
      expect(configuration.default_model).to eq("claude-3.5-sonnet")
      expect(configuration.default_options).to include(
        temperature: 0.7,
        max_tokens: 1024,
        top_p: 0.9,
        top_k: 0
      )
    end
  end
  
  describe "#validate!" do
    context "when api_key is not set" do
      it "raises an error" do
        expect { configuration.validate! }.to raise_error(PerplexityApi::Error, "API key is not set.")
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