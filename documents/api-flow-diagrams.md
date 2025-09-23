# 冷蔵庫AI API フロー図

このドキュメントでは、冷蔵庫AI APIの処理フローを図解で説明します。

## 概要

冷蔵庫AI APIは以下の主要機能を提供します：

1. **画像解析**: 冷蔵庫の写真からAIが材料を識別
2. **材料管理**: 識別された材料をデータベースに保存・管理
3. **レシピ生成**: 保存された材料を基にAIがレシピを自動生成

## シーケンス図（材料画像からレシピ生成まで）

```mermaid
sequenceDiagram
    participant User as ユーザー
    participant API as Rails API
    participant Controller as Controller
    participant UseCase as UseCase
    participant Service as Service
    participant OpenAI as OpenAI API
    participant DB as Supabase DB
    participant Blueprint as Blueprinter

    Note over User, Blueprint: 1. 材料画像の解析
    User->>API: POST /api/v1/ingredients/analyze_image
    API->>Controller: IngredientsController#analyze_image
    Controller->>UseCase: Api::V1::Ingredients::AnalyzeImageUsecase
    UseCase->>Service: IngredientAnalysisService
    Service->>OpenAI: GPT-4 Vision API (画像解析)
    OpenAI-->>Service: 材料データ (name, quantity, expiry_date)
    Service-->>UseCase: 材料情報配列
    
    loop 各材料に対して
        UseCase->>DB: Ingredient.create!(材料データ)
        DB-->>UseCase: 保存された材料
    end
    
    UseCase->>Blueprint: IngredientBlueprint.render_as_hash
    Blueprint-->>UseCase: JSON形式の材料データ
    UseCase-->>Controller: ['success', 材料データ]
    Controller-->>API: render json: {status: 'success', data: 材料データ}
    API-->>User: 解析結果 (JSON)

    Note over User, Blueprint: 2. レシピ生成
    User->>API: POST /api/v1/recipes/generate
    API->>Controller: RecipesController#generate
    Controller->>UseCase: Api::V1::Recipes::GenerateUsecase
    UseCase->>DB: Ingredient.by_user(user_id)
    DB-->>UseCase: ユーザーの材料一覧
    
    alt 材料が存在しない場合
        UseCase-->>Controller: ['error', 'No ingredients found']
        Controller-->>User: エラーレスポンス
    else 材料が存在する場合
        UseCase->>Service: RecipeGenerationService
        Service->>OpenAI: GPT-4 API (レシピ生成)
        OpenAI-->>Service: レシピデータ (title, ingredients, instructions)
        Service-->>UseCase: レシピ情報
        UseCase->>DB: Recipe.create!(レシピデータ)
        DB-->>UseCase: 保存されたレシピ
        UseCase->>Blueprint: RecipeBlueprint.render_as_hash
        Blueprint-->>UseCase: JSON形式のレシピデータ
        UseCase-->>Controller: ['success', レシピデータ]
        Controller-->>API: render json: {status: 'success', data: レシピデータ}
        API-->>User: 生成されたレシピ (JSON)
    end
```

## フローチャート（全体の処理フロー）

```mermaid
flowchart TD
    A[ユーザーが冷蔵庫の写真を撮影] --> B[POST /api/v1/ingredients/analyze_image]
    B --> C{画像ファイルが存在？}
    C -->|No| D[エラー: 'Image is required']
    C -->|Yes| E[IngredientAnalysisService起動]
    
    E --> F[OpenAI GPT-4 Vision APIに画像送信]
    F --> G[AIが材料を識別・解析]
    G --> H[材料データ配列を取得<br/>name, quantity, expiry_date]
    
    H --> I[各材料をSupabaseに保存]
    I --> J[Blueprinterで材料データをJSON化]
    J --> K[材料解析結果をユーザーに返却]
    
    K --> L[ユーザーがレシピ生成を要求]
    L --> M[POST /api/v1/recipes/generate]
    M --> N[ユーザーの材料一覧を取得]
    
    N --> O{材料が存在？}
    O -->|No| P[エラー: 'No ingredients found']
    O -->|Yes| Q[RecipeGenerationService起動]
    
    Q --> R[材料一覧をOpenAI GPT-4 APIに送信]
    R --> S[AIがレシピを生成]
    S --> T[レシピデータを取得<br/>title, ingredients, instructions]
    
    T --> U[レシピをSupabaseに保存]
    U --> V[BlueprinterでレシピデータをJSON化]
    V --> W[生成されたレシピをユーザーに返却]
    
    style A fill:#e1f5fe
    style D fill:#ffebee
    style P fill:#ffebee
    style K fill:#e8f5e8
    style W fill:#e8f5e8
    style F fill:#fff3e0
    style R fill:#fff3e0
```

## アーキテクチャ構成図

```mermaid
graph TB
    subgraph "クライアント層"
        Mobile[モバイルアプリ]
        Web[Webアプリ]
    end
    
    subgraph "Railway Deployment"
        subgraph "Rails API層"
            Controller[Controllers<br/>Api::V1::IngredientsController<br/>Api::V1::RecipesController]
            UseCase[UseCases<br/>AnalyzeImageUsecase<br/>GenerateUsecase]
            Service[Services<br/>IngredientAnalysisService<br/>RecipeGenerationService]
            Blueprint[Blueprinter<br/>IngredientBlueprint<br/>RecipeBlueprint]
        end
    end
    
    subgraph "外部API"
        OpenAI[OpenAI API<br/>GPT-4 Vision<br/>GPT-4]
    end
    
    subgraph "データベース"
        Supabase[(Supabase PostgreSQL<br/>ingredients テーブル<br/>recipes テーブル)]
    end
    
    Mobile --> Controller
    Web --> Controller
    Controller --> UseCase
    UseCase --> Service
    Service --> OpenAI
    UseCase --> Supabase
    UseCase --> Blueprint
    Blueprint --> Controller
    
    style Mobile fill:#e3f2fd
    style Web fill:#e3f2fd
    style Controller fill:#f3e5f5
    style UseCase fill:#e8f5e8
    style Service fill:#fff3e0
    style Blueprint fill:#fce4ec
    style OpenAI fill:#ffebee
    style Supabase fill:#e0f2f1
```

## API エンドポイント一覧

### 材料関連
- `GET /api/v1/ingredients` - 材料一覧取得
- `POST /api/v1/ingredients` - 材料作成
- `GET /api/v1/ingredients/:id` - 材料詳細取得
- `PUT /api/v1/ingredients/:id` - 材料更新
- `DELETE /api/v1/ingredients/:id` - 材料削除
- `POST /api/v1/ingredients/analyze_image` - 画像解析による材料追加

### レシピ関連
- `GET /api/v1/recipes` - レシピ一覧取得
- `POST /api/v1/recipes` - レシピ作成
- `GET /api/v1/recipes/:id` - レシピ詳細取得
- `DELETE /api/v1/recipes/:id` - レシピ削除
- `POST /api/v1/recipes/generate` - AIによるレシピ自動生成

## 技術スタック

### バックエンド
- **フレームワーク**: Ruby on Rails 7.2.0
- **言語**: Ruby 3.1.0
- **アーキテクチャ**: UseCase パターン
- **JSON シリアライゼーション**: Blueprinter

### データベース
- **データベース**: Supabase PostgreSQL
- **ORM**: Active Record

### 外部サービス
- **AI画像解析**: OpenAI GPT-4 Vision API
- **AIレシピ生成**: OpenAI GPT-4 API

### デプロイメント
- **プラットフォーム**: Railway
- **Webサーバー**: Puma

### セキュリティ・設定
- **CORS**: rack-cors
- **環境変数管理**: dotenv-rails
- **認証**: ヘッダーベース (X-User-ID)

## レスポンス形式

### 成功レスポンス
```json
{
  "status": "success",
  "data": {
    // Blueprinterでシリアライズされたデータ
  }
}
```

### エラーレスポンス
```json
{
  "status": "error",
  "data": "エラーメッセージ"
}
```

## データベーススキーマ

### ingredients テーブル
```sql
CREATE TABLE ingredients (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  name TEXT NOT NULL,
  quantity TEXT,
  expiry_date DATE,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### recipes テーブル
```sql
CREATE TABLE recipes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  title TEXT NOT NULL,
  ingredients JSONB,
  instructions TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## デプロイ情報

- **本番環境URL**: https://web-production-b2c5.up.railway.app/
- **ヘルスチェック**: https://web-production-b2c5.up.railway.app/health
- **GitHubリポジトリ**: https://github.com/Tonny4196/fridge-ai-api

---

*このドキュメントは冷蔵庫AI APIの技術仕様と処理フローを説明しています。*