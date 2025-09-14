# Fridge AI API

冷蔵庫の写真から食材を自動認識し、AIがレシピを提案するAPIアプリケーション

## 技術スタック

- **Backend**: Ruby on Rails 6.1 (API mode)
- **Database**: PostgreSQL (Supabase)
- **AI**: OpenAI GPT-4 Vision & GPT-4
- **Deployment**: Supabase

## 機能

- 🔍 **食材認識**: 冷蔵庫の写真をAIが解析し、食材を自動識別
- 📝 **食材管理**: 食材の追加・編集・削除・一覧表示
- 🍳 **レシピ生成**: 保存された食材からAIが自動でレシピを提案
- 📱 **REST API**: フロントエンドアプリケーションとの連携用API

## APIエンドポイント

### 食材管理
- `GET /api/v1/ingredients` - 食材一覧取得
- `POST /api/v1/ingredients` - 食材追加
- `PUT /api/v1/ingredients/:id` - 食材更新
- `DELETE /api/v1/ingredients/:id` - 食材削除
- `POST /api/v1/ingredients/analyze_image` - 画像から食材認識

### レシピ管理
- `GET /api/v1/recipes` - レシピ一覧取得
- `GET /api/v1/recipes/:id` - レシピ詳細取得
- `POST /api/v1/recipes/generate` - AI レシピ生成
- `DELETE /api/v1/recipes/:id` - レシピ削除

## セットアップ

### 1. Supabaseプロジェクト作成
1. [Supabase](https://database.new) でプロジェクト作成
2. データベース接続情報を取得

### 2. 環境変数設定
```bash
cp .env.example .env
```

`.env` ファイルを編集：
```env
DATABASE_URL=postgres://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.com:5432/postgres
OPENAI_ACCESS_TOKEN=your_openai_api_key
SECRET_KEY_BASE=your_secret_key_base
```

### 3. データベース設定
Supabaseのコンソールで以下のSQLを実行：

```sql
-- 食材テーブル
CREATE TABLE ingredients (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  name TEXT NOT NULL,
  quantity TEXT,
  expiry_date DATE,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- レシピテーブル
CREATE TABLE recipes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  title TEXT NOT NULL,
  ingredients JSONB,
  instructions TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 4. Railsアプリ起動
```bash
bundle install
rails server
```

## 使用例

### 画像から食材認識
```bash
curl -X POST http://localhost:3000/api/v1/ingredients/analyze_image \
  -H "X-User-ID: your-user-id" \
  -F "image=@fridge_photo.jpg"
```

### レシピ生成
```bash
curl -X POST http://localhost:3000/api/v1/recipes/generate \
  -H "X-User-ID: your-user-id"
```

## デプロイ

Supabaseへのデプロイ手順は[Supabase Docs](https://supabase.com/docs/guides/getting-started/quickstarts/ruby-on-rails)を参照してください。

## ライセンス

MIT License
