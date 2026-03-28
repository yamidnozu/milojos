-- =====================================================
-- MilOjos — Seeds de desarrollo
-- SOLO para entorno de desarrollo local
-- =====================================================

-- Institución piloto (San José, Popayán)
INSERT INTO institutions (id, name, nit, address, location, rector_name, contract_active, subscription_plan)
VALUES (
  'a1b2c3d4-0000-0000-0000-000000000001',
  'Institución Educativa San José',
  '891.180.091-1',
  'Carrera 9 # 9-55, Popayán, Cauca',
  ST_GeographyFromText('POINT(-76.6147 2.4448)'),
  'Rector Demo',
  true,
  'institucion_basica'
) ON CONFLICT DO NOTHING;

-- Super Admin
INSERT INTO users (id, email, full_name, role, is_active, subscription_plan)
VALUES (
  'a1b2c3d4-0000-0000-0000-000000000010',
  'superadmin@milojos.com.co',
  'Super Admin MilOjos',
  'superadmin',
  true,
  'vecino_pro'
) ON CONFLICT DO NOTHING;

-- Admin de institución demo
INSERT INTO users (id, email, full_name, role, institution_id, is_active)
VALUES (
  'a1b2c3d4-0000-0000-0000-000000000011',
  'admin@sanjose.edu.co',
  'Admin San José Demo',
  'admin',
  'a1b2c3d4-0000-0000-0000-000000000001',
  true
) ON CONFLICT DO NOTHING;

-- Estudiante demo
INSERT INTO users (id, email, full_name, role, institution_id, is_active, consent_signed_at)
VALUES (
  'a1b2c3d4-0000-0000-0000-000000000012',
  'estudiante@demo.milojos.com.co',
  'Estudiante Demo',
  'student',
  'a1b2c3d4-0000-0000-0000-000000000001',
  true,
  NOW()
) ON CONFLICT DO NOTHING;

-- Vecino demo con suscripción activa
INSERT INTO users (
  id, email, full_name, role, is_active,
  home_address, home_location, home_verified,
  subscription_plan, subscription_valid_until
)
VALUES (
  'a1b2c3d4-0000-0000-0000-000000000013',
  'vecino@demo.milojos.com.co',
  'Vecino Demo Popayán',
  'neighbor',
  true,
  'Calle 5 # 8-45, Popayán',
  ST_GeographyFromText('POINT(-76.6130 2.4460)'),
  true,
  'vecino_basico',
  NOW() + INTERVAL '30 days'
) ON CONFLICT DO NOTHING;
