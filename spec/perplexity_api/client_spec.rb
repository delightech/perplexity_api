require 'spec_helper'

RSpec.describe PerplexityApi::Client do
  let(:api_key) { "test-api-key" }
  let(:model) { "test-model" }
  let(:options) { { temperature: 0.5, max_tokens: 500 } }
  
  describe "#initialize" do
    context "with no parameters" do
      it "uses default configuration" do
        PerplexityApi.configure do |config|
          config.api_key = "default-api-key"
          config.default_model = "default-model"
        end
        
        client = described_class.new
        expect(client.config.api_key).to eq("default-api-key")
        expect(client.instance_variable_get(:@model)).to eq("default-model")
      end
    end
    
    context "with custom parameters" do
      it "overrides default configuration" do
        client = described_class.new(
          api_key: api_key,
          model: model,
          options: options
        )
        
        expect(client.config.api_key).to eq(api_key)
        expect(client.instance_variable_get(:@model)).to eq(model)
        expect(client.instance_variable_get(:@options)[:temperature]).to eq(options[:temperature])
      end
    end
  end
  
  describe "#chat" do
    let(:client) { described_class.new(api_key: api_key) }
    let(:message) { "Hello, Perplexity!" }
    let(:expected_body) do
      {
        model: client.instance_variable_get(:@model),
        messages: [{ role: "user", content: message }],
        temperature: client.instance_variable_get(:@options)[:temperature],
        max_tokens: client.instance_variable_get(:@options)[:max_tokens],
        top_p: client.instance_variable_get(:@options)[:top_p],
        top_k: client.instance_variable_get(:@options)[:top_k]
      }
    end
    
    let(:mock_response) { double("response", code: "200", body: '{"id":"test-id","choices":[{"message":{"content":"Test response"}}]}') }
    
    before do
      allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_response)
    end
    
    it "sends a request to the Perplexity API" do
      expect_any_instance_of(Net::HTTP::Post).to receive(:body=).with(expected_body.to_json)
      client.chat(message)
    end
    
    it "returns the parsed response" do
      response = client.chat(message)
      expect(response).to be_a(Hash)
      expect(response["id"]).to eq("test-id")
      expect(response["choices"][0]["message"]["content"]).to eq("Test response")
    end
    
    context "when API key is not set" do
      let(:client) { described_class.new(api_key: nil) }
      
      it "raises an error" do
        expect { client.chat(message) }.to raise_error(PerplexityApi::Error, "API key is not set.")
      end
    end
    
    context "when API returns an error" do
      let(:mock_response) { double("response", code: "401", body: '{"error":"Invalid API key"}') }
      
      it "raises an error with the response details" do
        expect { client.chat(message) }.to raise_error(PerplexityApi::Error, /API call failed/)
      end
    end
  end
  
  describe "#models" do
    let(:client) { described_class.new(api_key: api_key) }
    let(:mock_response) { double("response", code: "200", body: '{"data":[{"id":"model1"},{"id":"model2"}]}') }
    
    before do
      allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_response)
    end
    
    it "sends a request to the Perplexity API models endpoint" do
      expect_any_instance_of(Net::HTTP::Get).to receive(:[]=).with("Authorization", "Bearer #{api_key}")
      client.models
    end
    
    it "returns the parsed response" do
      response = client.models
      expect(response).to be_a(Hash)
      expect(response["data"]).to be_an(Array)
      expect(response["data"][0]["id"]).to eq("model1")
    end
  end
end