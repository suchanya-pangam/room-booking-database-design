-- Room Booking Database Design
-- PostgreSQL 14+ schema derived from docs/room-booking-erd.drawio.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE CHECK (email ~* '^[^@]+@gmail\\.com$'),
  full_name TEXT NOT NULL,
  user_type TEXT NOT NULL,
  role TEXT NOT NULL,
  phone TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  email_verified_at TIMESTAMPTZ,
  last_login_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE student_profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  student_id TEXT NOT NULL UNIQUE,
  entry_year SMALLINT,
  current_academic_year SMALLINT,
  current_year_level SMALLINT,
  student_status TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_code TEXT NOT NULL UNIQUE,
  room_name TEXT NOT NULL,
  location TEXT NOT NULL,
  capacity INTEGER NOT NULL CHECK (capacity > 0),
  description TEXT,
  status TEXT NOT NULL,
  opens_at TIME,
  closes_at TIME,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  booking_policy TEXT NOT NULL DEFAULT 'Bookings are allowed Monday-Friday, 08:30-16:30, with at least 3 business days advance notice. Outside-hours requests require administrator contact.'
);

CREATE TABLE login_challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  code_hash TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ,
  attempt_count INTEGER NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  invalidated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES rooms(id),
  user_id UUID NOT NULL REFERENCES users(id),
  public_title TEXT NOT NULL,
  purpose TEXT NOT NULL,
  attendee_count INTEGER NOT NULL CHECK (attendee_count > 0),
  contact_phone TEXT,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL,
  note TEXT,
  cancelled_by UUID REFERENCES users(id),
  cancelled_at TIMESTAMPTZ,
  cancel_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (end_at > start_at)
);

CREATE TABLE booking_decisions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  decided_by UUID NOT NULL REFERENCES users(id),
  decision TEXT NOT NULL CHECK (decision IN ('APPROVED', 'REJECTED')),
  reason TEXT,
  decided_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE equipment_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE equipment_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  equipment_type_id UUID NOT NULL REFERENCES equipment_types(id),
  asset_code TEXT NOT NULL UNIQUE,
  home_room_id UUID REFERENCES rooms(id) ON DELETE SET NULL,
  is_movable BOOLEAN NOT NULL DEFAULT TRUE,
  condition_status TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE booking_equipment_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  equipment_type_id UUID NOT NULL REFERENCES equipment_types(id),
  quantity_requested INTEGER NOT NULL CHECK (quantity_requested > 0),
  note TEXT,
  UNIQUE (booking_id, equipment_type_id)
);

CREATE TABLE equipment_loans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES booking_equipment_requests(id),
  equipment_item_id UUID NOT NULL REFERENCES equipment_items(id),
  status TEXT NOT NULL,
  issued_at TIMESTAMPTZ,
  issued_by UUID REFERENCES users(id),
  return_reported_at TIMESTAMPTZ,
  return_reported_by UUID REFERENCES users(id),
  received_at TIMESTAMPTZ,
  received_by UUID REFERENCES users(id),
  condition_on_return TEXT,
  note TEXT
);

CREATE TABLE issue_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID REFERENCES rooms(id) ON DELETE SET NULL,
  equipment_item_id UUID REFERENCES equipment_items(id) ON DELETE SET NULL,
  reporter_id UUID NOT NULL REFERENCES users(id),
  issue_type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT NOT NULL,
  source TEXT NOT NULL DEFAULT 'SYSTEM' CHECK (source IN ('SYSTEM', 'GOOGLE_FORM')),
  external_response_id TEXT UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (room_id IS NOT NULL OR equipment_item_id IS NOT NULL)
);

CREATE TABLE issue_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  issue_id UUID NOT NULL REFERENCES issue_reports(id) ON DELETE CASCADE,
  storage_key TEXT NOT NULL UNIQUE,
  original_filename TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  uploaded_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE issue_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  issue_id UUID NOT NULL REFERENCES issue_reports(id) ON DELETE CASCADE,
  from_status TEXT,
  to_status TEXT NOT NULL,
  changed_by UUID NOT NULL REFERENCES users(id),
  note TEXT,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE activity_requirements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  completion_criteria TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requirement_id UUID NOT NULL REFERENCES activity_requirements(id),
  title TEXT NOT NULL,
  description TEXT,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ NOT NULL,
  location TEXT,
  booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
  status TEXT NOT NULL,
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (end_at > start_at)
);

CREATE TABLE activity_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  attendance_status TEXT NOT NULL,
  result_status TEXT,
  verified_by UUID REFERENCES users(id),
  verified_at TIMESTAMPTZ,
  note TEXT,
  UNIQUE (activity_id, user_id)
);

CREATE TABLE student_requirements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  requirement_id UUID NOT NULL REFERENCES activity_requirements(id),
  status TEXT NOT NULL,
  source_participation_id UUID REFERENCES activity_participants(id) ON DELETE SET NULL,
  verified_by UUID REFERENCES users(id),
  verified_at TIMESTAMPTZ,
  note TEXT,
  UNIQUE (user_id, requirement_id)
);

CREATE TABLE calendar_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  calendar_email TEXT NOT NULL DEFAULT 'ds_calendar@gmail.com' CHECK (calendar_email = 'ds_calendar@gmail.com'),
  calendar_account_id TEXT NOT NULL,
  calendar_id TEXT NOT NULL,
  granted_scopes TEXT[] NOT NULL DEFAULT '{}',
  status TEXT NOT NULL,
  connected_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  revoked_at TIMESTAMPTZ,
  credential_secret_ref TEXT NOT NULL,
  UNIQUE (calendar_email, calendar_id)
);

CREATE TABLE calendar_event_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  connection_id UUID NOT NULL REFERENCES calendar_connections(id) ON DELETE CASCADE,
  google_event_id TEXT NOT NULL,
  sync_status TEXT NOT NULL,
  last_synced_at TIMESTAMPTZ,
  last_error TEXT,
  UNIQUE (connection_id, google_event_id)
);

CREATE TABLE notification_deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  activity_id UUID REFERENCES activities(id) ON DELETE CASCADE,
  channel TEXT NOT NULL,
  notification_type TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  status TEXT NOT NULL,
  deduplication_key TEXT NOT NULL UNIQUE,
  last_error TEXT
);

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  before_data JSONB,
  after_data JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX bookings_room_time_idx ON bookings (room_id, start_at, end_at);
CREATE INDEX bookings_user_idx ON bookings (user_id);
CREATE INDEX issue_reports_status_idx ON issue_reports (status);
CREATE INDEX activities_requirement_idx ON activities (requirement_id);
CREATE INDEX notification_deliveries_pending_idx ON notification_deliveries (status, scheduled_at);
CREATE INDEX audit_logs_actor_created_idx ON audit_logs (actor_id, created_at DESC);

COMMIT;
