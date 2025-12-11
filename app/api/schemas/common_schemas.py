from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Generic, TypeVar
from datetime import datetime
from uuid import UUID

T = TypeVar('T')

class CommonResponse(BaseModel, Generic[T]):
    """Common response model for all API endpoints."""
    code: int
    message: str
    data: Optional[T] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        json_schema_extra = {
            "example": {
                "code": 200,
                "message": "Success",
                "data": {},
                "timestamp": "2024-12-11T12:00:00"
            }
        }

class PaginationMeta(BaseModel):
    """Pagination metadata."""
    page: int
    page_size: int
    total_items: int
    total_pages: int

class PaginatedResponse(BaseModel, Generic[T]):
    """Paginated response model."""
    items: list[T]
    meta: PaginationMeta
