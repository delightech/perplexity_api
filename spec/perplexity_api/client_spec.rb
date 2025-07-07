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
    let(:messages_array) { [{ role: "user", content: message }] }
    let(:expected_body) do
      {
        model: client.instance_variable_get(:@model),
        messages: [{ role: "user", content: message }],
        temperature: client.instance_variable_get(:@options)[:temperature],
        max_tokens: client.instance_variable_get(:@options)[:max_tokens],
        top_p: client.instance_variable_get(:@options)[:top_p],
        top_k: client.instance_variable_get(:@options)[:top_k],
        frequency_penalty: client.instance_variable_get(:@options)[:frequency_penalty],
        presence_penalty: client.instance_variable_get(:@options)[:presence_penalty]
      }.compact
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
    
    context "with messages array" do
      it "accepts an array of messages" do
        response = client.chat(messages_array)
        expect(response).to be_a(Hash)
      end
    end
    
    context "with search options" do
      let(:search_options) do
        {
          search_mode: "web",
          search_domain_filter: ["wikipedia.org", "-reddit.com"],
          search_recency_filter: "week",
          return_images: true,
          return_related_questions: true
        }
      end
      
      it "includes search parameters in request" do
        expected_search_body = expected_body.merge(search_options)
        expect_any_instance_of(Net::HTTP::Post).to receive(:body=) do |instance, body|
          parsed_body = JSON.parse(body)
          expect(parsed_body["search_mode"]).to eq("web")
          expect(parsed_body["search_domain_filter"]).to eq(["wikipedia.org", "-reddit.com"])
        end
        client.chat(message, search_options)
      end
    end
    
    context "with advanced search filters" do
      let(:advanced_options) do
        {
          search_after_date_filter: "01/01/2024",
          search_before_date_filter: "12/31/2024",
          web_search_options: {
            search_context_size: "high",
            user_location: {
              country: "US",
              latitude: 37.7749,
              longitude: -122.4194
            }
          }
        }
      end
      
      it "includes advanced search parameters" do
        expect_any_instance_of(Net::HTTP::Post).to receive(:body=) do |instance, body|
          parsed_body = JSON.parse(body)
          expect(parsed_body["search_after_date_filter"]).to eq("01/01/2024")
          expect(parsed_body["web_search_options"]["search_context_size"]).to eq("high")
        end
        client.chat(message, advanced_options)
      end
    end
  end
end