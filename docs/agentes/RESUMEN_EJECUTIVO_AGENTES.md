# RESUMEN EJECUTIVO — Todos los Agentes Activados
**Proyecto MilOjos · Sesion de Activacion · 2026-03-28**

---

## ESTADO DE ACTIVACION

| Agente | Estado | Informe | Archivos |
|---|---|---|---|
| ⚖️ Compliance Agent | ✅ ACTIVO | [Ver →](./informes/01_compliance_agent_informe.md) | 4 docs legales pendientes |
| 🏗️ Architect Agent | ✅ ACTIVO | [Ver →](./informes/02_architect_agent_informe.md) | ADR-001 a ADR-007 |
| ✅ QA & Lead Dev Agent | ✅ ACTIVO | [Ver →](./informes/03_qa_agent_informe.md) | Tests TDD + CI/CD |
| 🎨 Product Owner Agent | ✅ ACTIVO | [Ver →](./informes/04_product_agent_informe.md) | 14 User Stories |

---

## DECISION TRANSVERSAL: GOOGLE PLAY BILLING

**Actualización aprobada:** Las suscripciones de MilOjos se gestionan mediante
**Google Play Billing** (in_app_purchase plugin de Flutter), que integra Google Pay
como método de pago nativo en Android.

### Impacto por Agente

| Agente | Impacto | Acción Requerida |
|---|---|---|
| **Compliance** | Nuevas cláusulas legales para compras in-app | Cláusulas de cancelación, reembolso y renovación |
| **Architect** | Webhook Google Play Pub/Sub en NestJS | `POST /api/v1/subscriptions/google-play/webhook` |
| **QA** | Tests para flujo de compra (Google Play sandbox) | US-009 en Sprint 3 con sandbox environment |
| **Product** | SKUs definidos, flujo de UI aprobado | 2 SKUs veginos + 2 institucionales vía factura |

### SKUs Definitivos Google Play

```
milojos.vecino.basico.monthly    → COP $15,000/mes
milojos.vecino.pro.monthly       → COP $25,000/mes
```

> Planes institucionales: factura directa (B2B), fuera de Google Play.

---

## DECISIONES CRUZADAS ACORDADAS

### 1. Stack Tecnologico FINAL

```
MOBILE:       Flutter 3.x + Dart
ESTADO:       BLoC + Cubit (flutter_bloc) — UNICO gestor de estado
BACKEND:      NestJS (Node.js + TypeScript)
BASE DATOS:   PostgreSQL 16 + PostGIS (geo) + Redis 7 (cache/pub-sub)
AUTH:         Supabase Auth (JWT + PKCE + RLS)
VIDEO:        Mediasoup SFU (WebRTC) + RTSP bridge con FFmpeg
PUSH:         Firebase Cloud Messaging (alta prioridad)
MAPAS:        Mapbox GL (soporte offline)
STORAGE:      Supabase Storage / AWS S3 (fotos de alerta)
PAGOS:        Google Play Billing — in_app_purchase plugin
LINT:         very_good_analysis
TESTING:      flutter_test + mocktail + bloc_test + Patrol (E2E)
CI/CD:        GitHub Actions + Docker + Railway/Render
MONITOREO:    Sentry + Grafana
```

### 2. Protocolo de Interaccion — Confirmado

```
PRIORIDAD EN CONFLICTOS:
  Legal > Arquitectura > Calidad > Producto

REGLA CERO:
  Ninguna feature toca produccion sin Privacy Clearance (si aplica)
  y sin tests TDD previos.

CANAL DE COMUNICACION:
  GitHub Issues con etiqueta [COMPLIANCE] / [ARCHITECT] / [QA] / [PRODUCT]
```

### 3. Criterios de Exito Sprint 0 (Semanas 1-2)

| Entregable | Agente | Deadline |
|---|---|---|
| Política de Privacidad v1 | Compliance | Semana 1 |
| Formulario Consentimiento Menores v1 | Compliance | Semana 1 |
| Términos de Uso Cámaras IP v1 | Compliance | Semana 2 |
| Cláusulas Google Play | Compliance | Semana 2 |
| docker-compose.yml funcional | Architect | Semana 1 |
| Schema PostgreSQL + PostGIS | Architect | Semana 1 |
| Proyecto NestJS base | Architect | Semana 2 |
| Proyecto Flutter base (Clean Arch) | Architect | Semana 2 |
| SKUs creados en Google Play Console | Architect | Semana 2 |
| analysis_options.yaml | QA | Semana 1 |
| Pipeline GitHub Actions CI | QA | Semana 1 |
| Template PR con DoD | QA | Semana 1 |
| Tests TDD PanicAlertUseCase (FAIL) | QA | Semana 2 |
| Tests TDD PanicBloc (FAIL) | QA | Semana 2 |
| Wireframes flujo de pánico | Product | Semana 2 |
| User Stories Gherkin (US-001 a US-006) | Product | Semana 2 |
| Backlog v1 priorizado | Product | Semana 2 |

---

## PROXIMA SESION DE SINCRONIZACION

**Trigger sugerido:** Al finalizar Sprint 0 (Semana 2)

**Agenda:**
1. Compliance: estado de documentos legales y risk matrix
2. Architect: demo del docker-compose + diagrama C4
3. QA: demo del pipeline CI corriendo (tests en FAIL esperados)
4. Product: presentación de wireframes al equipo

---
*Resumen ejecutivo generado automáticamente — MilOjos — 2026-03-28*
