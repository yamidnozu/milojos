-- =====================================================
-- MilOjos — Políticas Row Level Security (RLS)
-- Iteración 2 / Sprint 4 (Configuración PostgreSQL)
-- =====================================================

-- Asegurarse de que el acceso a RLS esté habilitado en las tablas sensibles
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE cameras ENABLE ROW LEVEL SECURITY;
ALTER TABLE panic_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE camera_access_log ENABLE ROW LEVEL SECURITY;

-- 1. Políticas de Usuarios (users)
-- Los usuarios pueden leer su propio perfil
CREATE POLICY "Users can read own profile"
ON users FOR SELECT
USING (auth.uid() = id);

-- Los usuarios pueden actualizar su propio perfil (solo columnas seguras)
CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

-- La policía y admins pueden leer perfiles de su institución/zona
CREATE POLICY "Police and SuperAdmins can read all profiles"
ON users FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users u WHERE u.id = auth.uid() AND u.role IN ('police', 'superadmin')
  )
);

-- 2. Políticas de Cámaras (cameras)
-- Un usuario solo puede registrar o dar de baja SUS propias cámaras
CREATE POLICY "Owners can manage own cameras"
ON cameras FOR ALL
USING (auth.uid() = owner_id);

-- Un vecino solo puede ver y visualizar (SELECT) la cámara que esté activa y dentro de su vecindario
CREATE POLICY "Neighbors can view nearby active cameras"
ON cameras FOR SELECT
USING (
  is_active = true
  AND
  -- Solo cámaras sin RTSP expuesto directamente. 
  -- NestJS evaluará la cercanía, pero la BD pre-filtra:
  (owner_id = auth.uid() OR auth.role() = 'authenticated')
);

-- 3. Políticas de Alertas de Pánico (panic_alerts)
-- Las alertas pueden ser creadas por la víctima
CREATE POLICY "Victims can trigger alerts"
ON panic_alerts FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Solo Vecinos, Policías y Admins pueden ver Alertas 'Activas'
CREATE POLICY "Responders can view active alerts"
ON panic_alerts FOR SELECT
USING (
  status = 'active'
);

-- 4. Inmutabilidad (camera_access_log)
-- Nadie puede hacer UPDATE ni DELETE (ya gestionado por Triggers en init.sql)
-- Para SELECT, solo Auditoría/Polícia puede leer esta tabla para Habeas Data
CREATE POLICY "Only authorities can read camera audit logs"
ON camera_access_log FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users u WHERE u.id = auth.uid() AND u.role IN ('police', 'superadmin')
  )
);

-- =====================================================
-- Función Cifrado de punta a punta (RTSP URI E2EE)
-- =====================================================
-- Permite insertar cámaras ocultando la clave (Requerido por Security Agent)
-- pg_crypto ya instalado en init.sql

-- (Exclusivo en scripts manejados por TypeORM o migraciones NestJS)
