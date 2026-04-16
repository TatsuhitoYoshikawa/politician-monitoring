"""
国会議員 活動モニター — スクレイパーマイクロサービス

起動:
  uvicorn main:app --reload --port 8000

Swagger UI:
  http://localhost:8000/docs
"""
from fastapi import FastAPI
from routers import ndl, twitter, homepage

app = FastAPI(
    title="Politician Monitoring — Scraper API",
    description=(
        "国会議員の活動情報を各ソースから収集し、Rails API へ送信するマイクロサービス。\n\n"
        "**Phase 1**: ダミーデータによるスタブ実装\n"
        "**Phase 2**: NDL 国会会議録 API / Twitter API v2 / ホームページ (BeautifulSoup4) の実装"
    ),
    version="0.1.0",
)

app.include_router(ndl.router,      tags=["NDL 国会会議録"])
app.include_router(twitter.router,  tags=["Twitter / X"])
app.include_router(homepage.router, tags=["議員ホームページ"])


@app.get("/health", tags=["System"])
def health_check():
    return {"status": "ok", "service": "scraper"}


@app.get("/", tags=["System"])
def root():
    return {
        "message": "Politician Monitoring Scraper API",
        "docs":    "/docs",
        "endpoints": {
            "ndl":      "POST /scrape/ndl      — 国会会議録",
            "twitter":  "POST /scrape/twitter  — Twitter / X",
            "homepage": "POST /scrape/homepage — 議員ホームページ",
        },
    }
