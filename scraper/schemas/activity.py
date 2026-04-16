from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from enum import Enum


class ActivityType(str, Enum):
    speech    = "speech"
    sns       = "sns"
    committee = "committee"
    vote      = "vote"
    other     = "other"


class ActivityCreate(BaseModel):
    politician_id: int
    activity_type: ActivityType
    description:   str
    source_url:    Optional[str] = None
    occurred_at:   datetime


class ScraperResult(BaseModel):
    """スクレイパーエンドポイントの共通レスポンス"""
    source:             str
    status:             str
    activities_found:   int
    activities_pushed:  int
    message:            str
