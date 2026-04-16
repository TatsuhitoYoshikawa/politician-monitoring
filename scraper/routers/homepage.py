"""
議員ホームページ スクレイパー

【Phase 1】スタブ実装 — ダミーデータを Rails へ送信する
【Phase 2 実装予定】requests + BeautifulSoup4 でホームページを解析する

実装方針:
  1. Rails API GET /api/v1/politicians から homepage_url 一覧を取得
  2. 各 URL を httpx で取得
  3. BeautifulSoup4 で「活動報告」「ニュース」セクションを解析
  4. 新しいエントリを ActivityCreate に変換して Rails へ送信
"""
import httpx
import os
from fastapi import APIRouter
from datetime import datetime, timedelta, timezone

from schemas.activity import ActivityCreate, ActivityType, ScraperResult
from services.rails_client import push_activities

router = APIRouter()

RAILS_API_URL = os.getenv("RAILS_API_URL", "http://localhost:3000")


@router.post("/scrape/homepage", response_model=ScraperResult, summary="ホームページスクレイピング")
async def scrape_homepage():
    """
    議員ホームページから活動情報を取得して Rails へ送信する。

    【Phase 1】ダミーデータを使用。
    【Phase 2】以下の実装に差し替える:
    ```python
    from bs4 import BeautifulSoup

    # 1. Rails から議員一覧を取得
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"{RAILS_API_URL}/api/v1/politicians")
        politicians = resp.json()["data"]

    # 2. 各議員のホームページをスクレイピング
    for politician in politicians:
        if not politician.get("homepage_url"):
            continue
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                page = await client.get(politician["homepage_url"])
            soup = BeautifulSoup(page.text, "lxml")

            # サイトごとに CSS セレクターを調整
            for article in soup.select(".activity-list li, .news-list li"):
                title = article.get_text(strip=True)
                link  = article.find("a")
                activities.append(ActivityCreate(
                    politician_id=politician["id"],
                    activity_type=ActivityType.other,
                    description=f"【HP】{title[:300]}",
                    source_url=link["href"] if link else politician["homepage_url"],
                    occurred_at=datetime.now(timezone.utc),
                ))
        except Exception as e:
            print(f"Error scraping {politician['name']}: {e}")
    ```
    """
    now = datetime.now(timezone.utc)

    # --- Phase 1: ダミーデータ ---
    dummy_activities = [
        ActivityCreate(
            politician_id=4,
            activity_type=ActivityType.other,
            description="【HP】「大阪選挙区で地域住民との懇談会を開催しました。地方分権の重要性について意見交換しました」と活動報告を更新。",
            source_url="https://example.com/baba/news/dummy-001",
            occurred_at=now - timedelta(hours=8),
        ),
        ActivityCreate(
            politician_id=6,
            activity_type=ActivityType.other,
            description="【HP】「介護現場の実態調査のため、都内介護施設を視察。職員の処遇改善が急務と改めて確認しました」と活動報告を掲載。",
            source_url="https://example.com/tamura/news/dummy-001",
            occurred_at=now - timedelta(hours=12),
        ),
    ]
    # --- ここまで Phase 1 ---

    result = await push_activities(dummy_activities)

    return ScraperResult(
        source="homepage_bs4",
        status="ok",
        activities_found=len(dummy_activities),
        activities_pushed=result.get("created_count", 0),
        message=(
            f"[Phase 1 stub] {len(dummy_activities)} 件のダミーデータを送信。"
            " Phase 2 では requests + BeautifulSoup4 で各議員ホームページを解析する予定。"
        ),
    )
