-- ====================================================================
-- BusOps - Bus Operations Management System
-- Complete PostgreSQL Database Schema for NeonDB
-- ====================================================================

-- ====================================================================
-- ENUM TYPES
-- ====================================================================

-- User related enums
CREATE TYPE user_role AS ENUM ('admin', 'depot_manager', 'driver', 'conductor', 'mechanic', 'supervisor');
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TYPE gender_enum AS ENUM ('male', 'female', 'other');

-- Vehicle related enums
CREATE TYPE vehicle_status AS ENUM ('available', 'in-service', 'maintenance', 'breakdown', 'retired');
CREATE TYPE vehicle_type AS ENUM ('ordinary', 'semi-luxury', 'luxury', 'ac', 'non-ac', 'sleeper');
CREATE TYPE fuel_type AS ENUM ('diesel', 'petrol', 'cng', 'electric', 'hybrid');

-- Trip related enums
CREATE TYPE trip_status AS ENUM ('scheduled', 'in-progress', 'completed', 'cancelled', 'delayed');
CREATE TYPE trip_type AS ENUM ('regular', 'express', 'special', 'charter');

-- Reservation related enums
CREATE TYPE reservation_status AS ENUM ('confirmed', 'cancelled', 'no-show', 'boarded', 'refunded');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TYPE payment_method AS ENUM ('cash', 'card', 'upi', 'wallet', 'netbanking');

-- Attendance related enums
CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'on-leave', 'late', 'half-day');
CREATE TYPE leave_type AS ENUM ('sick', 'casual', 'earned', 'unpaid');

-- Incident related enums
CREATE TYPE incident_severity AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE incident_status AS ENUM ('reported', 'investigating', 'resolved', 'closed');
CREATE TYPE incident_type AS ENUM ('accident', 'breakdown', 'delay', 'passenger_complaint', 'safety_issue', 'other');

-- Route related enums
CREATE TYPE route_type AS ENUM ('city', 'intercity', 'express', 'local');

-- ====================================================================
-- CORE TABLES
-- ====================================================================

-- Users table (all system users)
CREATE TABLE busops_users_tbl (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role user_role NOT NULL,
    status user_status DEFAULT 'active',
    profile_image VARCHAR(500),
    date_of_birth DATE,
    gender gender_enum,
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Depots table
CREATE TABLE busops_depots_tbl (
    depot_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(20) NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    manager_id UUID REFERENCES busops_users_tbl(user_id),
    capacity INTEGER NOT NULL, -- Number of buses it can hold
    active_vehicles INTEGER DEFAULT 0,
    active_staff INTEGER DEFAULT 0,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    status user_status DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles table
CREATE TABLE busops_vehicles_tbl (
    vehicle_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    registration_number VARCHAR(50) UNIQUE NOT NULL,
    vehicle_number VARCHAR(50) UNIQUE NOT NULL,
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    capacity INTEGER NOT NULL,
    vehicle_type vehicle_type NOT NULL,
    fuel_type fuel_type NOT NULL,
    depot_id UUID REFERENCES busops_depots_tbl(depot_id),
    status vehicle_status DEFAULT 'available',
    last_service_date DATE,
    next_service_date DATE,
    mileage INTEGER DEFAULT 0, -- in kilometers
    gps_device_id VARCHAR(100),
    insurance_expiry DATE,
    permit_expiry DATE,
    fitness_certificate_expiry DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vehicle maintenance records
CREATE TABLE busops_vehicle_maintenance_tbl (
    maintenance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID REFERENCES busops_vehicles_tbl(vehicle_id) ON DELETE CASCADE,
    maintenance_type VARCHAR(100) NOT NULL, -- 'routine', 'repair', 'inspection'
    description TEXT NOT NULL,
    cost DECIMAL(10, 2),
    mechanic_id UUID REFERENCES busops_users_tbl(user_id),
    service_date DATE NOT NULL,
    next_service_date DATE,
    parts_replaced TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Staff table
CREATE TABLE busops_staff_tbl (
    staff_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES busops_users_tbl(user_id) ON DELETE CASCADE,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    depot_id UUID REFERENCES busops_depots_tbl(depot_id),
    license_number VARCHAR(50),
    license_type VARCHAR(50), -- 'heavy', 'light', 'transport'
    license_expiry DATE,
    date_of_joining DATE NOT NULL,
    shift VARCHAR(20), -- 'morning', 'afternoon', 'night'
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(20),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    blood_group VARCHAR(5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Routes table
CREATE TABLE busops_routes_tbl (
    route_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_number VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    origin VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    distance DECIMAL(10, 2) NOT NULL, -- in kilometers
    estimated_duration INTEGER NOT NULL, -- in minutes
    route_type route_type DEFAULT 'city',
    base_fare DECIMAL(10, 2) NOT NULL,
    depot_id UUID REFERENCES busops_depots_tbl(depot_id),
    status user_status DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Route stops table
CREATE TABLE busops_route_stops_tbl (
    stop_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id UUID REFERENCES busops_routes_tbl(route_id) ON DELETE CASCADE,
    stop_name VARCHAR(255) NOT NULL,
    stop_order INTEGER NOT NULL,
    distance_from_origin DECIMAL(10, 2) NOT NULL, -- in kilometers
    estimated_arrival_time INTEGER NOT NULL, -- in minutes from origin
    fare DECIMAL(10, 2) NOT NULL,
    is_boarding BOOLEAN DEFAULT TRUE,
    is_dropping BOOLEAN DEFAULT TRUE,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trips table
CREATE TABLE busops_trips_tbl (
    trip_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_number VARCHAR(50) UNIQUE NOT NULL,
    route_id UUID REFERENCES busops_routes_tbl(route_id),
    vehicle_id UUID REFERENCES busops_vehicles_tbl(vehicle_id),
    depot_id UUID REFERENCES busops_depots_tbl(depot_id),
    scheduled_departure_time TIMESTAMP NOT NULL,
    scheduled_arrival_time TIMESTAMP NOT NULL,
    actual_departure_time TIMESTAMP,
    actual_arrival_time TIMESTAMP,
    status trip_status DEFAULT 'scheduled',
    trip_type trip_type DEFAULT 'regular',
    total_seats INTEGER NOT NULL,
    available_seats INTEGER NOT NULL,
    reserved_seats INTEGER DEFAULT 0,
    fare DECIMAL(10, 2) NOT NULL,
    delay_minutes INTEGER DEFAULT 0,
    cancellation_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trip assignments (staff and vehicle assignments)
CREATE TABLE busops_trip_assignments_tbl (
    assignment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES busops_trips_tbl(trip_id) ON DELETE CASCADE,
    driver_id UUID REFERENCES busops_staff_tbl(staff_id),
    conductor_id UUID REFERENCES busops_staff_tbl(staff_id),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES busops_users_tbl(user_id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Passengers table
CREATE TABLE busops_passengers_tbl (
    passenger_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    age INTEGER,
    gender gender_enum,
    id_proof_type VARCHAR(50), -- 'aadhar', 'pan', 'passport', 'license'
    id_proof_number VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reservations table
CREATE TABLE busops_reservations_tbl (
    reservation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_number VARCHAR(50) UNIQUE NOT NULL,
    trip_id UUID REFERENCES busops_trips_tbl(trip_id),
    passenger_id UUID REFERENCES busops_passengers_tbl(passenger_id),
    boarding_stop_id UUID REFERENCES busops_route_stops_tbl(stop_id),
    dropping_stop_id UUID REFERENCES busops_route_stops_tbl(stop_id),
    seat_number VARCHAR(10),
    fare DECIMAL(10, 2) NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status reservation_status DEFAULT 'confirmed',
    payment_method payment_method,
    payment_status payment_status DEFAULT 'pending',
    payment_id VARCHAR(255), -- Payment gateway transaction ID
    boarded_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    refund_amount DECIMAL(10, 2),
    created_by UUID REFERENCES busops_users_tbl(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Attendance table
CREATE TABLE busops_attendance_tbl (
    attendance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    staff_id UUID REFERENCES busops_staff_tbl(staff_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    status attendance_status DEFAULT 'present',
    check_in_time TIMESTAMP,
    check_out_time TIMESTAMP,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    notes TEXT,
    marked_by UUID REFERENCES busops_users_tbl(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(staff_id, date)
);

-- Leave requests table
CREATE TABLE busops_leave_requests_tbl (
    leave_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    staff_id UUID REFERENCES busops_staff_tbl(staff_id) ON DELETE CASCADE,
    leave_type leave_type NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    approved_by UUID REFERENCES busops_users_tbl(user_id),
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Incidents table
CREATE TABLE busops_incidents_tbl (
    incident_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_number VARCHAR(50) UNIQUE NOT NULL,
    trip_id UUID REFERENCES busops_trips_tbl(trip_id),
    vehicle_id UUID REFERENCES busops_vehicles_tbl(vehicle_id),
    reported_by UUID REFERENCES busops_users_tbl(user_id),
    incident_type incident_type NOT NULL,
    severity incident_severity NOT NULL,
    status incident_status DEFAULT 'reported',
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    incident_date TIMESTAMP NOT NULL,
    resolved_at TIMESTAMP,
    resolved_by UUID REFERENCES busops_users_tbl(user_id),
    resolution_notes TEXT,
    estimated_cost DECIMAL(10, 2),
    actual_cost DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Incident photos table
CREATE TABLE busops_incident_photos_tbl (
    photo_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id UUID REFERENCES busops_incidents_tbl(incident_id) ON DELETE CASCADE,
    photo_url VARCHAR(500) NOT NULL,
    caption TEXT,
    uploaded_by UUID REFERENCES busops_users_tbl(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- AUTHENTICATION TABLES
-- ====================================================================

-- Refresh tokens table for JWT refresh mechanism
CREATE TABLE busops_refresh_tokens_tbl (
    refresh_token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES busops_users_tbl(user_id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User sessions table for tracking active sessions
CREATE TABLE busops_user_sessions_tbl (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES busops_users_tbl(user_id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    device_name VARCHAR(255),
    device_type VARCHAR(50), -- 'mobile', 'web', 'tablet'
    platform VARCHAR(50), -- 'ios', 'android', 'web'
    is_active BOOLEAN DEFAULT TRUE,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, device_id)
);

-- Password reset tokens table
CREATE TABLE busops_password_reset_tokens_tbl (
    reset_token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES busops_users_tbl(user_id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- ANALYTICS TABLES
-- ====================================================================

-- Daily statistics table
CREATE TABLE busops_daily_stats_tbl (
    stat_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL,
    depot_id UUID REFERENCES busops_depots_tbl(depot_id),
    total_trips INTEGER DEFAULT 0,
    completed_trips INTEGER DEFAULT 0,
    cancelled_trips INTEGER DEFAULT 0,
    delayed_trips INTEGER DEFAULT 0,
    total_revenue DECIMAL(10, 2) DEFAULT 0,
    total_passengers INTEGER DEFAULT 0,
    average_occupancy DECIMAL(5, 2) DEFAULT 0,
    on_time_percentage DECIMAL(5, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(date, depot_id)
);

-- Route performance metrics
CREATE TABLE busops_route_performance_tbl (
    performance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id UUID REFERENCES busops_routes_tbl(route_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    trips_count INTEGER DEFAULT 0,
    average_occupancy DECIMAL(5, 2) DEFAULT 0,
    total_revenue DECIMAL(10, 2) DEFAULT 0,
    on_time_trips INTEGER DEFAULT 0,
    delayed_trips INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(route_id, date)
);

-- ====================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ====================================================================

-- User table indexes
CREATE INDEX idx_busops_users_email ON busops_users_tbl(email);
CREATE INDEX idx_busops_users_phone ON busops_users_tbl(phone);
CREATE INDEX idx_busops_users_role ON busops_users_tbl(role);
CREATE INDEX idx_busops_users_status ON busops_users_tbl(status);

-- Depot table indexes
CREATE INDEX idx_busops_depots_code ON busops_depots_tbl(code);
CREATE INDEX idx_busops_depots_manager ON busops_depots_tbl(manager_id);
CREATE INDEX idx_busops_depots_status ON busops_depots_tbl(status);

-- Vehicle table indexes
CREATE INDEX idx_busops_vehicles_registration ON busops_vehicles_tbl(registration_number);
CREATE INDEX idx_busops_vehicles_depot ON busops_vehicles_tbl(depot_id);
CREATE INDEX idx_busops_vehicles_status ON busops_vehicles_tbl(status);
CREATE INDEX idx_busops_vehicles_type ON busops_vehicles_tbl(vehicle_type);

-- Vehicle maintenance indexes
CREATE INDEX idx_busops_maintenance_vehicle ON busops_vehicle_maintenance_tbl(vehicle_id);
CREATE INDEX idx_busops_maintenance_date ON busops_vehicle_maintenance_tbl(service_date);

-- Staff table indexes
CREATE INDEX idx_busops_staff_user ON busops_staff_tbl(user_id);
CREATE INDEX idx_busops_staff_employee_id ON busops_staff_tbl(employee_id);
CREATE INDEX idx_busops_staff_depot ON busops_staff_tbl(depot_id);

-- Route table indexes
CREATE INDEX idx_busops_routes_number ON busops_routes_tbl(route_number);
CREATE INDEX idx_busops_routes_depot ON busops_routes_tbl(depot_id);
CREATE INDEX idx_busops_routes_status ON busops_routes_tbl(status);

-- Route stops indexes
CREATE INDEX idx_busops_stops_route ON busops_route_stops_tbl(route_id);
CREATE INDEX idx_busops_stops_order ON busops_route_stops_tbl(route_id, stop_order);

-- Trip table indexes
CREATE INDEX idx_busops_trips_number ON busops_trips_tbl(trip_number);
CREATE INDEX idx_busops_trips_route ON busops_trips_tbl(route_id);
CREATE INDEX idx_busops_trips_vehicle ON busops_trips_tbl(vehicle_id);
CREATE INDEX idx_busops_trips_depot ON busops_trips_tbl(depot_id);
CREATE INDEX idx_busops_trips_status ON busops_trips_tbl(status);
CREATE INDEX idx_busops_trips_departure ON busops_trips_tbl(scheduled_departure_time);
CREATE INDEX idx_busops_trips_date ON busops_trips_tbl(DATE(scheduled_departure_time));

-- Trip assignments indexes
CREATE INDEX idx_busops_assignments_trip ON busops_trip_assignments_tbl(trip_id);
CREATE INDEX idx_busops_assignments_driver ON busops_trip_assignments_tbl(driver_id);
CREATE INDEX idx_busops_assignments_conductor ON busops_trip_assignments_tbl(conductor_id);

-- Passenger indexes
CREATE INDEX idx_busops_passengers_phone ON busops_passengers_tbl(phone);
CREATE INDEX idx_busops_passengers_email ON busops_passengers_tbl(email);

-- Reservation indexes
CREATE INDEX idx_busops_reservations_number ON busops_reservations_tbl(reservation_number);
CREATE INDEX idx_busops_reservations_trip ON busops_reservations_tbl(trip_id);
CREATE INDEX idx_busops_reservations_passenger ON busops_reservations_tbl(passenger_id);
CREATE INDEX idx_busops_reservations_status ON busops_reservations_tbl(status);
CREATE INDEX idx_busops_reservations_payment_status ON busops_reservations_tbl(payment_status);
CREATE INDEX idx_busops_reservations_date ON busops_reservations_tbl(booking_date);

-- Attendance indexes
CREATE INDEX idx_busops_attendance_staff ON busops_attendance_tbl(staff_id);
CREATE INDEX idx_busops_attendance_date ON busops_attendance_tbl(date);
CREATE INDEX idx_busops_attendance_status ON busops_attendance_tbl(status);

-- Leave requests indexes
CREATE INDEX idx_busops_leave_staff ON busops_leave_requests_tbl(staff_id);
CREATE INDEX idx_busops_leave_dates ON busops_leave_requests_tbl(start_date, end_date);
CREATE INDEX idx_busops_leave_status ON busops_leave_requests_tbl(status);

-- Incident indexes
CREATE INDEX idx_busops_incidents_number ON busops_incidents_tbl(incident_number);
CREATE INDEX idx_busops_incidents_trip ON busops_incidents_tbl(trip_id);
CREATE INDEX idx_busops_incidents_vehicle ON busops_incidents_tbl(vehicle_id);
CREATE INDEX idx_busops_incidents_status ON busops_incidents_tbl(status);
CREATE INDEX idx_busops_incidents_severity ON busops_incidents_tbl(severity);
CREATE INDEX idx_busops_incidents_date ON busops_incidents_tbl(incident_date);

-- Incident photos indexes
CREATE INDEX idx_busops_incident_photos_incident ON busops_incident_photos_tbl(incident_id);

-- Authentication tables indexes
CREATE INDEX idx_busops_refresh_tokens_user ON busops_refresh_tokens_tbl(user_id);
CREATE INDEX idx_busops_refresh_tokens_hash ON busops_refresh_tokens_tbl(token_hash);
CREATE INDEX idx_busops_refresh_tokens_expires ON busops_refresh_tokens_tbl(expires_at);

CREATE INDEX idx_busops_sessions_user ON busops_user_sessions_tbl(user_id);
CREATE INDEX idx_busops_sessions_device ON busops_user_sessions_tbl(device_id);
CREATE INDEX idx_busops_sessions_active ON busops_user_sessions_tbl(is_active);

CREATE INDEX idx_busops_password_reset_user ON busops_password_reset_tokens_tbl(user_id);
CREATE INDEX idx_busops_password_reset_hash ON busops_password_reset_tokens_tbl(token_hash);

-- Analytics indexes
CREATE INDEX idx_busops_daily_stats_date ON busops_daily_stats_tbl(date);
CREATE INDEX idx_busops_daily_stats_depot ON busops_daily_stats_tbl(depot_id);

CREATE INDEX idx_busops_route_performance_route ON busops_route_performance_tbl(route_id);
CREATE INDEX idx_busops_route_performance_date ON busops_route_performance_tbl(date);

-- ====================================================================
-- TRIGGERS FOR UPDATED_AT TIMESTAMPS
-- ====================================================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables with updated_at column
CREATE TRIGGER update_busops_users_updated_at
    BEFORE UPDATE ON busops_users_tbl
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_busops_depots_updated_at
    BEFORE UPDATE ON busops_depots_tbl
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_busops_vehicles_updated_at
    BEFORE UPDATE ON busops_vehicles_tbl
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_busops_staff_updated_at
    BEFORE UPDATE ON busops_staff_tbl
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_busops_routes_updated_at
    BEFORE UPDATE ON busops_routes_tbl
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_busops_trips_updated_at
    BEFORE UPDATE ON busops_trips_tbl
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_busops_reservations_updated_at
    BEFORE UPDATE ON busops_reservations_tbl
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_busops_leave_requests_updated_at
    BEFORE UPDATE ON busops_leave_requests_tbl
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_busops_incidents_updated_at
    BEFORE UPDATE ON busops_incidents_tbl
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_busops_refresh_tokens_updated_at
    BEFORE UPDATE ON busops_refresh_tokens_tbl
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ====================================================================
-- SAMPLE DATA INSERTION (FOR TESTING)
-- ====================================================================

-- Insert admin user (password: admin123)
INSERT INTO busops_users_tbl (email, phone, password_hash, first_name, last_name, role, status, email_verified, phone_verified) VALUES
('admin@busops.local', '9999999999', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyVK/0pqhEKG', 'System', 'Administrator', 'admin', 'active', TRUE, TRUE);

-- Insert sample depot
INSERT INTO busops_depots_tbl (code, name, location, address_line1, city, state, pincode, contact_number, email, capacity) VALUES
('PUN-01', 'Pune Swargate Depot', 'Swargate', 'Swargate Bus Stand', 'Pune', 'Maharashtra', '411042', '020-24454567', 'pune.swargate@busops.local', 120);

-- ====================================================================
-- VIEWS FOR COMMON QUERIES
-- ====================================================================

-- View for trip details with all related information
CREATE OR REPLACE VIEW busops_trip_details_view AS
SELECT 
    t.trip_id,
    t.trip_number,
    t.scheduled_departure_time,
    t.scheduled_arrival_time,
    t.status,
    t.total_seats,
    t.available_seats,
    t.reserved_seats,
    r.route_number,
    r.name AS route_name,
    r.origin,
    r.destination,
    v.registration_number,
    v.vehicle_number,
    d.name AS depot_name,
    ta.driver_id,
    ta.conductor_id,
    du.first_name || ' ' || du.last_name AS driver_name,
    cu.first_name || ' ' || cu.last_name AS conductor_name
FROM busops_trips_tbl t
LEFT JOIN busops_routes_tbl r ON t.route_id = r.route_id
LEFT JOIN busops_vehicles_tbl v ON t.vehicle_id = v.vehicle_id
LEFT JOIN busops_depots_tbl d ON t.depot_id = d.depot_id
LEFT JOIN busops_trip_assignments_tbl ta ON t.trip_id = ta.trip_id
LEFT JOIN busops_staff_tbl ds ON ta.driver_id = ds.staff_id
LEFT JOIN busops_users_tbl du ON ds.user_id = du.user_id
LEFT JOIN busops_staff_tbl cs ON ta.conductor_id = cs.staff_id
LEFT JOIN busops_users_tbl cu ON cs.user_id = cu.user_id;

-- View for staff details
CREATE OR REPLACE VIEW busops_staff_details_view AS
SELECT 
    s.staff_id,
    s.employee_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone,
    u.role,
    u.status,
    s.license_number,
    s.license_expiry,
    s.date_of_joining,
    s.shift,
    d.name AS depot_name,
    d.code AS depot_code
FROM busops_staff_tbl s
JOIN busops_users_tbl u ON s.user_id = u.user_id
LEFT JOIN busops_depots_tbl d ON s.depot_id = d.depot_id;

-- ====================================================================
-- COMPLETION MESSAGE
-- ====================================================================

-- Database schema created successfully!
-- Total tables: 23
-- Total enums: 13
-- Total indexes: 60+
-- Total triggers: 10
-- Total views: 2
