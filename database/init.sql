-- =====================================================
-- MilOjos — Schema inicial de PostgreSQL + PostGIS
-- Sprint 0 — 2026-03-28
-- Ejecutar en orden: 01_init.sql
-- =====================================================

-- Habilitar extensiones
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── ENUM: Roles de usuario ───
CREATE TYPE user_role AS ENUM (
  'student',
  'neighbor',
  'admin',
  'police',
  'superadmin'
);

-- ─── ENUM: Estado de alerta ───
CREATE TYPE alert_status AS ENUM (
  'active',
  'resolved',
  'false_alarm',
  'cancelled'
);

-- ─── ENUM: Plan de suscripción ───
CREATE TYPE subscription_plan AS ENUM (
  'free',
  'vecino_basico',
  'vecino_pro',
  'institucion_basica',
  'institucion_enterprise'
);

-- ─── Tabla: Instituciones educativas ───
CREATE TABLE IF NOT EXISTS institutions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                TEXT NOT NULL,
  nit                 TEXT UNIQUE NOT NULL,
  address             TEXT,
  location            GEOGRAPHY(POINT, 4326),
  phone               TEXT,
  rector_name         TEXT,
  rector_email        TEXT,
  contract_active     BOOLEAN DEFAULT false,
  contract_start_date DATE,
  contract_end_date   DATE,
  subscription_plan   subscription_plan DEFAULT 'free',
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Tabla: Usuarios (todos los roles) ───
CREATE TABLE IF NOT EXISTS users (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email                       TEXT UNIQUE,
  phone                       TEXT,
  phone_verified              BOOLEAN DEFAULT false,
  full_name                   TEXT NOT NULL,
  role                        user_role NOT NULL DEFAULT 'neighbor',
  institution_id              UUID REFERENCES institutions(id) ON DELETE SET NULL,
  -- Suscripción
  subscription_plan           subscription_plan DEFAULT 'free',
  subscription_valid_until    TIMESTAMPTZ,
  google_play_purchase_token  TEXT,                            -- token de Google Play Billing
  -- Estado de cuenta
  is_active                   BOOLEAN DEFAULT false,
  consent_signed_at           TIMESTAMPTZ,
  consent_signed_by           TEXT,                            -- para menores: nombre del padre/tutor
  -- Verificación domicilio (vecinos)
  home_address                TEXT,
  home_location               GEOGRAPHY(POINT, 4326),
  home_verified               BOOLEAN DEFAULT false,
  home_photo_url              TEXT,
  -- Contadores de falsa alarma
  false_alarm_count_last_hour INTEGER DEFAULT 0,
  last_false_alarm_at         TIMESTAMPTZ,
  temporarily_blocked_until   TIMESTAMPTZ,
  -- Auditoría
  last_login_at               TIMESTAMPTZ,
  created_at                  TIMESTAMPTZ DEFAULT NOW(),
  updated_at                  TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Tabla: Alertas de pánico ───
CREATE TABLE IF NOT EXISTS panic_alerts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id),
  location        GEOGRAPHY(POINT, 4326) NOT NULL,
  photo_url       TEXT,                                        -- URL firmada S3, expira en 90 días
  photo_expires_at TIMESTAMPTZ,
  status          alert_status NOT NULL DEFAULT 'active',
  triggered_at    TIMESTAMPTZ DEFAULT NOW(),
  resolved_at     TIMESTAMPTZ,
  resolved_by     UUID REFERENCES users(id),
  responders      UUID[] DEFAULT '{}',                         -- IDs que respondieron
  notes           TEXT                                         -- notas al resolver
);

-- ─── Tabla: Cámaras IP registradas ───
CREATE TABLE IF NOT EXISTS cameras (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id                    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name                        TEXT NOT NULL DEFAULT 'Mi cámara',
  rtsp_url_encrypted          TEXT NOT NULL,                   -- cifrado con pgcrypto, nunca expuesto
  location                    GEOGRAPHY(POINT, 4326),
  address_hint                TEXT,                            -- descripción "esquina calle 5 con 8"
  is_active                   BOOLEAN DEFAULT true,
  is_verified                 BOOLEAN DEFAULT false,
  stream_access_radius_meters INTEGER DEFAULT 500,
  last_seen_at                TIMESTAMPTZ,
  -- Para cámaras institucionales
  institution_id              UUID REFERENCES institutions(id),
  created_at                  TIMESTAMPTZ DEFAULT NOW(),
  updated_at                  TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Tabla: Log de acceso a cámaras (INMUTABLE — sin UPDATE/DELETE) ───
-- Política: solo INSERT, jamás UPDATE ni DELETE
CREATE TABLE IF NOT EXISTS camera_access_log (
  id              BIGSERIAL PRIMARY KEY,
  camera_id       UUID NOT NULL REFERENCES cameras(id),
  accessed_by     UUID NOT NULL REFERENCES users(id),
  access_reason   TEXT NOT NULL CHECK (access_reason IN ('emergency_alert', 'police_request', 'owner_test')),
  alert_id        UUID REFERENCES panic_alerts(id),
  session_started TIMESTAMPTZ DEFAULT NOW(),
  session_ended   TIMESTAMPTZ
  -- SIN columnas modificables — registro inmutable (Compliance ADR)
);

-- ─── Tabla: Consentimientos de menores ───
CREATE TABLE IF NOT EXISTS minor_consents (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id          UUID NOT NULL REFERENCES users(id),
  guardian_name       TEXT NOT NULL,
  guardian_id_number  TEXT NOT NULL,
  guardian_email      TEXT,
  guardian_phone      TEXT,
  institution_id      UUID NOT NULL REFERENCES institutions(id),
  consent_text_version TEXT NOT NULL,                          -- versión del formulario firmado
  signed_at           TIMESTAMPTZ DEFAULT NOW(),
  ip_address          TEXT,
  signature_hash      TEXT NOT NULL,                           -- hash del documento firmado
  revoked_at          TIMESTAMPTZ,
  revocation_reason   TEXT
);

-- ─── INDICES geoespaciales (críticos para performance) ───
CREATE INDEX IF NOT EXISTS idx_alerts_location ON panic_alerts USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_alerts_status ON panic_alerts(status) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_cameras_location ON cameras USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_cameras_active ON cameras(owner_id) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_institution ON users(institution_id);
CREATE INDEX IF NOT EXISTS idx_users_subscription ON users(subscription_valid_until);
CREATE INDEX IF NOT EXISTS idx_camera_log_camera ON camera_access_log(camera_id);
CREATE INDEX IF NOT EXISTS idx_camera_log_alert ON camera_access_log(alert_id);

-- ─── FUNCIÓN: Vecinos en radio de alerta ───
CREATE OR REPLACE FUNCTION get_neighbors_in_radius(
  alert_location    GEOGRAPHY,
  radius_meters     INTEGER DEFAULT 500
)
RETURNS TABLE(
  user_id         UUID,
  distance_meters FLOAT,
  fcm_token       TEXT
) AS $$
  SELECT
    u.id,
    ST_Distance(u.home_location, alert_location) AS distance_meters,
    NULL::TEXT AS fcm_token  -- Se obtiene de Supabase Auth / Firebase
  FROM users u
  WHERE
    u.role = 'neighbor'
    AND u.is_active = true
    AND u.subscription_valid_until > NOW()
    AND u.home_location IS NOT NULL
    AND ST_DWithin(u.home_location, alert_location, radius_meters)
  ORDER BY distance_meters ASC;
$$ LANGUAGE SQL STABLE;

-- ─── FUNCIÓN: Cámaras disponibles en radio de alerta ───
CREATE OR REPLACE FUNCTION get_cameras_in_radius(
  alert_location    GEOGRAPHY,
  radius_meters     INTEGER DEFAULT 500
)
RETURNS TABLE(
  camera_id       UUID,
  owner_id        UUID,
  name            TEXT,
  distance_meters FLOAT
) AS $$
  SELECT
    c.id,
    c.owner_id,
    c.name,
    ST_Distance(c.location, alert_location) AS distance_meters
  FROM cameras c
  WHERE
    c.is_active = true
    AND c.location IS NOT NULL
    AND ST_DWithin(c.location, alert_location, radius_meters)
  ORDER BY distance_meters ASC;
$$ LANGUAGE SQL STABLE;

-- ─── TRIGGER: prevent UPDATE/DELETE on camera_access_log ───
CREATE OR REPLACE FUNCTION prevent_log_modification()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'El log de acceso a cámaras es inmutable. Operación % no permitida.', TG_OP;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER immutable_camera_access_log_update
  BEFORE UPDATE ON camera_access_log
  FOR EACH ROW EXECUTE FUNCTION prevent_log_modification();

CREATE TRIGGER immutable_camera_access_log_delete
  BEFORE DELETE ON camera_access_log
  FOR EACH ROW EXECUTE FUNCTION prevent_log_modification();

-- ─── TRIGGER: updated_at automático ───
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER institutions_updated_at BEFORE UPDATE ON institutions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER cameras_updated_at BEFORE UPDATE ON cameras
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─── ROW LEVEL SECURITY: Políticas de acceso ───
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE cameras ENABLE ROW LEVEL SECURITY;
ALTER TABLE panic_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE camera_access_log ENABLE ROW LEVEL SECURITY;

-- Las políticas RLS se gestionan vía Supabase Dashboard y se documentan en /docs/architecture/rls_policies.md
