RSpec.describe PerplexityApi do
  it "has a version number" do
    expect(PerplexityApi::VERSION).not_to be nil
  end

  describe ".configure" do
    after do
      # Reset configuration after test
      PerplexityApi.configure do |config|
        config.api_key = nil
        config.api_base = "https://api.perplexity.ai"
        config.default_model = "sonar"
        config.default_options = {
          temperature: 0.7,
          max_tokens: 1024,
          top_p: 0.9,
          top_k: 0
        }
      end
    end

    it "allows setting configuration options" do
      test_api_key = "test-api-key-#{Time.now.to_i}"
      PerplexityApi.configure do |config|
        config.api_key = test_api_key
        config.default_model = "test-model"
        config.default_options = { temperature: 0.5 }
      end

      config = PerplexityApi.configuration
      expect(config.api_key).to eq(test_api_key)
      expect(config.default_model).to eq("test-model")
      expect(config.default_options[:temperature]).to eq(0.5)
    end
  end

  describe ".new" do
    it "creates a new client instance" do
      client = PerplexityApi.new
      expect(client).to be_a(PerplexityApi::Client)
    end

    it "accepts api_key, model, and options parameters" do
      custom_api_key = "custom-api-key-#{Time.now.to_i}"
      client = PerplexityApi.new(
        api_key: custom_api_key,
        model: "custom-model",
        options: { temperature: 0.3 }
      )
      
      expect(client.config.api_key).to eq(custom_api_key)
      expect(client.instance_variable_get(:@model)).to eq("custom-model")
      expect(client.instance_variable_get(:@options)[:temperature]).to eq(0.3)
    end
  end

  describe ".load_env" do
    before do
      allow(PerplexityApi).to receive(:load_dotenv)
    end
    
    it "calls load_dotenv with the provided debug_mode" do
      expect(PerplexityApi).to receive(:load_dotenv).with(debug_mode: true)
      PerplexityApi.load_env(debug_mode: true)
    end
    
    it "calls load_dotenv with default debug_mode when not provided" do
      expect(PerplexityApi).to receive(:load_dotenv).with(debug_mode: false)
      PerplexityApi.load_env
    end
  end

  describe "API methods" do
    let(:mock_client) { instance_double(PerplexityApi::Client) }
    
    before do
      allow(PerplexityApi::Client).to receive(:new).and_return(mock_client)
    end

    describe ".chat" do
      it "delegates to client.chat" do
        expect(mock_client).to receive(:chat).with("Hello")
        PerplexityApi.chat("Hello")
      end
    end
  end
end
