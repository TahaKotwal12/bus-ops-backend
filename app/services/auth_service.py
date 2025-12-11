from sqlalchemy.orm import Session
from datetime import timedelta
from app.infra.db.postgres.repositories.user_repository import UserRepository
from app.utils.security import verify_password, create_access_token, create_refresh_token, decode_token
from app.api.schemas.auth_schemas import RegisterRequest, LoginRequest, TokenResponse, UserResponse, LoginResponse
from app.config.settings import settings
from fastapi import HTTPException, status

class AuthService:
    """Service for authentication operations."""
    
    def __init__(self, db: Session):
        self.db = db
        self.user_repo = UserRepository(db)
    
    def register(self, request: RegisterRequest) -> LoginResponse:
        """Register a new user."""
        # Check if email already exists
        existing_user = self.user_repo.get_by_email(request.email)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        
        # Check if phone already exists
        existing_phone = self.user_repo.get_by_phone(request.phone)
        if existing_phone:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Phone number already registered"
            )
        
        # Create user
        user = self.user_repo.create(
            email=request.email,
            phone=request.phone,
            password=request.password,
            first_name=request.first_name,
            last_name=request.last_name,
            role=request.role
        )
        
        # Generate tokens
        tokens = self._generate_tokens(str(user.user_id), user.email)
        
        # Return response
        return LoginResponse(
            user=UserResponse.model_validate(user),
            tokens=tokens
        )
    
    def login(self, request: LoginRequest) -> LoginResponse:
        """Login user."""
        # Get user by email
        user = self.user_repo.get_by_email(request.email)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        # Verify password
        if not verify_password(request.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        # Check if user is active
        if user.status != "active":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Account is {user.status}"
            )
        
        # Generate tokens
        tokens = self._generate_tokens(str(user.user_id), user.email)
        
        # Return response
        return LoginResponse(
            user=UserResponse.model_validate(user),
            tokens=tokens
        )
    
    def refresh_token(self, refresh_token: str) -> TokenResponse:
        """Refresh access token."""
        # Decode refresh token
        payload = decode_token(refresh_token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid refresh token"
            )
        
        # Check token type
        if payload.get("type") != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token type"
            )
        
        # Get user
        user_id = payload.get("sub")
        user = self.user_repo.get_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        
        # Generate new tokens
        return self._generate_tokens(str(user.user_id), user.email)
    
    def _generate_tokens(self, user_id: str, email: str) -> TokenResponse:
        """Generate access and refresh tokens."""
        # Create access token
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user_id, "email": email},
            expires_delta=access_token_expires
        )
        
        # Create refresh token
        refresh_token_expires = timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
        refresh_token = create_refresh_token(
            data={"sub": user_id, "email": email},
            expires_delta=refresh_token_expires
        )
        
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        )
