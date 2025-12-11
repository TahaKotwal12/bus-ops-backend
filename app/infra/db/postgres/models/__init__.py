# Import all models here for SQLAlchemy to register them
from app.infra.db.postgres.models.user import User

__all__ = ["User"]
