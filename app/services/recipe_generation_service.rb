class RecipeGenerationService
  def initialize
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])
  end

  def generate_recipe_from_ingredients(ingredients)
    ingredient_list = ingredients.map { |ing| "#{ing.name}（#{ing.quantity}）" }.join("、")
    
    request_params = {
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: system_prompt
        },
        {
          role: "user",
          content: "食材: #{ingredient_list}"
        }
      ],
      max_tokens: 1500,
      temperature: 0.7
    }
    
    Rails.logger.info "=== OpenAI Recipe Generation API Request ==="
    Rails.logger.info "Model: #{request_params[:model]}"
    Rails.logger.info "System prompt: #{system_prompt}"
    Rails.logger.info "User prompt: 食材: #{ingredient_list}"
    Rails.logger.info "Max tokens: #{request_params[:max_tokens]}"
    Rails.logger.info "Temperature: #{request_params[:temperature]}"
    
    begin
      response = @client.chat(parameters: request_params)
      
      Rails.logger.info "=== OpenAI Recipe Generation API Response ==="
      Rails.logger.info "Full response: #{response.to_json}"
      Rails.logger.info "Content: #{response.dig('choices', 0, 'message', 'content')}"
      Rails.logger.info "Usage: #{response.dig('usage')}"
      
      parse_recipe_response(response.dig("choices", 0, "message", "content"))
    rescue => e
      Rails.logger.error "=== OpenAI Recipe Generation API Error ==="
      Rails.logger.error "Error class: #{e.class}"
      Rails.logger.error "Error message: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.join('\n')}"
      
      # エラー時はデフォルトレスポンスを返す
      {
        title: "レシピ生成に失敗しました（APIエラー）",
        ingredients: [],
        instructions: "申し訳ございませんが、OpenAI APIでエラーが発生しました。もう一度お試しください。"
      }
    end
  end

  private

  def system_prompt
    <<~PROMPT
      あなたは経験豊富な料理研究家です。与えられた食材を使って、美味しくて実用的なレシピを作成してください。

      レシピは以下のJSON形式で回答してください：

      {
        "title": "料理名",
        "ingredients": [
          {
            "name": "食材名",
            "quantity": "使用量"
          }
        ],
        "instructions": "作り方の詳細説明（改行区切りで手順を記載）"
      }

      要件：
      - 家庭で作りやすいレシピにしてください
      - 日本人の味覚に合う料理を優先してください
      - できるだけ多くの与えられた食材を使用してください
      - 足りない基本的な調味料（醤油、塩、油など）は適宜追加してください
      - 手順は分かりやすく、番号付きで説明してください
      - JSON以外の文字は含めないでください
    PROMPT
  end

  def parse_recipe_response(content)
    # JSON文字列からRubyオブジェクトに変換
    JSON.parse(content, symbolize_names: true)
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse recipe response: #{e.message}"
    Rails.logger.error "Response content: #{content}"
    
    # パース失敗時は基本的なレシピ構造を返す
    {
      title: "レシピ生成に失敗しました",
      ingredients: [],
      instructions: "申し訳ございませんが、レシピの生成に失敗しました。もう一度お試しください。"
    }
  end
end