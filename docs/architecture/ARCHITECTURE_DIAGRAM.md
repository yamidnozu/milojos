# Diagrama de Arquitectura de Sistemas & Flujo Lógico
**MilOjos - Red Colaborativa de Seguridad (Popayán)**

La plataforma de **MilOjos** está diseñada utilizando una arquitectura basada en eventos (WebSockets) y una base relacional robusta orientada al componente geoespacial (PostGIS) para reducir las latencias a menos de `500ms` durante una alerta de pánico.

A continuación, se define cómo interactúan los subsistemas:

## 1. Topología del Ecosistema

```mermaid
graph TD
    subgraph "MilOjos Frontend (Flutter)"
        App[MilOjos App]
        Shake(Shake Detector Sensor)
        Maps(Mapbox UI / GPS Location)
        AuthBloc(Auth BLoC)
        PanicBloc(Panic Alert BLoC)
        VideoPlayer(WebRTC VP8 Consumer)
    end

    subgraph "Seguridad e Identidad (Authentication)"
        Supabase(Supabase Auth - OAuth & JWT)
        EdgeFunc(Edge Function: Validate Student QR)
    end

    subgraph "MilOjos Backend Node.js (NestJS)"
        REST[API REST: Users & Onboarding]
        Gateway[Alerts WebSocket Gateway]
        GeoQuery(PostGIS Distance Logic)
        MediaSoup[MediaSoup C++ Worker / WebRTC Router]
        FCM(Firebase Cloud Messaging SDK)
        InAppPurch[Subscriptions Validator: Google Play]
    end

    subgraph "Base de Datos (Cluster PostgreSQL 16)"
        PG(Postgres DB)
        PostGIS(PostGIS Extension)
        RLS(Row Level Security / IAM)
        CamerasAuth(pgcrypto RTSP Secrets)
        ImmutableLog(Camera Access Log Triggers)
    end

    %% Relaciones Flutter a Backend
    Shake -->|Inertia > 2.5G| PanicBloc
    Maps -->|PUT /v1/users/:id/location| REST
    AuthBloc -->|Google OAuth| Supabase
    AuthBloc -->|Scan QR| EdgeFunc
    PanicBloc <-->|socket.io (UDP/TCP)| Gateway
    VideoPlayer <-->|ICE/DTLS UDP| MediaSoup

    %% Backend a Base de Datos
    REST --> PG
    Gateway --> GeoQuery
    GeoQuery --> PostGIS
    PostGIS -->|ST_DWithin()| PG
    MediaSoup --> CamerasAuth

    %% Alertas
    Gateway -->|Emergency Broadcast| FCM
    FCM -->|Push Notification| App
```

## 2. Flujo de Activación de Pánico (Event-Driven)

Cuando un menor de edad (o cualquier usuario) es víctima de un incidente y agita su celular:

```mermaid
sequenceDiagram
    autonumber
    participant Estudiante (Flutter App)
    participant NestJS (Alerts Gateway)
    participant PostgreSQL + PostGIS
    participant FCM (Push Notification)
    participant Vecino PRO (Flutter App)
    participant MediaSoup (Media Server)

    Estudiante (Flutter App)->>Estudiante (Flutter App): Agita el teléfono (Shake Sensor)
    Estudiante (Flutter App)->>NestJS (Alerts Gateway): WebSocket Emit ('panic_trigger') con Lat, Lng y JWT
    
    NestJS (Alerts Gateway)->>PostgreSQL + PostGIS: Llama get_neighbors_in_radius(Point, 500m)
    PostgreSQL + PostGIS-->>NestJS (Alerts Gateway): Retorna Vecinos Activos {id: 123, distance: 154m}
    
    NestJS (Alerts Gateway)-->>Estudiante (Flutter App): ACK emit('panic_confirmed', {neighbors_notified: n})
    
    NestJS (Alerts Gateway)->>FCM (Push Notification): Multicast Prioridad Alta ("Alerta en tu radio")
    FCM (Push Notification)-->>Vecino PRO (Flutter App): Despierta Servicio de SO
    
    Vecino PRO (Flutter App)->>NestJS (Alerts Gateway): Solicita Transports de video Cercano (POST /transports)
    NestJS (Alerts Gateway)->>MediaSoup (Media Server): createConsumerTransport()
    MediaSoup (Media Server)-->>Vecino PRO (Flutter App): WebRTC Tuple (VP8) de cámara en esquina
```

## 3. Modelo de Capas de Clean Architecture (App)

Para mantener desacoplado el código en Dart, MilOjos Mobile obedece:
1. **Presentation:** Widgets asíncronos y UI. BlocConsumer para repintar eventos (ej. Al agitar teléfono y cambiar a Modal rojo).
2. **Domain:** Entidades puras y de Negocio (`UserEntity`, `AlertEntity`) independientes de los paquetes en `pubspec.yaml` (las fallas como "NetworkFailure" existen aquí).
3. **Data:** Implementaciones que conocen sobre `dio`, `supabase_flutter`, `web_socket_client`. Implementan abstracciones, usando JSON Serialization y Try-Catches.

## 4. Auditoría de Cámaras y Habeas Data
Todo evento que otorgue el streaming UDP de una Institución Educativa a un Vecino es escrito pasivamente (via Triggers nativos) a la tabla `camera_access_log`. Esta es una tabla inmutable que prohíbe los eventos `UPDATE`, logrando así la conformidad con reguladores legales como la Superintendencia de Industria y Comercio en Colombia.
