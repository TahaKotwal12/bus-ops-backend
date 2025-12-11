from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.config.settings import settings
from app.config.logger import get_logger
from sqlalchemy import text
from app.infra.db.postgres.postgres_config import SessionLocal

APP_TITLE = "BusOps Backend"
app = FastAPI(title=APP_TITLE, version="1.0.0")

logger = get_logger(__name__)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routes (will be added later)
# app.include_router(auth.router, prefix="/api/v1")
# app.include_router(depots.router, prefix="/api/v1")
# ... more routers

@app.get("/")
async def root():
    return {
        "message": APP_TITLE,
        "status": "running",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "api_docs": "/docs",
            "api": "/api/v1"
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint that verifies database connection"""
    health_status = {
        "status": "healthy",
        "service": APP_TITLE,
        "database": "unknown"
    }
    
    # Check database connection
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        health_status["database"] = "connected"
        db.close()
    except Exception as e:
        health_status["database"] = f"error: {str(e)}"
        health_status["status"] = "unhealthy"
        logger.error(f"Database health check failed: {e}")
    
    return health_status

@app.exception_handler(Exception)
async def general_exception_handler(request, exc: Exception):
    """
    Handle all other exceptions.
    """
    logger.error(f"Unexpected error: {str(exc)}")
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "code": status.HTTP_500_INTERNAL_SERVER_ERROR,
            "message": f"An unexpected error occurred: {str(exc)}",
            "data": {}
        }
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
