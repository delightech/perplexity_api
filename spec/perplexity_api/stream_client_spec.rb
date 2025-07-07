require 'spec_helper'

RSpec.describe PerplexityApi::StreamClient do
  let(:api_key) { ENV["PERPLEXITY_API_KEY"] }
  let(:model) { "sonar" }
  let(:options) { { temperature: 0.5, max_tokens: 500 } }
  let(:client) { described_class.new(api_key: api_key, model: model, options: options) }
  
  describe "#initialize" do
    it "initializes with the provided configuration" do
      expect(client.config.api_key).to eq(api_key)
      expect(client.instance_variable_get(:@model)).to eq(model)
      expect(client.instance_variable_get(:@options)).to include(options)
    end
  end
  
  describe "#chat" do
    let(:message) { "Hello, streaming!" }
    let(:messages_array) { [{ role: "user", content: message }] }
    
    let(:mock_response) do
      double("response", 
        code: "200",
        read_body: nil
      )
    end
    
    before do
      mock_http = double("http")
      allow(mock_http).to receive(:request).and_yield(mock_response)
      allow(Net::HTTP).to receive(:start).and_yield(mock_http)
    end
    
    context "with string message" do
      it "converts string to messages array" do
        chunks = []
        
        allow(mock_response).to receive(:read_body).and_yield("data: {\"choices\":[{\"delta\":{\"content\":\"Hello\"}}]}\n")
        
        client.chat(message) do |chunk|
          chunks << chunk
        end
        
        expect(chunks).not_to be_empty
        expect(chunks.first["choices"][0]["delta"]["content"]).to eq("Hello")
      end
    end
    
    context "with messages array" do
      it "processes streaming response" do
        chunks = []
        
        allow(mock_response).to receive(:read_body)
          .and_yield("data: {\"choices\":[{\"delta\":{\"content\":\"Stream\"}}]}\n")
          .and_yield("data: {\"choices\":[{\"delta\":{\"content\":\" response\"}}]}\n")
          .and_yield("data: [DONE]\n")
        
        client.chat(messages_array) do |chunk|
          chunks << chunk
        end
        
        expect(chunks.length).to eq(2)
        expect(chunks[0]["choices"][0]["delta"]["content"]).to eq("Stream")
        expect(chunks[1]["choices"][0]["delta"]["content"]).to eq(" response")
      end
    end
    
    context "with search options" do
      let(:search_options) do
        {
          search_mode: "academic",
          search_domain_filter: ["arxiv.org"],
          return_images: true
        }
      end
      
      it "includes search parameters in request" do
        expect_any_instance_of(Net::HTTP::Post).to receive(:body=) do |instance, body|
          parsed_body = JSON.parse(body)
          expect(parsed_body["stream"]).to be true
          expect(parsed_body["search_mode"]).to eq("academic")
          expect(parsed_body["search_domain_filter"]).to eq(["arxiv.org"])
        end
        
        allow(mock_response).to receive(:read_body).and_yield("data: [DONE]\n")
        
        client = described_class.new(api_key: api_key, options: search_options)
        client.chat(message) { |_| }
      end
    end
    
    context "when API returns an error" do
      let(:mock_response) { double("response", code: "401", read_body: '{"error":"Invalid API key"}') }
      
      it "raises an error" do
        expect { client.chat(message) { |_| } }.to raise_error(PerplexityApi::Error, /API call failed/)
      end
    end
    
    context "with invalid JSON in stream" do
      it "skips invalid JSON chunks" do
        chunks = []
        
        allow(mock_response).to receive(:read_body)
          .and_yield("data: {\"choices\":[{\"delta\":{\"content\":\"Valid\"}}]}\n")
          .and_yield("data: invalid json\n")
          .and_yield("data: {\"choices\":[{\"delta\":{\"content\":\" chunk\"}}]}\n")
          .and_yield("data: [DONE]\n")
        
        client.chat(message) do |chunk|
          chunks << chunk
        end
        
        expect(chunks.length).to eq(2)
        expect(chunks[0]["choices"][0]["delta"]["content"]).to eq("Valid")
        expect(chunks[1]["choices"][0]["delta"]["content"]).to eq(" chunk")
      end
    end
  end
end