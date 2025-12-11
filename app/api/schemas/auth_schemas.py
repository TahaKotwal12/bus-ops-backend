from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional
from datetime import datetime
from uuid import UUID

# Request schemas
class RegisterRequest(BaseModel):
    """User registration request."""
    email: EmailStr
    phone: str = Field(..., min_length=10, max_length=20)
    password: str = Field(..., min_length=8, max_length=100)
    first_name: str = Field(..., min_length=1, max_length=100)
    last_name: str = Field(..., min_length=1, max_length=100)
    role: str = Field(default="driver")
    
    @validator('phone')
    def validate_phone(cls, v):
        # Remove spaces and validate
        v = v.replace(" ", "").replace("-", "")
        if not v.isdigit():
            raise ValueError('Phone must contain only digits')
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "john.doe@busops.local",
                "phone": "9876543210",
                "password": "SecurePass123",
                "first_name": "John",
                "last_name": "Doe",
                "role": "driver"
            }
        }

class LoginRequest(BaseModel):
    """User login request."""
    email: EmailStr
    password: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "john.doe@busops.local",
                "password": "SecurePass123"
            }
        }

class RefreshTokenRequest(BaseModel):
    """Refresh token request."""
    refresh_token: str

# Response schemas
class TokenResponse(BaseModel):
    """Token response."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int  # seconds
    
    class Config:
        json_schema_extra = {
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "expires_in": 1800
            }
        }

class UserResponse(BaseModel):
    """User response."""
    user_id: UUID
    email: str
    phone: str
    first_name: str
    last_name: str
    role: str
    status: str
    profile_image: Optional[str] = None
    email_verified: bool
    phone_verified: bool
    created_at: datetime
    
    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "email": "john.doe@busops.local",
                "phone": "9876543210",
                "first_name": "John",
                "last_name": "Doe",
                "role": "driver",
                "status": "active",
                "profile_image": None,
                "email_verified": False,
                "phone_verified": False,
                "created_at": "2024-12-11T12:00:00"
            }
        }

class LoginResponse(BaseModel):
    """Login response with user and tokens."""
    user: UserResponse
    tokens: TokenResponse
