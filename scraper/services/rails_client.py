"""
Rails API へスクレイピング結果を送信するクライアント。
POST /api/v1/scraper/activities に Bearer token 付きでリクエストする。
"""
import os
import httpx
from typing import List
from schemas.activity import ActivityCreate

RAILS_API_URL      = os.getenv("RAILS_API_URL", "http://localhost:3000")
RAILS_BEARER_TOKEN = os.getenv("RAILS_BEARER_TOKEN", "dev-scraper-token-changeme")


async def push_activities(activities: List[ActivityCreate]) -> dict:
    """
    スクレイピングした活動データを Rails API へ一括送信する。

    Returns:
        Rails API のレスポンス JSON
        { created_count: int, created_ids: list[int], errors: list }
    """
    if not activities:
        return {"created_count": 0, "created_ids": [], "errors": []}

    headers = {
        "Authorization": f"Bearer {RAILS_BEARER_TOKEN}",
        "Content-Type":  "application/json",
    }
    payload = {
        "activities": [
            {
                "politician_id": a.politician_id,
                "activity_type": a.activity_type.value,
                "description":   a.description,
                "source_url":    a.source_url,
                "occurred_at":   a.occurred_at.isoformat(),
            }
            for a in activities
        ]
    }

    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(
            f"{RAILS_API_URL}/api/v1/scraper/activities",
            headers=headers,
            json=payload,
        )
        response.raise_for_status()
        return response.json()
