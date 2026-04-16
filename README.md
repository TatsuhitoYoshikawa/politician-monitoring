# 国会議員 活動モニター

日本の国会議員の日々の活動を可視化するWebアプリケーション。

## アーキテクチャ

```
Flutter Web (port 8080)
    │ HTTP GET /api/v1/...
    ▼
Rails API (port 3000)  ───▶  PostgreSQL (port 5432)
    ▲
    │ POST /api/v1/scraper/activities (Bearer token)
Python FastAPI Scraper (port 8000)
```

## ディレクトリ構成

```
politician-monitoring/
├── backend/    # Ruby on Rails 7.1 API
├── scraper/    # Python FastAPI スクレイパーマイクロサービス
└── frontend/   # Flutter Web
```

## 開発フェーズ

- **Phase 1（現在）**: Docker Compose によるローカル開発、ダミーデータ
- **Phase 2**: 実スクレイピング実装（NDL 国会会議録API / Twitter API v2 / ホームページ）
- **Phase 3**: AWS 移行（ECS Fargate + RDS + S3/CloudFront）

## ローカル起動手順

### 必要なもの

- Docker Desktop（または Docker Engine + Compose Plugin）

### 起動

```bash
cp .env.example .env
docker compose up --build
```

初回は3〜5分かかります。起動後、Railsが自動で DB作成・マイグレーション・シードデータ投入を行います。

### アクセス先

| サービス | URL |
|---------|-----|
| Flutter Web UI | http://localhost:8080 |
| Rails API | http://localhost:3000 |
| FastAPI Docs (Swagger) | http://localhost:8000/docs |
| Rails ヘルスチェック | http://localhost:3000/health |
| Scraper ヘルスチェック | http://localhost:8000/health |

### API 確認

```bash
# 議員一覧
curl http://localhost:3000/api/v1/politicians | jq

# 議員詳細（id=1）
curl http://localhost:3000/api/v1/politicians/1 | jq

# 活動一覧
curl http://localhost:3000/api/v1/activities | jq

# スクレイパースタブ実行（ダミーデータをRailsへ投入）
curl -X POST http://localhost:8000/scrape/ndl
curl -X POST http://localhost:8000/scrape/twitter
curl -X POST http://localhost:8000/scrape/homepage
```

### 便利なコマンド

```bash
# Rails コンソール
docker compose exec backend bundle exec rails console

# マイグレーション実行
docker compose exec backend bundle exec rails db:migrate

# シードデータ再投入
docker compose exec backend bundle exec rails db:seed

# ログ確認
docker compose logs -f backend
docker compose logs -f scraper
```

## データソース（Phase 2 実装予定）

| ソース | API / 方法 |
|--------|-----------|
| 国会会議録 | [NDL 国会会議録検索API](https://kokkai.ndl.go.jp/api.html)（APIキー不要） |
| SNS投稿 | Twitter API v2（Bearer token要） |
| 議員ホームページ | requests + BeautifulSoup4 |
| 参院・衆院公式サイト | Nokogiri / BeautifulSoup4 |

## AWS 移行（Phase 3）

| ローカル | AWS |
|---------|-----|
| db（PostgreSQL） | RDS PostgreSQL |
| backend（Rails） | ECS Fargate + ECR |
| scraper（FastAPI） | ECS Fargate + ECR |
| frontend（Flutter） | S3 + CloudFront |
| SCRAPER_BEARER_TOKEN | Secrets Manager |
| 定期スクレイピング | EventBridge Scheduler → ECS Task |
