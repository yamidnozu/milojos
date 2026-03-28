# Plan de Acción Estratégico — Iteración 2 (Sprint 4 y Escalado)
**Documento Consolidado por el Enjambre de Agentes MilOjos | Fecha: 2026-03-28**

Habiendo alcanzado la estabilidad en las interfaces y los servicios lógicos de Pánico (Sprints 1 al 3), los Agentes Expertos han auditado el sistema y proyectado los objetivos mandatarios para la **Iteración 2**. El enfoque virará de la estructuración de producto hacia la **Seguridad Ofensiva, Despliegue Cloud (DevOps) y Tareas Diferidas**.

---

### 🛡️ 1. Security Agent (Agente de Ciberseguridad)
*El nivel de amenaza incrementó al manejar datos de menores, streams de vigilancia en vivo y ubicación GPS.*
**Tareas Asignadas:**
*   **A.** Implementar las políticas `Row Level Security (RLS)` directamente en las tablas de Supabase/PostgreSQL. Ningún Vecino debe poder hacer `SELECT` de alertas lejanas.
*   **B.** Cifrar de punta a punta (E2EE) la url de RTSP mediante Node `crypto` o la extensión `pgcrypto` al inyectar cámaras nuevas desde la App.
*   **C.** Habilitar los Guards definitivos (`@UseGuards(SupabaseGuard)`) en el Backend NestJS inyectando la llave JWT pública.

### ⚙️ 2. Cloud Architect & DevOps Agent
*Todo funciona en desarrollo local. Es inminente portar la topología a la nube (AWS/DigitalOcean).*
**Tareas Asignadas:**
*   **A.** Diseñar el esquema de **Docker Compose** multi-etapa para el servidor NestJS.
*   **B.** Crear e instanciar el servidor de **MediaSoup WebRTC** (Worker en C++), el cual debe correr en una máquina independiente con puertos UDP abiertos (rango 10000-59999) para soportar streaming VP8 concurrente.
*   **C.** Sincronizar un Pipeline `CI/CD` en GitHub Actions que ejecute el `flutter analyze`, los tests unitarios (`trigger_panic_alert_usecase_test.dart`) y bloquee _Pull Requests_ defectuosos.

### 📱 3. Mobile Dev Agent (Sprints Diferidos)
*Faltan componentes en la frontera del producto para cerrar el ciclo del MVP.*
**Tareas Asignadas:**
*   **A.** Completar **US-013:** Diseñar el historial / estadísticas personales dentro de la app móvil.
*   **B.** Completar **US-014:** Programar el "Modo Demo Activo" (7 días de trial en código duro en Flutter para los recorridos de ventas en campo).
*   **C.** Enlazar el flujo de cámara `RTCVideoRenderer` de Flutter con la API real de Señalización WebRTC del Backend.

### ⚖️ 4. Compliance & QA Agent
**Tareas Asignadas:**
*   **A.** Testear flujos de excepción (`NetworkFailure`, `LocationPermissionDenied`), inyectando Mocktail en los UseCases restantes de Flutter.
*   **B.** Validar la auditoría inmutable de la tabla `camera_access_log` lanzando ataques _SQL Injection_ controlados.
