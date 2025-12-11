from sqlalchemy.orm import Session
from typing import Optional
from app.infra.db.postgres.models.user import User, UserRole, UserStatus
from app.utils.security import get_password_hash
from uuid import UUID

class UserRepository:
    """Repository for User database operations."""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_id(self, user_id: UUID) -> Optional[User]:
        """Get user by ID."""
        return self.db.query(User).filter(User.user_id == user_id).first()
    
    def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email."""
        return self.db.query(User).filter(User.email == email).first()
    
    def get_by_phone(self, phone: str) -> Optional[User]:
        """Get user by phone."""
        return self.db.query(User).filter(User.phone == phone).first()
    
    def create(
        self,
        email: str,
        phone: str,
        password: str,
        first_name: str,
        last_name: str,
        role: str = "driver"
    ) -> User:
        """Create a new user."""
        # Hash password
        password_hash = get_password_hash(password)
        
        # Create user
        user = User(
            email=email,
            phone=phone,
            password_hash=password_hash,
            first_name=first_name,
            last_name=last_name,
            role=UserRole(role),
            status=UserStatus.ACTIVE
        )
        
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        
        return user
    
    def update(self, user: User) -> User:
        """Update user."""
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def delete(self, user: User) -> None:
        """Delete user."""
        self.db.delete(user)
        self.db.commit()
