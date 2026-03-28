# INFORME #1 — Agente Arquitecto de Software (Architect Agent)
**Proyecto MilOjos · Fecha: 2026-03-28 · Estado: ACTIVO**

---

## DECLARACION DE ACTIVACION

El Agente Arquitecto está operativo. Este informe define la arquitectura técnica
completa de MilOjos. Ninguna decisión de infraestructura, protocolo o dependencia
mayor puede tomarse sin pasar por este agente. Todas las decisiones aquí son
Architecture Decision Records (ADRs) formales.

---

## ADR-001: ARQUITECTURA GENERAL — Clean Architecture

### Decision
Adoptar **Clean Architecture** con separación estricta en 3 capas para la app Flutter.

### Estructura de Directorios del Proyecto Flutter

```
lib/
├── core/
│   ├── constants/
│   ├── errors/          # Failures y Exceptions
│   ├── network/         # Dio client, interceptors
│   ├── usecase/         # UseCase<T, P> base abstract
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/    # remote_data_source.dart, local_data_source.dart
│   │   │   ├── models/         # user_model.dart (extends UserEntity)
│   │   │   └── repositories/   # auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/       # user_entity.dart (pure Dart)
│   │   │   ├── repositories/   # auth_repository.dart (abstract)
│   │   │   └── usecases/       # login_usecase.dart, register_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/           # auth_bloc.dart, auth_event.dart, auth_state.dart
│   │       ├── pages/          # login_page.dart, register_page.dart
│   │       └── widgets/
│   │
│   ├── panic_alert/
│   │   ├── data/
│   │   │   ├── datasources/    # alert_remote_source.dart
│   │   │   ├── models/         # alert_model.dart
│   │   │   └── repositories/   # alert_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/       # alert_entity.dart
│   │   │   ├── repositories/   # alert_repository.dart (abstract)
│   │   │   └── usecases/
│   │   │       ├── trigger_panic_alert_usecase.dart   ← PRIORITARIO
│   │   │       └── cancel_alert_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/           # panic_bloc.dart
│   │       ├── pages/          # panic_confirmation_page.dart
│   │       └── widgets/        # shake_detector_widget.dart
│   │
│   ├── cameras/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── subscriptions/          # Google Pay integration
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── injection_container.dart     # GetIt DI setup
└── main.dart
```

### Reglas de Dependencia (INVIOLABLES)
```
Presentation → solo puede importar de: domain/
Data         → solo puede importar de: domain/
Domain       → NO puede importar nada de Flutter framework

PROHIBIDO:
  domain/ importar packages Flutter (solo dart:core)
  data/ importar widgets de presentation/
  Uso de BuildContext fuera de presentation/
```

---

## ADR-002: BACKEND — NestJS con Arquitectura Modular

### Estructura del Backend

```
backend/
├── src/
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.module.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   └── strategies/          # JWT, Supabase strategy
│   │   │
│   │   ├── alerts/
│   │   │   ├── alerts.module.ts
│   │   │   ├── alerts.controller.ts
│   │   │   ├── alerts.service.ts
│   │   │   ├── alerts.gateway.ts    # WebSocket Gateway (Socket.io)
│   │   │   └── dto/
│   │   │       ├── create-alert.dto.ts
│   │   │       └── alert-response.dto.ts
│   │   │
│   │   ├── cameras/
│   │   │   ├── cameras.module.ts
│   │   │   ├── cameras.controller.ts
│   │   │   ├── cameras.service.ts
│   │   │   └── mediasoup/           # WebRTC SFU integration
│   │   │
│   │   ├── users/
│   │   ├── subscriptions/           # Google Pay webhooks
│   │   └── notifications/           # FCM integration
│   │
│   ├── common/
│   │   ├── guards/                  # JwtAuthGuard, RolesGuard
│   │   ├── decorators/              # @CurrentUser(), @Roles()
│   │   ├── interceptors/            # LoggingInterceptor, TransformInterceptor
│   │   └── filters/                 # GlobalExceptionFilter
│   │
│   ├── database/
│   │   ├── migrations/
│   │   └── seeds/
│   │
│   ├── app.module.ts
│   └── main.ts
│
├── test/
│   ├── unit/
│   └── e2e/
│
├── Dockerfile
└── docker-compose.yml
```

---

## ADR-003: BASE DE DATOS — PostgreSQL 16 + PostGIS

### Schema Principal

```sql
-- Usuarios (todos los roles)
CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         TEXT UNIQUE NOT NULL,
  phone         TEXT,                           -- cifrado con pgcrypto
  role          TEXT NOT NULL CHECK (role IN ('student','neighbor','admin','police','superadmin')),
  institution_id UUID REFERENCES institutions(id),
  subscription_plan TEXT,                       -- 'basic','pro','institution_basic','institution_enterprise'
  google_pay_subscription_id TEXT,              -- token Google Play Billing
  is_active     BOOLEAN DEFAULT false,          -- false hasta consentimiento completo
  consent_signed_at TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Instituciones
CREATE TABLE institutions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  nit           TEXT UNIQUE NOT NULL,
  address       TEXT,
  location      GEOGRAPHY(POINT, 4326),         -- PostGIS
  contract_active BOOLEAN DEFAULT false,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Alertas de panico
CREATE TABLE panic_alerts (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id),
  location      GEOGRAPHY(POINT, 4326) NOT NULL,
  photo_url     TEXT,                           -- URL firmada S3, expira en 90 dias
  status        TEXT CHECK (status IN ('active','resolved','false_alarm')),
  triggered_at  TIMESTAMPTZ DEFAULT NOW(),
  resolved_at   TIMESTAMPTZ,
  responders    UUID[]                          -- IDs de usuarios que respondieron
);

-- Camaras IP registradas
CREATE TABLE cameras (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id      UUID NOT NULL REFERENCES users(id),
  rtsp_url_encrypted TEXT NOT NULL,            -- cifrado, nunca expuesto al cliente
  name          TEXT,
  location      GEOGRAPHY(POINT, 4326),
  is_active     BOOLEAN DEFAULT true,
  stream_access_radius_meters INTEGER DEFAULT 500,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Log de acceso a camaras (INMUTABLE — sin UPDATE/DELETE)
CREATE TABLE camera_access_log (
  id            BIGSERIAL PRIMARY KEY,
  camera_id     UUID NOT NULL REFERENCES cameras(id),
  accessed_by   UUID NOT NULL REFERENCES users(id),
  access_reason TEXT,                          -- 'emergency_alert', 'police_request'
  alert_id      UUID REFERENCES panic_alerts(id),
  accessed_at   TIMESTAMPTZ DEFAULT NOW()
  -- SIN columnas modificables después de INSERT
);

-- Indice geoespacial para consultas de proximidad
CREATE INDEX idx_alerts_location ON panic_alerts USING GIST(location);
CREATE INDEX idx_cameras_location ON cameras USING GIST(location);
CREATE INDEX idx_users_institution ON users(institution_id);

-- Funcion para encontrar vecinos en radio de alerta
CREATE OR REPLACE FUNCTION get_neighbors_in_radius(
  alert_location GEOGRAPHY,
  radius_meters INTEGER DEFAULT 500
)
RETURNS TABLE(user_id UUID, distance_meters FLOAT) AS $$
  SELECT u.id, ST_Distance(c.location, alert_location) AS distance
  FROM users u
  JOIN cameras c ON c.owner_id = u.id
  WHERE ST_DWithin(c.location, alert_location, radius_meters)
    AND u.role = 'neighbor'
    AND u.is_active = true
  ORDER BY distance;
$$ LANGUAGE SQL;
```

---

## ADR-004: SISTEMA DE ALERTAS — WebSocket + FCM

### Flujo Técnico Detallado

```
FLUTTER APP                    NESTJS BACKEND              SERVICIOS EXTERNOS
    │                               │                              │
    │  1. shake detectado           │                              │
    │  2. foto + GPS capturados     │                              │
    │                               │                              │
    │──── WebSocket emit ──────────►│                              │
    │  { userId, latitude,          │                              │
    │    longitude, photoBase64,    │                              │
    │    timestamp }                │                              │
    │                               │                              │
    │                    3. guardar en PostgreSQL                  │
    │                    4. consultar PostGIS                      │
    │                       (vecinos en radio 500m)                │
    │                               │                              │
    │                               │──── FCM ────────────────────►│
    │                               │  [vecinos cercanos]          │ FCM entrega
    │                               │  [admin institución]         │ push a devices
    │                               │  [policía jurisdicción]      │
    │                               │                              │
    │◄── WebSocket ack ─────────────│                              │
    │  { alertId, status: 'sent',   │                              │
    │    respondersCount: N }        │                              │
    │                               │                              │
    │  5. mostrar pantalla          │                              │
    │    "AYUDA EN CAMINO"          │                              │
```

### AlertsGateway (WebSocket NestJS)
```typescript
@WebSocketGateway({ namespace: '/alerts', cors: true })
@UseGuards(WsJwtGuard)
export class AlertsGateway {
  @WebSocketServer() server: Server;

  @SubscribeMessage('panic_trigger')
  async handlePanicTrigger(
    @ConnectedSocket() client: Socket,
    @MessageBody() dto: CreateAlertDto,
  ): Promise<void> {
    // 1. Guardar alerta en PostgreSQL
    const alert = await this.alertsService.createAlert(dto);
    // 2. Consultar vecinos en radio (PostGIS)
    const neighbors = await this.alertsService.getNeighborsInRadius(
      dto.latitude, dto.longitude, 500
    );
    // 3. Enviar FCM a vecinos, policía y admin
    await this.notificationsService.sendEmergencyPush(alert, neighbors);
    // 4. Confirmar al cliente
    client.emit('panic_confirmed', { alertId: alert.id, respondersCount: neighbors.length });
  }
}
```

---

## ADR-005: VIDEO — Mediasoup SFU + RTSP Bridge

### Arquitectura del Sistema de Video

```
CAMARA IP (RTSP)
      │
      ▼
FFmpeg Transcoder
(rtsp → RTP/H264)     ← Corre en el mismo servidor que Mediasoup
      │
      ▼
Mediasoup SFU
  ┌──────────────────┐
  │  Worker          │  ← Proceso Node.js dedicado
  │  Router          │  ← Uno por "sala" de emergencia
  │  Producer        │  ← Stream de la cámara
  │  Consumer        │  ← Un Consumer por cada viewer
  └──────────────────┘
      │
      ▼ WebRTC (DTLS + SRTP)
Flutter App (viewer)
  flutter_webrtc plugin
```

### Flujo de Inicio de Visualización de Cámara
```
1. Alert activa → Backend inicia sesión Mediasoup
2. Backend ejecuta: ffmpeg -i rtsp://[ENCRYPTED_URL] -vcodec copy rtp://mediasoup_address
3. Flutter recibe: { sessionId, iceServers, sdpOffer }
4. Flutter responde con sdpAnswer → WebRTC conectado
5. Al resolver alerta: backend termina sesión Mediasoup + log de acceso
```

### Servidores TURN/STUN Requeridos (NAT Traversal)
```
# Para Colombia / Claro / ETB / Movistar
stun.l.google.com:19302          ← STUN gratuito (desarrollo)
turn.milojos.com.co:3478        ← TURN propio (produccion OBLIGATORIO)
turn.milojos.com.co:5349        ← TURN sobre TLS
```

---

## ADR-006: GOOGLE PAY — Integración Técnica

### Estrategia: Google Play Billing (In-App Subscriptions)

**Decisión clave:** Usar **Google Play Billing** (no Google Pay directo) para suscripciones
recurrentes en la app Android. Google Pay se usa para el checkout, pero el sistema de
suscripción es gestionado por la Play Store.

```
┌─────────────────────────────────────────────────────────┐
│  FLUTTER APP (Android)                                  │
│                                                         │
│  in_app_purchase plugin                                 │
│  ↓                                                      │
│  Google Play Billing Library                            │
│  ↓                                                      │
│  Usuario elige plan → Google Pay sheet aparece          │
│  ↓                                                      │
│  Google confirma pago → PurchaseDetails.purchaseToken   │
│  ↓                                                      │
│  App envía purchaseToken al Backend                     │
└─────────────────────────────────────────────────────────┘
          │
          ▼ POST /subscriptions/verify
┌─────────────────────────────────────────────────────────┐
│  NESTJS BACKEND                                         │
│                                                         │
│  Google Play Developer API (googleapis npm)             │
│  ↓                                                      │
│  Verifica purchaseToken con Google                      │
│  ↓                                                      │
│  Si válido: actualiza subscription_plan en PostgreSQL   │
│  + Actualiza Firebase Custom Claims del usuario         │
│  ↓                                                      │
│  Responde 200 OK con nuevo plan activo                  │
└─────────────────────────────────────────────────────────┘
          │
          ▼ (Google → Backend, cada renovacion)
┌─────────────────────────────────────────────────────────┐
│  Google Play Real-time Developer Notifications           │
│  (Pub/Sub webhook)                                      │
│                                                         │
│  Eventos manejados:                                     │
│  → SUBSCRIPTION_RENEWED: extender plan                  │
│  → SUBSCRIPTION_CANCELED: degradar a free               │
│  → SUBSCRIPTION_EXPIRED: bloquear acceso                │
│  → SUBSCRIPTION_REVOKED: eliminar acceso inmediatamente  │
└─────────────────────────────────────────────────────────┘
```

### SKUs de Google Play a Crear
```
milojos.vecino.basico.monthly     → COP $15,000/mes
milojos.vecino.pro.monthly        → COP $25,000/mes
milojos.institucion.basica.monthly → COP $150,000/mes
milojos.institucion.enterprise.monthly → COP $350,000/mes
```

### Nota sobre iOS
Para iOS se requerirá **StoreKit / Apple In-App Purchase** en el futuro. El plugin
`in_app_purchase` de Flutter maneja ambas plataformas con la misma API.

---

## ADR-007: INFRAESTRUCTURA — Docker + Railway

### docker-compose.yml para Desarrollo

```yaml
version: '3.9'

services:
  postgres:
    image: postgis/postgis:16-3.4
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: milojos_dev
      POSTGRES_USER: milojos
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --requirepass ${REDIS_PASSWORD}

  mediasoup:
    build: ./mediasoup-server
    ports:
      - "3001:3001"
      - "10000-10100:10000-10100/udp"   # RTP ports
    environment:
      MEDIASOUP_ANNOUNCED_IP: ${SERVER_PUBLIC_IP}

  backend:
    build: ./backend
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
    environment:
      DATABASE_URL: postgresql://milojos:${POSTGRES_PASSWORD}@postgres:5432/milojos_dev
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      JWT_SECRET: ${JWT_SECRET}
      SUPABASE_URL: ${SUPABASE_URL}
      SUPABASE_SERVICE_KEY: ${SUPABASE_SERVICE_KEY}
      GOOGLE_PLAY_SERVICE_ACCOUNT: ${GOOGLE_PLAY_SERVICE_ACCOUNT}
      FCM_SERVER_KEY: ${FCM_SERVER_KEY}
    volumes:
      - ./backend:/app
      - /app/node_modules

volumes:
  postgres_data:
```

### Variables de Entorno Requeridas (.env)
```
# Base de Datos
POSTGRES_PASSWORD=
DATABASE_URL=

# Redis
REDIS_PASSWORD=

# Auth
JWT_SECRET=
JWT_EXPIRATION=15m
JWT_REFRESH_EXPIRATION=30d

# Supabase
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_KEY=

# Firebase
FCM_SERVER_KEY=
FIREBASE_PROJECT_ID=

# Google Play (para validar suscripciones)
GOOGLE_PLAY_PACKAGE_NAME=com.milojos.app
GOOGLE_PLAY_SERVICE_ACCOUNT=  # JSON de cuenta de servicio en base64

# Mediasoup
MEDIASOUP_ANNOUNCED_IP=
SERVER_PUBLIC_IP=

# Mapbox
MAPBOX_ACCESS_TOKEN=

# AWS S3 (fotos de alerta)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=milojos-alerts
AWS_REGION=us-east-1
```

---

## 8. DIAGRAMA C4 — NIVEL CONTEXTO

```
                    ┌─────────────────────────────────────────────┐
                    │              SISTEMA MILOJOS                │
                    │                                             │
  ┌───────────┐     │  ┌───────────┐    ┌──────────────────────┐ │
  │ Estudiante│────►│  │ Flutter   │───►│  NestJS Backend API  │ │
  └───────────┘     │  │ Mobile App│    │  + WebSocket Gateway │ │
                    │  └───────────┘    └──────────────────────┘ │
  ┌───────────┐     │       │                    │                │
  │  Vecino   │────►│       │           ┌────────┴──────────┐     │
  └───────────┘     │       │           │ PostgreSQL+PostGIS│     │
                    │       │           │ Redis 7            │     │
  ┌───────────┐     │       │           │ Mediasoup SFU      │     │
  │   Admin   │────►│       ▼           └────────────────────┘     │
  └───────────┘     │  ┌───────────┐                               │
                    │  │ Admin Web │    ┌──────────────────────┐    │
  ┌───────────┐     │  │(Dashboard)│    │   SERVICIOS EXTERNOS │    │
  │  Policía  │────►│  └───────────┘   │  Supabase Auth       │    │
  └───────────┘     │                  │  Firebase FCM        │    │
                    │                  │  Google Play Billing │    │
  ┌───────────┐     │  ┌───────────┐   │  AWS S3              │    │
  │Cámara IP  │────►│  │ RTSP      │   │  Mapbox              │    │
  │(hardware) │     │  │ Bridge    │   └──────────────────────┘    │
  └───────────┘     │  └───────────┘                               │
                    └─────────────────────────────────────────────┘
```

---

## 9. NOTIFICACION A OTROS AGENTES

**→ Compliance Agent:** El campo `rtsp_url_encrypted` en la tabla `cameras` usa
pgcrypto con clave rotable. El `camera_access_log` tiene trigger que PREVIENE
UPDATE y DELETE a nivel de PostgreSQL policy.

**→ QA Agent:** La capa Domain es 100% Dart puro, sin imports de Flutter.
Todos los tests unitarios de domain/ no necesitan mocks de Flutter SDK.
El `PanicAlertUseCase` recibe `AlertRepository` (abstract) como dependencia inyectada.

**→ Product Agent:** Google Play Billing requiere que los productos (SKUs) estén
creados en la Play Console ANTES de que el flujo de compra funcione en producción.
En desarrollo, se puede usar el sandbox de Google Play. Prever 2-3 semanas para
aprobación de Google si es la primera app.

---

## 10. ENTREGABLES — SPRINT 0

| Entregable | Deadline | Dependencias |
|---|---|---|
| `docker-compose.yml` funcional | Semana 1 | — |
| Schema PostgreSQL + migraciones iniciales | Semana 1 | — |
| Proyecto NestJS base (módulos Auth, Alerts) | Semana 2 | — |
| Proyecto Flutter base (Clean Arch + BLoC) | Semana 2 | — |
| ADR-001 a ADR-007 formalizados | Semana 2 | — |
| SKUs creados en Google Play Console | Semana 2 | Cuenta Play Console activa |

---
*Architect Agent — MilOjos — Informe #1 — 2026-03-28*
