from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from app.infra.db.postgres.postgres_config import get_db
from app.services.auth_service import AuthService
from app.api.schemas.auth_schemas import (
    RegisterRequest,
    LoginRequest,
    RefreshTokenRequest,
    LoginResponse,
    TokenResponse,
    UserResponse
)
from app.api.schemas.common_schemas import CommonResponse
from app.api.dependencies import get_current_active_user
from app.infra.db.postgres.models.user import User

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=CommonResponse[LoginResponse], status_code=status.HTTP_201_CREATED)
async def register(
    request: RegisterRequest,
    db: Session = Depends(get_db)
):
    """
    Register a new user.
    
    - **email**: Valid email address
    - **phone**: Phone number (10-20 digits)
    - **password**: Password (min 8 characters)
    - **first_name**: First name
    - **last_name**: Last name
    - **role**: User role (default: driver)
    """
    auth_service = AuthService(db)
    result = auth_service.register(request)
    
    return CommonResponse(
        code=status.HTTP_201_CREATED,
        message="User registered successfully",
        data=result
    )

@router.post("/login", response_model=CommonResponse[LoginResponse])
async def login(
    request: LoginRequest,
    db: Session = Depends(get_db)
):
    """
    Login user and get access token.
    
    - **email**: User email
    - **password**: User password
    
    Returns user information and JWT tokens.
    """
    auth_service = AuthService(db)
    result = auth_service.login(request)
    
    return CommonResponse(
        code=status.HTTP_200_OK,
        message="Login successful",
        data=result
    )

@router.post("/refresh", response_model=CommonResponse[TokenResponse])
async def refresh_token(
    request: RefreshTokenRequest,
    db: Session = Depends(get_db)
):
    """
    Refresh access token using refresh token.
    
    - **refresh_token**: Valid refresh token
    
    Returns new access and refresh tokens.
    """
    auth_service = AuthService(db)
    result = auth_service.refresh_token(request.refresh_token)
    
    return CommonResponse(
        code=status.HTTP_200_OK,
        message="Token refreshed successfully",
        data=result
    )

@router.get("/me", response_model=CommonResponse[UserResponse])
async def get_current_user_info(
    current_user: User = Depends(get_current_active_user)
):
    """
    Get current authenticated user information.
    
    Requires valid access token in Authorization header.
    """
    return CommonResponse(
        code=status.HTTP_200_OK,
        message="User retrieved successfully",
        data=UserResponse.model_validate(current_user)
    )

@router.post("/logout", response_model=CommonResponse[dict])
async def logout(
    current_user: User = Depends(get_current_active_user)
):
    """
    Logout user (client should discard tokens).
    
    Requires valid access token in Authorization header.
    """
    # In a production app, you would invalidate the refresh token in the database
    # For now, we just return success and let the client discard the tokens
    
    return CommonResponse(
        code=status.HTTP_200_OK,
        message="Logout successful",
        data={"message": "Please discard your tokens"}
    )
