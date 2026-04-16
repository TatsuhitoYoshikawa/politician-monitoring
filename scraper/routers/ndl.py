"""
国立国会図書館 国会会議録検索システム スクレイパー

【Phase 1】スタブ実装 — ダミーデータを Rails へ送信する
【Phase 2 実装予定】実際の NDL API を呼び出す

NDL API ドキュメント: https://kokkai.ndl.go.jp/api.html
エンドポイント例:
  GET https://kokkai.ndl.go.jp/api/speech
    ?speaker=岸田文雄
    &from=2024-01-01
    &until=2024-12-31
    &maximumRecords=10
    &recordPacking=json
"""
import httpx
from fastapi import APIRouter
from datetime import datetime, timedelta, timezone

from schemas.activity import ActivityCreate, ActivityType, ScraperResult
from services.rails_client import push_activities

router = APIRouter()

NDL_API_BASE = "https://kokkai.ndl.go.jp/api"


@router.post("/scrape/ndl", response_model=ScraperResult, summary="国会会議録スクレイピング")
async def scrape_ndl():
    """
    国会会議録 API から議員の発言を取得して Rails へ送信する。

    【Phase 1】ダミーデータを使用。
    【Phase 2】以下の実装に差し替える:
    ```python
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"{NDL_API_BASE}/speech", params={
            "speaker": politician_name,
            "maximumRecords": 10,
            "recordPacking": "json",
        })
        data = resp.json()
        for record in data.get("speechRecord", []):
            activities.append(ActivityCreate(
                politician_id=...,
                activity_type=ActivityType.speech,
                description=record["speech"][:500],
                source_url=record["speechURL"],
                occurred_at=datetime.fromisoformat(record["date"]),
            ))
    ```
    """
    now = datetime.now(timezone.utc)

    # --- Phase 1: ダミーデータ ---
    dummy_activities = [
        ActivityCreate(
            politician_id=1,
            activity_type=ActivityType.speech,
            description="【NDL】衆院予算委員会にて経済政策について発言。「持続可能な財政再建と成長戦略の両立を目指す」と述べた。",
            source_url=f"{NDL_API_BASE}/speech?id=dummy-ndl-001",
            occurred_at=now - timedelta(hours=3),
        ),
        ActivityCreate(
            politician_id=2,
            activity_type=ActivityType.committee,
            description="【NDL】内閣委員会にて政府のデジタル化推進策について質疑を行った。「地方と都市の格差解消が急務」と指摘。",
            source_url=f"{NDL_API_BASE}/speech?id=dummy-ndl-002",
            occurred_at=now - timedelta(hours=5),
        ),
    ]
    # --- ここまで Phase 1 ---

    result = await push_activities(dummy_activities)

    return ScraperResult(
        source="ndl_kokkai",
        status="ok",
        activities_found=len(dummy_activities),
        activities_pushed=result.get("created_count", 0),
        message=(
            f"[Phase 1 stub] {len(dummy_activities)} 件のダミーデータを送信。"
            f" Phase 2 では {NDL_API_BASE}/speech を実際に呼び出す予定。"
        ),
    )
