class IngredientAnalysisService
  def initialize
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])
  end

  def analyze_fridge_image(image_file)
    image_data = encode_image(image_file)
    
    request_params = {
      model: "gpt-4o",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: analyze_prompt
            },
            {
              type: "image_url",
              image_url: {
                url: "data:image/jpeg;base64,#{image_data[0..50]}..." # 最初の50文字のみログ
              }
            }
          ]
        }
      ],
      max_tokens: 1000,
      temperature: 0.3
    }
    
    Rails.logger.info "=== OpenAI Vision API Request ==="
    Rails.logger.info "Model: #{request_params[:model]}"
    Rails.logger.info "Prompt: #{analyze_prompt}"
    Rails.logger.info "Image data length: #{image_data.length} characters"
    Rails.logger.info "Max tokens: #{request_params[:max_tokens]}"
    Rails.logger.info "Temperature: #{request_params[:temperature]}"
    
    begin
      response = @client.chat(parameters: request_params)
      
      Rails.logger.info "=== OpenAI Vision API Response ==="
      Rails.logger.info "Full response: #{response.to_json}"
      Rails.logger.info "Content: #{response.dig('choices', 0, 'message', 'content')}"
      Rails.logger.info "Usage: #{response.dig('usage')}"
      
      parse_ingredients_response(response.dig("choices", 0, "message", "content"))
    rescue => e
      Rails.logger.error "=== OpenAI Vision API Error ==="
      Rails.logger.error "Error class: #{e.class}"
      Rails.logger.error "Error message: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.join('\n')}"
      
      # エラー時は空の配列を返す
      []
    end
  end

  private

  def encode_image(image_file)
    Base64.strict_encode64(image_file.read)
  end

  def analyze_prompt
    <<~PROMPT
      冷蔵庫の中の写真を分析して、含まれている食材を特定してください。
      以下のJSON形式で回答してください：

      [
        {
          "name": "食材名",
          "quantity": "推定量（例：2個、500g、1パックなど）",
          "expiry_date": "推定賞味期限（YYYY-MM-DD形式、不明な場合は1週間後）"
        }
      ]

      - 明確に識別できる食材のみをリストしてください
      - 一般的な日本の食材名を使用してください
      - 賞味期限は食材の一般的な保存期間を考慮してください
      - JSON以外の文字は含めないでください
    PROMPT
  end

  def parse_ingredients_response(content)
    # JSON文字列からRubyオブジェクトに変換
    JSON.parse(content, symbolize_names: true)
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse OpenAI response: #{e.message}"
    Rails.logger.error "Response content: #{content}"
    
    # パース失敗時は空の配列を返す
    []
  end
end