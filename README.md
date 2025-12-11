# BusOps Backend

FastAPI backend for the BusOps - Bus Operations Management System.

## Features

- **Authentication**: JWT-based authentication with refresh tokens
- **Database**: PostgreSQL with SQLAlchemy ORM
- **API Documentation**: Auto-generated Swagger UI at `/docs`
- **Deployment**: Vercel-ready serverless deployment

## Quick Start

### 1. Set up Database

Create a PostgreSQL database on [Neon](https://neon.tech) (recommended) or any PostgreSQL provider.

Run the database schema:
```bash
psql -h your-host -U your-user -d your-database -f scripts/script.sql
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Environment

Copy `.env.example` to `.env` and update with your values:
```bash
cp .env.example .env
```

Update `DATABASE_URL` with your NeonDB connection string.

### 4. Run Development Server

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

- API Documentation: `http://localhost:8000/docs`
- Health Check: `http://localhost:8000/health`

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - Logout

### Depots
- `GET /api/v1/depots` - List all depots
- `GET /api/v1/depots/{id}` - Get depot details
- `POST /api/v1/depots` - Create depot (admin)
- `PUT /api/v1/depots/{id}` - Update depot
- `DELETE /api/v1/depots/{id}` - Delete depot (admin)

### Vehicles
- `GET /api/v1/vehicles` - List vehicles
- `GET /api/v1/vehicles/{id}` - Get vehicle details
- `POST /api/v1/vehicles` - Add vehicle
- `PUT /api/v1/vehicles/{id}` - Update vehicle
- `DELETE /api/v1/vehicles/{id}` - Delete vehicle

### Staff
- `GET /api/v1/staff` - List staff
- `GET /api/v1/staff/{id}` - Get staff details
- `POST /api/v1/staff` - Add staff member
- `PUT /api/v1/staff/{id}` - Update staff
- `DELETE /api/v1/staff/{id}` - Delete staff

### Trips
- `GET /api/v1/trips` - List trips
- `GET /api/v1/trips/{id}` - Get trip details
- `POST /api/v1/trips` - Schedule trip
- `PUT /api/v1/trips/{id}` - Update trip
- `DELETE /api/v1/trips/{id}` - Cancel trip

### Reservations
- `GET /api/v1/reservations` - List reservations
- `GET /api/v1/reservations/{id}` - Get reservation details
- `POST /api/v1/reservations` - Create reservation
- `PUT /api/v1/reservations/{id}` - Update reservation
- `DELETE /api/v1/reservations/{id}` - Cancel reservation

### Attendance
- `GET /api/v1/attendance` - List attendance
- `GET /api/v1/attendance/today` - Today's attendance
- `POST /api/v1/attendance` - Mark attendance

### Incidents
- `GET /api/v1/incidents` - List incidents
- `GET /api/v1/incidents/{id}` - Get incident details
- `POST /api/v1/incidents` - Report incident
- `PUT /api/v1/incidents/{id}` - Update incident

### Analytics
- `GET /api/v1/analytics/dashboard` - Dashboard statistics
- `GET /api/v1/analytics/trips/daily` - Daily trip stats
- `GET /api/v1/analytics/revenue/daily` - Daily revenue

## Deployment

### Deploy to Vercel

```bash
vercel --prod
```

Make sure to set environment variables in Vercel dashboard:
- `DATABASE_URL`
- `SECRET_KEY`
- `CORS_ORIGINS`

## Database Schema

The complete database schema is in `scripts/script.sql`. It includes:

- 23 tables for all bus operations
- 13 enum types for status fields
- 60+ indexes for performance
- 10 triggers for auto-updating timestamps
- 2 views for common queries

## Project Structure

```
backend/
├── app/
│   ├── main.py                 # FastAPI app entry point
│   ├── config/
│   │   ├── settings.py         # Configuration
│   │   └── logger.py           # Logging
│   ├── api/
│   │   ├── routes/             # API endpoints
│   │   └── schemas/            # Pydantic models
│   ├── infra/
│   │   └── db/
│   │       └── postgres/
│   │           ├── models/     # SQLAlchemy models
│   │           └── repositories/
│   ├── services/               # Business logic
│   └── utils/                  # Utilities
├── scripts/
│   └── script.sql              # Database schema
├── requirements.txt
├── vercel.json
└── .env.example
```

## License

MIT License - Open Source
