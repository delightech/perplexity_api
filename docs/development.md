# Perplexity API Gem 開発ドキュメント

## 概要

このドキュメントは、Perplexity AI APIのすべての機能を包括的にサポートするPerplexity API Ruby gemバージョン0.3.0の実装詳細について説明します。

## アーキテクチャ

### コアコンポーネント

1. **Client** (`lib/perplexity_api/client.rb`)
   - 同期API呼び出しのメインインターフェース
   - メッセージのフォーマットとリクエストビルドを処理
   - 文字列と配列の両方のメッセージ入力をサポート

2. **StreamClient** (`lib/perplexity_api/stream_client.rb`)
   - Server-Sent Events (SSE)ストリーミングを処理
   - チャンクレスポンスをリアルタイムで処理
   - ストリーム中断に対する適切なエラー処理を実装

3. **Configuration** (`lib/perplexity_api/configuration.rb`)
   - APIキーとデフォルト設定を管理
   - 環境変数設定をサポート
   - トラブルシューティング用のデバッグモードを提供

4. **Models** (`lib/perplexity_api/models.rb`)
   - 利用可能なすべてのモデルの定数
   - モデルファミリー（Sonar、Llamaなど）でグループ化
   - 検索関連の定数

## 実装詳細

### 1. ストリーミングサポート

ストリーミング実装はServer-Sent Events (SSE)プロトコルを使用：

```ruby
# StreamClient#chatメソッド
def chat(messages, &block)
  # SSEヘッダー付きのHTTPリクエストを準備
  request["Accept"] = "text/event-stream"
  request["Cache-Control"] = "no-cache"
  
  # ストリーミングレスポンスを処理
  response.read_body do |chunk|
    # SSE形式をパース: "data: {json}\n"
    # 特別な"[DONE]"マーカーを処理
    # パースしたJSONチャンクをブロックにyield
  end
end
```

主な機能：
- ノンブロッキングチャンク処理
- 自動JSONパース
- 不正なチャンクに対するエラー復旧
- すべてのチャットパラメータをサポート

### 2. Web検索統合

Web検索は追加のリクエストパラメータを通じて実装：

```ruby
# build_request_bodyでの検索パラメータ
body[:search_mode] = options[:search_mode] # "web"または"academic"
body[:search_domain_filter] = options[:search_domain_filter] # ["domain.com", "-excluded.com"]
body[:search_recency_filter] = options[:search_recency_filter] # "hour", "day", "week", "month"
```

高度な検索機能：
- 日付範囲フィルタリング
- 位置ベース検索
- ドメインの包含/除外
- 学術論文検索モード

### 3. メッセージ配列サポート

gemは完全な会話履歴をサポート：

```ruby
def prepare_messages(messages)
  case messages
  when String
    [{ role: "user", content: messages }]
  when Array
    messages # マルチターン会話用にパススルー
  else
    raise ArgumentError, "メッセージは文字列または配列である必要があります"
  end
end
```

これにより以下が可能：
- システムプロンプト
- マルチターン会話
- アシスタントメッセージ履歴
- コンテキストの保持

### 4. リクエストビルド

`build_request_body`メソッドはすべてのパラメータでAPIリクエストを構築：

```ruby
def build_request_body(messages, options)
  body = {
    model: @model,
    messages: messages
  }
  
  # nil以外のパラメータのみ追加
  body[:temperature] = options[:temperature] if options[:temperature]
  body[:search_mode] = options[:search_mode] if options[:search_mode]
  # ... その他のパラメータ
  
  body
end
```

このアプローチ：
- 不要なnull値の送信を回避
- すべてのAPIパラメータをサポート
- 後方互換性を維持

## API設計の決定事項

### 1. 後方互換性

gemは後方互換性を維持：
- `chat(string)`はシンプルなクエリで引き続き機能
- 高度な使用のための新しい`chat(messages, options)`シグネチャ
- デフォルト値が既存の動作を保持

### 2. ストリーミングインターフェース

ストリーミングは自然な反復のためにRubyブロックを使用：
```ruby
PerplexityApi.stream_chat("クエリ") do |chunk|
  print chunk["choices"][0]["delta"]["content"]
end
```

### 3. 設定の柔軟性

複数の設定方法：
- 環境変数（推奨）
- Ruby設定ブロック
- リクエストごとのオーバーライド

### 4. エラーハンドリング

包括的なエラーハンドリング：
- APIエラーは`PerplexityApi::Error`を発生
- ストリーミングエラーはキャッチされて再発生
- ストリーム内の無効なJSONはスキップ

## テスト戦略

### ユニットテスト

1. **Clientテスト** (`spec/perplexity_api/client_spec.rb`)
   - リクエストフォーマット
   - パラメータ処理
   - エラーシナリオ

2. **StreamClientテスト** (`spec/perplexity_api/stream_client_spec.rb`)
   - SSEパース
   - チャンク処理
   - エラー復旧

3. **Configurationテスト** (`spec/perplexity_api/configuration_spec.rb`)
   - 環境変数の読み込み
   - デフォルト値
   - バリデーション

4. **Modelテスト** (`spec/perplexity_api/models_spec.rb`)
   - 定数定義
   - モデルグループ化

### テストパターン

- 予測可能なテストのためのHTTPレスポンスのモック
- 設定テストのための環境変数のスタブ
- 成功と失敗の両方のパスをテスト

## v0.3.0の新機能

### 1. ストリーミングレスポンス
- リアルタイムレスポンスストリーミング
- Server-Sent Eventsサポート
- チャンク転送エンコーディング

### 2. Web検索
- ドメインフィルタリング（包含/除外）
- 日付範囲フィルタ
- 最新性フィルタ（時間/日/週/月）
- 位置ベース検索

### 3. 高度なモデル
- sonar-pro: 拡張機能
- sonar-deep-research: 詳細な分析
- すべてのレガシーモデルをサポート

### 4. 拡張パラメータ
- frequency_penalty: 繰り返しを減らす
- presence_penalty: トピックの多様性を促進
- return_images: 画像結果を取得（ベータ）
- return_related_questions: フォローアップの質問を取得（ベータ）

### 5. 検索モード
- Web検索: 一般的なインターネット検索
- 学術検索: 学術論文と論文

## 使用例

### 基本チャット
```ruby
response = PerplexityApi.chat("こんにちは、世界！")
```

### ストリーミング
```ruby
PerplexityApi.stream_chat("物語を聞かせて") do |chunk|
  print chunk["choices"][0]["delta"]["content"]
end
```

### Web検索
```ruby
response = PerplexityApi.chat(
  "最新のAIニュース",
  options: {
    search_mode: "web",
    search_recency_filter: "day"
  }
)
```

### 会話
```ruby
messages = [
  { role: "system", content: "あなたはRubyのエキスパートです" },
  { role: "user", content: "gemの作り方を教えてください" }
]
response = PerplexityApi.chat(messages)
```

## 環境変数

gemは以下の環境変数をサポート：

```
PERPLEXITY_API_KEY=your-api-key
PERPLEXITY_DEFAULT_MODEL=sonar-pro
PERPLEXITY_TEMPERATURE=0.7
PERPLEXITY_MAX_TOKENS=2048
PERPLEXITY_TOP_P=0.9
PERPLEXITY_TOP_K=0
PERPLEXITY_FREQUENCY_PENALTY=0.0
PERPLEXITY_PRESENCE_PENALTY=0.0
```

## パフォーマンスの考慮事項

1. **ストリーミング**: 大きなレスポンスのメモリ使用量を削減
2. **接続の再利用**: 各リクエストは新しい接続を作成（最適化可能）
3. **JSONパース**: 効率のために組み込みJSONパーサーを使用
4. **エラー復旧**: 優雅な処理により接続リークを防止

## セキュリティの考慮事項

1. **APIキーの保存**: ハードコードされた値ではなく環境変数を使用
2. **HTTPSのみ**: すべての接続はSSL/TLSを使用
3. **入力検証**: 送信前にメッセージを検証
4. **ログなし**: 機密データはログに記録されない

## 将来の拡張

将来のバージョンの潜在的な改善：

1. **接続プーリング**: HTTP接続の再利用
2. **非同期サポート**: ノンブロッキングAPI呼び出し
3. **レート制限**: 組み込みレート制限処理
4. **リトライロジック**: 指数バックオフによる自動リトライ
5. **レスポンスキャッシング**: オプションのレスポンスキャッシング
6. **Webhookサポート**: PerplexityがWebhook機能を追加した場合

## コントリビューション

新機能を追加する際：

1. 後方互換性を維持
2. 包括的なテストを追加
3. ドキュメントを更新
4. Rubyスタイルガイドラインに従う
5. 新機能の例を追加

## デバッグ

設定の詳細を表示するためにデバッグモードを有効化：

```ruby
PerplexityApi.configuration.debug_mode = true
```

これにより以下が出力されます：
- 設定読み込みの詳細
- APIキーステータス（設定済み/未設定）
- デフォルトモデルとパラメータ

## リリースプロセス

1. `lib/perplexity_api/version.rb`でバージョンを更新
2. CHANGELOG.mdを更新
3. テストを実行: `bundle exec rspec`
4. gemをビルド: `gem build perplexity_api.gemspec`
5. RubyGemsにプッシュ: `gem push perplexity_api-x.x.x.gem`

## ライセンス

MITライセンス - 詳細はLICENSE.txtを参照