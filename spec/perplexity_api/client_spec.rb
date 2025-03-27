require 'spec_helper'

RSpec.describe PerplexityApi::Client do
  let(:api_key) { ENV["PERPLEXITY_API_KEY"] }
  let(:model) { "sonar" }
  let(:options) { { temperature: 0.5, max_tokens: 500 } }
  
  describe "#initialize" do
    context "with no parameters" do
      before do
        # 環境変数が正しく設定されていることを確認
        @original_api_key = ENV["PERPLEXITY_API_KEY"]
        # 明示的に Configuration をリセット
        allow(PerplexityApi).to receive(:configuration).and_call_original
        PerplexityApi.instance_variable_set(:@configuration, nil)
      end
      
      after do
        # テスト後に元の状態に戻す
        PerplexityApi.instance_variable_set(:@configuration, nil)
      end
      
      it "uses default configuration" do
        client = described_class.new
        expect(client.config.api_key).to eq(@original_api_key)
        expect(client.instance_variable_get(:@model)).to eq("sonar")
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
      before do
        # 環境変数を一時的に保存
        @original_api_key = ENV["PERPLEXITY_API_KEY"]
        # 環境変数を削除
        ENV.delete("PERPLEXITY_API_KEY")
        # グローバル設定をリセット
        allow(PerplexityApi).to receive(:configuration).and_call_original
        # 明示的に新しいConfigurationインスタンスを作成し、APIキーをnilに設定
        config = PerplexityApi::Configuration.new
        config.api_key = nil
        allow(PerplexityApi).to receive(:configuration).and_return(config)
      end
      
      after do
        # テスト後に環境変数を復元
        ENV["PERPLEXITY_API_KEY"] = @original_api_key
        # グローバル設定をリセット
        PerplexityApi.instance_variable_set(:@configuration, nil)
      end
      
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
end