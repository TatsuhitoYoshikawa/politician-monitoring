"""
Twitter / X API v2 スクレイパー

【Phase 1】スタブ実装 — ダミーデータを Rails へ送信する
【Phase 2 実装予定】Twitter API v2 を Bearer token で呼び出す

Twitter API v2 ドキュメント: https://developer.twitter.com/en/docs/twitter-api
エンドポイント例:
  GET https://api.twitter.com/2/users/:id/tweets
    ?max_results=10
    &tweet.fields=created_at,text
  Header: Authorization: Bearer <TWITTER_BEARER_TOKEN>
"""
import os
from fastapi import APIRouter
from datetime import datetime, timedelta, timezone

from schemas.activity import ActivityCreate, ActivityType, ScraperResult
from services.rails_client import push_activities

router = APIRouter()

TWITTER_API_BASE   = "https://api.twitter.com/2"
TWITTER_BEARER_TOKEN = os.getenv("TWITTER_BEARER_TOKEN", "")


@router.post("/scrape/twitter", response_model=ScraperResult, summary="Twitter/X スクレイピング")
async def scrape_twitter():
    """
    Twitter API v2 から議員のツイートを取得して Rails へ送信する。

    【Phase 1】ダミーデータを使用。
    【Phase 2】以下の実装に差し替える:
    ```python
    headers = {"Authorization": f"Bearer {TWITTER_BEARER_TOKEN}"}
    async with httpx.AsyncClient() as client:
        # まずユーザー ID を取得
        resp = await client.get(
            f"{TWITTER_API_BASE}/users/by/username/{twitter_handle}",
            headers=headers,
        )
        user_id = resp.json()["data"]["id"]

        # ツイート一覧を取得
        resp = await client.get(
            f"{TWITTER_API_BASE}/users/{user_id}/tweets",
            headers=headers,
            params={"max_results": 10, "tweet.fields": "created_at,text"},
        )
        for tweet in resp.json().get("data", []):
            activities.append(ActivityCreate(
                politician_id=...,
                activity_type=ActivityType.sns,
                description=f"【X】{tweet['text'][:300]}",
                source_url=f"https://x.com/i/web/status/{tweet['id']}",
                occurred_at=datetime.fromisoformat(tweet["created_at"]),
            ))
    ```

    注意: Phase 2 では TWITTER_BEARER_TOKEN 環境変数の設定が必要。
    """
    now = datetime.now(timezone.utc)

    # --- Phase 1: ダミーデータ ---
    dummy_activities = [
        ActivityCreate(
            politician_id=3,
            activity_type=ActivityType.sns,
            description="【X】「本日の委員会では少子化対策について重要な議論を行いました。詳細はブログにて報告します」と投稿。",
            source_url="https://x.com/i/web/status/dummy-tweet-001",
            occurred_at=now - timedelta(hours=1),
        ),
        ActivityCreate(
            politician_id=5,
            activity_type=ActivityType.sns,
            description="【X】「手取り増やす！103万円の壁を今国会で必ず突破します。皆さんの声が力になっています」と投稿。5000RT超。",
            source_url="https://x.com/i/web/status/dummy-tweet-002",
            occurred_at=now - timedelta(minutes=45),
        ),
    ]
    # --- ここまで Phase 1 ---

    result = await push_activities(dummy_activities)

    return ScraperResult(
        source="twitter_v2",
        status="ok",
        activities_found=len(dummy_activities),
        activities_pushed=result.get("created_count", 0),
        message=(
            f"[Phase 1 stub] {len(dummy_activities)} 件のダミーデータを送信。"
            f" Phase 2 では Twitter API v2 を呼び出す予定"
            f"{'（TWITTER_BEARER_TOKEN 未設定）' if not TWITTER_BEARER_TOKEN else ''}。"
        ),
    )
