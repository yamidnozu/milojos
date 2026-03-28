-- =====================================================
-- MilOjos — Seeds de desarrollo y QA (Popayán, Cauca)
-- SOLO para entorno de desarrollo local
-- =====================================================

-- =====================================================
-- 1. INSTITUCIONES EDUCATIVAS PILOTO
-- =====================================================

INSERT INTO institutions (id, name, nit, address, location, phone, rector_name, rector_email, contract_active, subscription_plan)
VALUES 
(
  'a1b2c3d4-0000-0000-0000-000000000001',
  'Institución Educativa Técnica San José',
  '891.180.091-1',
  'Carrera 9 # 9-55, Popayán, Cauca',
  ST_GeographyFromText('POINT(-76.6147 2.4448)'),
  '(602) 8243110',
  'Dr. Jorge Iván Restrepo',
  'rectoria@sanjose.edu.co',
  true,
  'institucion_basica'
),
(
  'a1b2c3d4-0000-0000-0000-000000000002',
  'Colegio Champagnat',
  '890.300.222-2',
  'Calle 15N # 6-39, Popayán, Cauca',
  ST_GeographyFromText('POINT(-76.6025 2.4510)'),
  '(602) 8334455',
  'Hno. Marista Alonso',
  'direccion@champagnat.edu.co',
  true,
  'institucion_enterprise'
),
(
  'a1b2c3d4-0000-0000-0000-000000000003',
  'Liceo Comercial El Pilar',
  '900.567.890-3',
  'Carrera 11 # 1N-20, Popayán, Cauca',
  ST_GeographyFromText('POINT(-76.6201 2.4390)'),
  '(602) 8211122',
  'Lic. Carmenza Pardo',
  'info@elpilar.edu.co',
  false,
  'free'
) ON CONFLICT DO NOTHING;

-- =====================================================
-- 2. USUARIOS (Admins, Estudiantes, Vecinos, Policías)
-- =====================================================

-- Super Admin
INSERT INTO users (id, email, full_name, role, is_active, subscription_plan)
VALUES (
  'a1b2c3d4-0000-0000-0000-000000000010',
  'superadmin@milojos.com.co',
  'Ing. Administrador MilOjos',
  'superadmin',
  true,
  'vecino_pro'
) ON CONFLICT DO NOTHING;

-- Admins de instituciones demo
INSERT INTO users (id, email, full_name, role, institution_id, is_active)
VALUES 
(
  'a1b2c3d4-0000-0000-0000-000000000011',
  'seguridad@sanjose.edu.co',
  'Coordinador Seguridad San José',
  'admin',
  'a1b2c3d4-0000-0000-0000-000000000001',
  true
),
(
  'a1b2c3d4-0000-0000-0000-000000000012',
  'monitoreo@champagnat.edu.co',
  'Operador Champagnat',
  'admin',
  'a1b2c3d4-0000-0000-0000-000000000002',
  true
) ON CONFLICT DO NOTHING;

-- Estudiante demo (San José)
INSERT INTO users (id, email, full_name, role, institution_id, is_active, consent_signed_at, consent_signed_by)
VALUES (
  'a1b2c3d4-0000-0000-0000-000000000013',
  'estudiante@demo.milojos.com.co',
  'Juan Pérez (Estudiante Demo)',
  'student',
  'a1b2c3d4-0000-0000-0000-000000000001',
  true,
  NOW(),
  'María Pérez (Madre)'
) ON CONFLICT DO NOTHING;

-- Guardián Legal (Consentimiento firmado para el estudiante local)
INSERT INTO minor_consents (id, student_id, guardian_name, guardian_id_number, institution_id, consent_text_version, signature_hash)
VALUES (
  'b2c3d4e5-0000-0000-0000-000000000001',
  'a1b2c3d4-0000-0000-0000-000000000013',
  'María Pérez',
  '34.567.890',
  'a1b2c3d4-0000-0000-0000-000000000001',
  'v1.0.HabeasData_Ley1581',
  'sha256:d87df7e743a6d71...'
) ON CONFLICT DO NOTHING;

-- Vecinos demo cerca a la Institución San José
INSERT INTO users (
  id, email, full_name, role, is_active,
  home_address, home_location, home_verified,
  subscription_plan, subscription_valid_until
)
VALUES 
(
  'a1b2c3d4-0000-0000-0000-000000000014',
  'vecino.pro@demo.milojos.com.co',
  'Carlos (Vecino Líder PRO)',
  'neighbor',
  true,
  'Carrera 9 # 10-02, Popayán',
  ST_GeographyFromText('POINT(-76.6145 2.4446)'), -- Muy cerca a San José (Rádio <500m)
  true,
  'vecino_pro',
  NOW() + INTERVAL '30 days'
),
(
  'a1b2c3d4-0000-0000-0000-000000000015',
  'vecino.basico@demo.milojos.com.co',
  'Ana (Vecina Básica)',
  'neighbor',
  true,
  'Calle 8 # 8-15, Popayán',
  ST_GeographyFromText('POINT(-76.6130 2.4460)'), -- Cerca a San José
  true,
  'vecino_basico',
  NOW() + INTERVAL '30 days'
) ON CONFLICT DO NOTHING;

-- =====================================================
-- 3. CÁMARAS IP (SIMULADAS / Sprint 2 Preview)
-- =====================================================

INSERT INTO cameras (id, owner_id, institution_id, name, rtsp_url_encrypted, location, address_hint, is_active, stream_access_radius_meters)
VALUES 
-- Cámara Institucional en Rectoría San José (Apunta a la Calle 9)
(
  'c3d4e5f6-0000-0000-0000-000000000001',
  'a1b2c3d4-0000-0000-0000-000000000011', -- Dueño: Admin San José
  'a1b2c3d4-0000-0000-0000-000000000001', -- Inst: San José
  'Cámara Exterior Principal San José',
  'pgp_sym_encrypt(''rtsp://admin:pass123@192.168.1.100:554/stream1'', ''milojos_secret'')',
  ST_GeographyFromText('POINT(-76.6147 2.4448)'),
  'Cámara del portón principal de estudiantes Carrera 9',
  true,
  500
),
-- Cámara Comunitaria Vecino Líder PRO (Apunta al Parque Cerca a San José)
(
  'c3d4e5f6-0000-0000-0000-000000000002',
  'a1b2c3d4-0000-0000-0000-000000000014', -- Dueño: Vecino PRO Carlos
  NULL,
  'Cámara Esquina Parque El Carmen',
  'pgp_sym_encrypt(''rtsp://vecino:seguro456@192.168.1.150:554/onvif'', ''milojos_secret'')',
  ST_GeographyFromText('POINT(-76.6145 2.4446)'),
  'Cámara balcón piso 2 enfocando la bajada al colegio',
  true,
  300
) ON CONFLICT DO NOTHING;
