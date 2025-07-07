require 'spec_helper'

RSpec.describe PerplexityApi::Models do
  describe "Model Constants" do
    it "defines sonar models" do
      expect(described_class::SONAR).to eq("sonar")
      expect(described_class::SONAR_PRO).to eq("sonar-pro")
      expect(described_class::SONAR_DEEP_RESEARCH).to eq("sonar-deep-research")
    end
    
    it "defines llama models" do
      expect(described_class::LLAMA_3_1_SONAR_SMALL_128K_CHAT).to eq("llama-3.1-sonar-small-128k-chat")
      expect(described_class::LLAMA_3_1_SONAR_LARGE_128K_CHAT).to eq("llama-3.1-sonar-large-128k-chat")
      expect(described_class::LLAMA_3_1_70B_INSTRUCT).to eq("llama-3.1-70b-instruct")
      expect(described_class::LLAMA_3_1_8B_INSTRUCT).to eq("llama-3.1-8b-instruct")
      expect(described_class::LLAMA_2_70B).to eq("llama-2-70b")
    end
    
    it "defines other models" do
      expect(described_class::MISTRAL_7B).to eq("mistral-7b")
      expect(described_class::CODELLAMA_34B).to eq("codellama-34b")
    end
  end
  
  describe "Model Groups" do
    it "groups sonar models" do
      expect(described_class::SONAR_MODELS).to contain_exactly(
        "sonar", "sonar-pro", "sonar-deep-research"
      )
    end
    
    it "groups llama models" do
      expect(described_class::LLAMA_MODELS).to include(
        "llama-3.1-sonar-small-128k-chat",
        "llama-3.1-sonar-large-128k-chat",
        "llama-3.1-70b-instruct"
      )
    end
    
    it "includes all models in ALL_MODELS" do
      expect(described_class::ALL_MODELS).to include(
        "sonar", "sonar-pro", "sonar-deep-research",
        "llama-3.1-sonar-small-128k-chat", "mistral-7b"
      )
    end
  end
  
  describe "Search Constants" do
    it "defines search modes" do
      expect(described_class::SEARCH_MODE_WEB).to eq("web")
      expect(described_class::SEARCH_MODE_ACADEMIC).to eq("academic")
    end
    
    it "defines recency filters" do
      expect(described_class::RECENCY_MONTH).to eq("month")
      expect(described_class::RECENCY_WEEK).to eq("week")
      expect(described_class::RECENCY_DAY).to eq("day")
      expect(described_class::RECENCY_HOUR).to eq("hour")
    end
    
    it "defines context sizes" do
      expect(described_class::CONTEXT_SIZE_LOW).to eq("low")
      expect(described_class::CONTEXT_SIZE_MEDIUM).to eq("medium")
      expect(described_class::CONTEXT_SIZE_HIGH).to eq("high")
    end
  end
end