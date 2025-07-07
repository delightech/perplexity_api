module PerplexityApi
  module Models
    # Current Sonar Models
    SONAR = "sonar"
    SONAR_PRO = "sonar-pro"
    SONAR_DEEP_RESEARCH = "sonar-deep-research"
    
    # Legacy Models
    LLAMA_3_1_SONAR_SMALL_128K_CHAT = "llama-3.1-sonar-small-128k-chat"
    LLAMA_3_1_SONAR_LARGE_128K_CHAT = "llama-3.1-sonar-large-128k-chat"
    LLAMA_3_1_70B_INSTRUCT = "llama-3.1-70b-instruct"
    LLAMA_3_1_8B_INSTRUCT = "llama-3.1-8b-instruct"
    MISTRAL_7B = "mistral-7b"
    CODELLAMA_34B = "codellama-34b"
    LLAMA_2_70B = "llama-2-70b"
    
    # Model Groups
    SONAR_MODELS = [SONAR, SONAR_PRO, SONAR_DEEP_RESEARCH].freeze
    LLAMA_MODELS = [
      LLAMA_3_1_SONAR_SMALL_128K_CHAT,
      LLAMA_3_1_SONAR_LARGE_128K_CHAT,
      LLAMA_3_1_70B_INSTRUCT,
      LLAMA_3_1_8B_INSTRUCT,
      LLAMA_2_70B
    ].freeze
    
    ALL_MODELS = (SONAR_MODELS + LLAMA_MODELS + [MISTRAL_7B, CODELLAMA_34B]).freeze
    
    # Search modes
    SEARCH_MODE_WEB = "web"
    SEARCH_MODE_ACADEMIC = "academic"
    
    # Search recency filters
    RECENCY_MONTH = "month"
    RECENCY_WEEK = "week"
    RECENCY_DAY = "day"
    RECENCY_HOUR = "hour"
    
    # Search context sizes
    CONTEXT_SIZE_LOW = "low"
    CONTEXT_SIZE_MEDIUM = "medium"
    CONTEXT_SIZE_HIGH = "high"
  end
end