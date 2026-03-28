<div align="center">

# 🛡️ MilOjos

### Plataforma de Seguridad Colaborativa
**Popayán, Cauca, Colombia**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![NestJS](https://img.shields.io/badge/NestJS-10.x-E0234E?logo=nestjs)](https://nestjs.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+PostGIS-4169E1?logo=postgresql)](https://postgresql.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CI](https://github.com/yamidnozu/milojos/actions/workflows/ci.yml/badge.svg)](https://github.com/yamidnozu/milojos/actions)

</div>

---

## 📖 Descripción

**MilOjos** es una plataforma de seguridad colaborativa que conecta a vecinos, estudiantes e instituciones educativas de Popayán para crear redes de protección comunitaria.

### ✨ Funcionalidades clave

- 🚨 **Botón de Pánico por Gesto** — Agitar el celular activa una alerta de emergencia que notifica a vecinos y autoridades en segundos
- 📹 **Red de Cámaras IP** — Vecinos comparten sus cámaras de seguridad formando una red colaborativa de vigilancia
- 📍 **Alertas Geolocalizadas** — Sistema de alertas en tiempo real con radio de cobertura configurable (PostGIS)
- 👨‍👩‍👧 **Protección Escolar** — Módulo especializado para instituciones educativas con consentimiento parental integrado
- 🔐 **Cumplimiento Legal** — Diseñado bajo la Ley 1581/2012 (Habeas Data Colombia) y normativas para menores de edad

---

## 🏗️ Arquitectura

```
┌─────────────────── FLUTTER APP (Mobile) ────────────────────┐
│  Presentation (BLoC/Cubit) → Domain (UseCases) → Data       │
└──────────────────────────────────────────────────────────────┘
          │ WebSocket / REST              │ Supabase Auth
          ▼                              ▼
┌────── NESTJS BACKEND ──────┐    ┌─── MEDIA SERVER ────┐
│  REST API + WebSocket GW   │    │  Mediasoup SFU       │
│  Módulos: Auth, Alerts,    │    │  (WebRTC streams)    │
│  Cameras, Subscriptions    │    └─────────────────────┘
└────────────────────────────┘
          │
    ┌─────┴──────┐
    ▼            ▼
PostgreSQL     Redis 7
+ PostGIS      (PubSub / Cache)
```

## 🛠️ Stack Tecnológico

| Capa | Tecnología |
|---|---|
| **Mobile** | Flutter 3.x (Dart) — Clean Architecture + BLoC |
| **Backend** | NestJS (Node.js + TypeScript) |
| **Base de Datos** | PostgreSQL 16 + PostGIS |
| **Cache / PubSub** | Redis 7 |
| **Auth** | Supabase Auth (JWT + PKCE) |
| **Video** | Mediasoup SFU (WebRTC) + RTSP bridge |
| **Mapas** | Mapbox GL |
| **Push** | Firebase Cloud Messaging |
| **Pagos** | Google Play Billing (in_app_purchase) |
| **DevOps** | Docker + GitHub Actions |

---

## 📁 Estructura del Repositorio

```
milojos/
├── mobile/          # App Flutter (Clean Architecture)
├── backend/         # API NestJS + WebSocket
├── mediasoup/       # Servidor de video WebRTC
├── docs/
│   ├── agentes/     # Definiciones y primeros informes de los Agentes
│   ├── legal/       # Política de privacidad, consentimientos
│   └── architecture/# ADRs (Architecture Decision Records)
├── .github/
│   ├── workflows/   # CI/CD pipelines
│   └── PULL_REQUEST_TEMPLATE.md
└── docker-compose.yml
```

---

## 🚀 Inicio Rápido

### Prerrequisitos
- Docker + Docker Compose
- Flutter 3.x SDK
- Node.js 20.x
- `gh` CLI (GitHub CLI)

### 1. Clonar y configurar
```bash
git clone https://github.com/yamidnozu/milojos.git
cd milojos
cp .env.example .env
# Editar .env con tus variables
```

### 2. Levantar servicios de desarrollo
```bash
docker-compose up -d
```

### 3. Backend
```bash
cd backend
npm install
npm run start:dev
```

### 4. App Flutter
```bash
cd mobile
flutter pub get
flutter run
```

---

## 👥 Equipo de Agentes Especialistas

| Agente | Responsabilidad | Doc |
|---|---|---|
| ⚖️ **Compliance** | Ley 1581, menores, privacidad | [Ver informe](docs/agentes/informes/01_compliance_agent_informe.md) |
| 🏗️ **Architect** | Clean Architecture, stack, ADRs | [Ver informe](docs/agentes/informes/02_architect_agent_informe.md) |
| ✅ **QA & Lead Dev** | TDD, DoD, CI/CD, BLoC | [Ver informe](docs/agentes/informes/03_qa_agent_informe.md) |
| 🎨 **Product & UX** | Backlog, flujo pánico, roles | [Ver informe](docs/agentes/informes/04_product_agent_informe.md) |

---

## ⚖️ Cumplimiento Legal

MilOjos cumple con:
- **Ley 1581/2012** — Habeas Data (Colombia)
- **Ley 1098/2006** — Código de Infancia y Adolescencia
- **Decreto 1070/2015** — Sector Defensa (acuerdo con Policía Nacional)
- **Ley 527/1999** — Firma electrónica para consentimientos

---

## 🗺️ Hoja de Ruta

- **Sprint 0** (Semana 1-2): Fundamentos — infraestructura, legal, CI/CD ← *estamos aquí*
- **Sprint 1** (Semana 3-6): Autenticación + Alerta de Pánico
- **Sprint 2** (Semana 7-10): Red de Cámaras IP + WebRTC
- **Sprint 3** (Semana 11-14): Google Play Billing + Roles Avanzados
- **Sprint 4** (Semana 15-16): Beta Cerrada Popayán

---

## 📄 Licencia

MIT License — Ver [LICENSE](LICENSE)

---

<div align="center">
Hecho con ❤️ en Popayán, Cauca, Colombia 🇨🇴
</div>
