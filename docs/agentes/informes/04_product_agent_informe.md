# INFORME #1 — Agente de Producto y UX (Product Owner Agent)
**Proyecto MilOjos · Fecha: 2026-03-28 · Estado: ACTIVO**

---

## DECLARACION DE ACTIVACION

El Agente de Producto y UX está operativo. Mi misión es garantizar que MilOjos
resuelva un problema real para los habitantes de Popayán con una experiencia que
cualquier usuario —independientemente de su nivel tecnológico— pueda usar en
situaciones de emergencia. Presento las definiciones funcionales del MVP.

---

## 1. FLUJO DE PANICO — Especificacion Tecnica Completa

### A. Deteccion del Gesto "Shake"

**Algoritmo de Detección:**

```
PARAMETROS DE CALIBRACION (ajustables desde Panel Admin):
  Umbral de magnitud:    2.5g (m/s² equivalente: 24.5)
  Duración mínima:       500ms de shake sostenido
  Ejes considerados:     X, Y, Z (los 3)
  Ventana de evaluación: 1 segundo deslizante

FILTROS ACTIVOS:
  1. KalmanFilter: elimina vibración de caminar/correr
  2. ChargerFilter: si batería es 100% y no baja → probablemente estático
  3. ForegroundScrollFilter: si AppLifecycleState == resumed Y
     última interacción UI fue hace < 500ms → ignorar shake

PSEUDOCODIGO:
  onAccelerometerEvent(event):
    magnitude = sqrt(x² + y² + z²) - GRAVITY
    if magnitude > THRESHOLD:
      shakeBuffer.add(event.timestamp)
      if shakeBuffer.duration() >= MIN_DURATION:
        if not isFiltered(event):
          emit(ShakeDetected())
          shakeBuffer.clear()
```

### B. Pantalla de Confirmacion (3 segundos)

```
┌─────────────────────────────────────────────────┐
│                                                  │
│     ⚠️  ALERTA DE PANICO DETECTADA              │
│                                                  │
│   ¿Necesitas ayuda ahora mismo?                 │
│                                                  │
│   ┌─────────────────────────────────────┐        │
│   │   🔴  SÍ, ESTOY EN PELIGRO         │        │
│   │       Activar alerta de emergencia  │        │
│   └─────────────────────────────────────┘        │
│                                                  │
│   ┌─────────────────────────────────────┐        │
│   │      Cancelar  (se cierra en 3s)   │        │
│   │   ████████████████░░░░░░░  3s      │        │
│   └─────────────────────────────────────┘        │
│                                                  │
│   Vibración háptica: 3 pulsos cortos             │
│   Sonido: tono de alerta (si no hay silencio)    │
│                                                  │
└─────────────────────────────────────────────────┘

COMPORTAMIENTO DEL COUNTDOWN:
  - Si expira el countdown SIN acción del usuario → NO activa alerta
  - El usuario DEBE presionar activamente "SÍ, ESTOY EN PELIGRO"
  - Presionar cualquier parte de la pantalla fuera del botón = cancelar
```

### C. Captura Silenciosa Post-Confirmacion

```
SECUENCIA INMEDIATA tras confirmar (objetivo: < 500ms):

1. Activar cámara frontal  → sin preview, sin sonido de obturador
2. Capturar foto           → resolución reducida (640x480) para velocidad
3. Convertir a Base64      → comprimir primero con calidad 70%
4. Obtener GPS             → con timeout de 3s; si falla, usar última ubicación
5. Registrar timestamp UTC → no usar hora local (evitar manipulación)
6. Emitir al Bloc          → ConfirmAlert(latitude, longitude, photoBase64)
```

### D. Pantalla "Ayuda en Camino"

```
┌─────────────────────────────────────────────────┐
│                                                  │
│        🚨 ALERTA ENVIADA                        │
│                                                  │
│   Tu SOS fue recibido por:                      │
│   • 8 vecinos cercanos                          │
│   • Institución San José                        │
│   • Policía Nacional Popayán                    │
│                                                  │
│   ┌─────────────────────────────────────┐        │
│   │  📍 Mapa con tu posición LIVE       │        │
│   │  (zona borrosa para privacidad)     │        │
│   └─────────────────────────────────────┘        │
│                                                  │
│   [CHAT DE EMERGENCIA ABIERTO]                   │
│   "¿Puedes describirnos qué sucede?"             │
│                                                  │
│   ─────────────────────────────────────         │
│   ¿Ya estás seguro/a?                           │
│   [✅ Estoy bien - Fue una falsa alarma]         │
│                                                  │
└─────────────────────────────────────────────────┘
```

---

## 2. PRODUCT BACKLOG v1 — Priorizado y Estimado

### Epica 1: Sistema de Autenticacion y Roles (Sprint 1)

```
US-001: Registro de Estudiante
  Como: estudiante menor de edad
  Quiero: registrarme con el QR que me entregó la institución
  Para: activar mi protección de pánico
  
  Criterios de Aceptacion (Gherkin):
    Escenario: Registro exitoso con QR válido
      Dado que tengo un QR único generado por la institución
      Y mi padre ya firmó el consentimiento digital
      Cuando escaneo el QR desde la app
      Entonces mi cuenta se activa automáticamente
      Y recibo confirmación con mis credenciales
    
    Escenario: QR expirado
      Dado que tengo un QR generado hace más de 30 días
      Cuando intento usarlo
      Entonces veo mensaje "Este código ha expirado, solicita uno nuevo a tu institución"
    
    Escenario: Sin consentimiento del padre
      Dado que tengo un QR válido
      Pero mi padre NO ha firmado el consentimiento
      Cuando escaneo el QR
      Entonces veo "Tu representante debe completar el formulario primero"
      Y el sistema envía recordatorio por WhatsApp al número del padre
  
  Story Points: 8 | Prioridad: MUST HAVE

US-002: Registro de Vecino
  Como: vecino del barrio
  Quiero: registrarme verificando mi domicilio
  Para: unirme a la red de seguridad del sector
  
  Criterios de Aceptacion:
    Escenario: Verificación de domicilio exitosa
      Dado que ingreso mi dirección
      Cuando tomo foto de la fachada de mi casa con GPS activo
      Y el GPS coincide con la dirección ingresada (radio 100m)
      Entonces mi cuenta queda en estado "pendiente de verificación"
      Y recibo confirmación en 24 horas
    
    Escenario: Sin coincidencia GPS
      Dado que el GPS está a más de 100m de la dirección ingresada
      Entonces se solicita una segunda foto con más contexto visible
  
  Story Points: 5 | Prioridad: MUST HAVE

US-003: Login con Google (OAuth)
  Como: usuario registrado
  Quiero: iniciar sesión con mi cuenta de Google
  Para: no memorizar contraseñas adicionales
  
  Nota: Prioritario para vecinos y admin. Estudiantes usan QR.
  Story Points: 3 | Prioridad: MUST HAVE
```

### Epica 2: Alerta de Panico (Sprint 1 — PRIORITARIO)

```
US-004: Gesto de Panico (Shake)
  Como: estudiante o usuario registrado
  Quiero: activar una alerta de emergencia agitando mi celular
  Para: pedir ayuda sin tener que desbloquear el teléfono
  
  Criterios de Aceptacion:
    Escenario: Activación exitosa
      Dado que tengo la app en segundo plano
      Cuando agito el teléfono con intensidad >= 2.5g por 500ms
      Entonces aparece pantalla de confirmación en menos de 1 segundo
      Y el teléfono vibra 3 veces
    
    Escenario: Activación en zona con poca señal
      Dado que tengo señal 2G únicamente
      Cuando confirmo la alerta
      Entonces la alerta se encola localmente
      Y se envía en cuanto se recupere señal
      Y veo mensaje "Sin señal óptima - tu alerta se enviará al recuperar conexión"
    
    Escenario: 3 falsas alarmas en 1 hora
      Dado que he marcado 3 alertas como "falsa alarma" en la última hora
      Cuando agito el teléfono
      Entonces veo "Función temporalmente pausada por 30 minutos"
      Y puedo llamar directamente a emergencias (123) desde la misma pantalla
  
  Story Points: 13 | Prioridad: MUST HAVE

US-005: Cancelación de Falsa Alarma
  Como: usuario que activó una alerta accidentalmente
  Quiero: cancelar la alerta antes de que lleguen los respondedores
  Para: no generar pánico innecesario
  
  Criterio: Cancelación disponible hasta 30 segundos después de confirmar.
  Después de 30s: solo puede "marcar como resuelta" (no cancelar).
  Story Points: 3 | Prioridad: MUST HAVE

US-006: Recepcion de Alertas (Vecino)
  Como: vecino registrado
  Quiero: recibir notificación push cuando hay una alerta cerca
  Para: poder ayudar o tomar precauciones
  
  Criterios de Aceptacion:
    Escenario: Notificación en foreground
      Cuando hay alerta en radio de 500m de mi ubicación
      Entonces veo banner de alerta en la app
      Y el mapa muestra la zona aproximada (no exacta) de la alerta
    
    Escenario: Notificación en background
      Cuando la app está cerrada
      Entonces recibo push de alta prioridad
      Y el teléfono vibra aunque esté en silencio (alerta crítica)
  
  Story Points: 5 | Prioridad: MUST HAVE
```

### Epica 3: Red de Camaras IP (Sprint 2)

```
US-007: Compartir Camara IP
  Como: vecino con cámara IP compatible
  Quiero: agregar mi cámara a la red MilOjos
  Para: que ayude en emergencias del vecindario
  
  Criterios de Aceptacion:
    Escenario: Cámara ONVIF compatible
      Dado que tengo una cámara con protocolo ONVIF
      Cuando ingreso IP local y credenciales
      Entonces el sistema verifica conectividad en < 10 segundos
      Y genera URL RTSP cifrada para uso interno
    
    Escenario: Cámara fuera de la red local
      Cuando la cámara está fuera del rango de detección
      Entonces veo guía para configurar acceso remoto seguro
  
  Story Points: 8 | Prioridad: SHOULD HAVE

US-008: Ver Camara en Emergencia
  Como: vecino que recibe alerta
  Quiero: ver el feed de cámaras cercanas a la emergencia
  Para: ayudar a identificar la situación
  
  Criterio: Solo disponible durante alerta activa.
  Feed visible máximo 500m de distancia a la alerta.
  Acceso registrado en log inmutable (Compliance).
  Story Points: 13 | Prioridad: SHOULD HAVE
```

### Epica 4: Suscripciones Google Play (Sprint 3)

```
US-009: Suscripcion Plan Vecino Basico
  Como: vecino interesado
  Quiero: suscribirme con Google Pay desde la app
  Para: acceder a las funciones de seguridad del barrio
  
  Criterios de Aceptacion:
    Escenario: Compra exitosa
      Dado que selecciono "Plan Vecino Básico - $15,000 COP/mes"
      Cuando autorizo el pago con Google Pay
      Entonces mi cuenta se activa en menos de 30 segundos
      Y recibo notificación de confirmación
      Y puedo ver mi fecha de renovación en Perfil > Suscripción
    
    Escenario: Pago rechazado
      Cuando el método de pago es rechazado
      Entonces veo opción de actualizar método de pago
      Y puedo reintentar sin salir del flujo
    
    Escenario: Cancelacion de suscripcion
      Cuando cancelo desde Configuración > Suscripción
      Entonces el acceso continúa hasta el fin del período pagado
      Y NO se realiza el cobro del mes siguiente
  
  Story Points: 8 | Prioridad: MUST HAVE (sin monetización no hay proyecto)

US-010: Suscripcion Institucional
  Como: administrador de institución educativa
  Quiero: contratar el plan institucional
  Para: proteger a todos nuestros estudiantes
  
  Nota: Este flujo es B2B — fuera del flujo de Google Play.
  Se gestiona mediante factura directa y contrato.
  Story Points: 5 | Prioridad: MUST HAVE
```

---

## 3. JERARQUIA DE ROLES — Especificacion Completa

### Mapa de Pantallas por Rol

```
ROL: ESTUDIANTE
├── Pantalla Principal: Mapa del colegio + historial de sus alertas
├── Botón de Pánico (siempre visible, esquina inferior derecha)
├── Notificaciones: solo alertas del colegio
├── Cámaras: solo las del colegio (modo solo lectura, sin emergencia)
├── Perfil: datos básicos (sin suscripción)
└── NO tiene: configuración de cámaras, gestión de usuarios

ROL: VECINO
├── Pantalla Principal: Mapa del barrio con alertas activas
├── Botón de Pánico (siempre visible)
├── Mis Cámaras: gestión de hasta N cámaras según su plan
├── Notificaciones: alertas en radio de 500m
├── Ver Cámaras Vecinas: solo durante alerta activa
├── Perfil + Suscripción: gestión de plan Google Play
└── NO tiene: gestión de usuarios, panel de institución

ROL: ADMIN INSTITUCION
├── Dashboard: estadísticas de alertas, estudiantes activos
├── Gestión de Estudiantes: crear, ver, desactivar cuentas
│   ├── Importar CSV de estudiantes
│   ├── Generar QR por estudiante
│   └── Ver estado del consentimiento parental
├── Cámaras del Colegio: gestionar cámaras institucionales
├── Alertas: historial completo + métricas
├── Suscripción Institucional: ver estado del contrato
└── NO tiene: acceso a cuentas de vecinos, panel de policía

ROL: POLICIA
├── Dashboard especializado: mapa con todas las alertas activas
├── Cámaras disponibles: públicas + acceso especial en emergencia
├── Historial de alertas en su jurisdicción
├── Acceso requiere credenciales verificadas por Super Admin
└── Sin acceso a: datos de estudiantes (solo ubicación de alerta)

ROL: SUPER ADMIN
├── Panel de control completo
├── Gestión de instituciones y contratos
├── Verificación de cuentas de policía
├── Métricas globales de la plataforma
├── Configuración de parámetros del shake detector
└── Auditoría de logs de acceso a cámaras
```

---

## 4. MODELO DE SUSCRIPCION — Google Play Billing

### Planes y SKUs

| Plan | SKU Google Play | Precio COP | Precio USD aprox | Límites |
|---|---|---|---|---|
| Vecino Básico | `milojos.vecino.basico.monthly` | $15,000 | ~$3.50 | 1 cámara, alertas básicas |
| Vecino Pro | `milojos.vecino.pro.monthly` | $25,000 | ~$5.80 | 3 cámaras, historial 30d |
| Institución Básica | N/A (factura directa) | $150,000 | ~$35 | 200 estudiantes |
| Institución Enterprise | N/A (factura directa) | $350,000 | ~$81 | Ilimitado + API |

### Flujo de Suscripcion en la App

```
PANTALLA: Elige tu Plan
┌─────────────────────────────────────────────┐
│  🏡 VECINO BÁSICO           $15.000/mes     │
│  ✓ 1 cámara IP compartida                  │
│  ✓ Alertas de pánico ilimitadas            │
│  ✓ Noticias del vecindario                 │
│  [SUSCRIBIRME CON  G Pay ]                  │
├─────────────────────────────────────────────┤
│  ⭐ VECINO PRO              $25.000/mes     │
│  ✓ Todo lo del plan Básico                 │
│  ✓ Hasta 3 cámaras IP                      │
│  ✓ Historial de alertas 30 días            │
│  ✓ Soporte prioritario                     │
│  [SUSCRIBIRME CON  G Pay ]                  │
└─────────────────────────────────────────────┘

PANTALLA: Confirmar suscripcion (Google Pay Sheet nativo)
  → El usuario ve: plan, precio, frecuencia, método de pago
  → Confirma con huella/PIN de Google Pay
  → Regresa a la app con PurchaseDetails

PANTALLA: Activacion confirmada
  ┌─────────────────────────────────────────┐
  │  ✅ ¡Bienvenido a MilOjos Pro!          │
  │                                          │
  │  Tu primer pago fue procesado.           │
  │  Próxima renovación: 28 de abril 2026   │
  │                                          │
  │  [COMENZAR A EXPLORAR]                  │
  └─────────────────────────────────────────┘
```

### Manejo de Casos Especiales de Google Play

| Evento | Accion en la App |
|---|---|
| `SUBSCRIPTION_RENEWED` | Extender `valid_until` en BD, notificar al usuario |
| `SUBSCRIPTION_CANCELED` | Mantener acceso hasta `expiry_time`, mostrar badge "Cancela el [fecha]" |
| `SUBSCRIPTION_EXPIRED` | Degradar a plan free, ocultar features premium |
| `SUBSCRIPTION_REVOKED` | Bloquear acceso inmediato, notificar por push y email |
| `SUBSCRIPTION_PAUSED` | Feature de Google Play — mostrar "Suscripción pausada" |
| `GRACE_PERIOD` | Pago fallido — dar 3 días de gracia, mostrar aviso |

---

## 5. ONBOARDING — Maxima Simplicidad

### Flujo de Onboarding para Vecino (máximo 3 pasos)

```
PASO 1: Registro rápido
  ┌─────────────────────────────────────────┐
  │  Únete a la red de seguridad            │
  │  de tu barrio en Popayán               │
  │                                          │
  │  [   Continuar con Google   ]           │
  │                                          │
  │  O ingresa tu número de celular:        │
  │  [+57  │  3XX XXX XXXX    ]             │
  │  [RECIBIR CÓDIGO POR SMS]               │
  └─────────────────────────────────────────┘

PASO 2: Verifica tu direccion
  ┌─────────────────────────────────────────┐
  │  📍  ¿Dónde vives?                      │
  │                                          │
  │  Ingresa tu dirección:                  │
  │  [Calle 5 # 8-45, El Centro  ]         │
  │                                          │
  │  Toma una foto de tu fachada:           │
  │  [📸 Tomar foto]                        │
  │                                          │
  │  Tu dirección se verificará en 24h.     │
  │  Mientras tanto, puedes explorar la app │
  └─────────────────────────────────────────┘

PASO 3: Activa tu plan
  → Mostrar planes (puede saltarse y explorar sin suscripción)
  → Demo Mode: 7 días gratis sin tarjeta
```

### Demo Mode (sin necesidad de registro)
Permite explorar la app por 7 días con funciones limitadas:
- Ver mapa del sector (datos ficticios)
- Simular el flujo de alerta (sin envío real)
- Sin acceso a cámaras ni alertas reales

---

## 6. NOTIFICACIONES PUSH — Estrategia

### Categorías de Notificación (FCM Priority)

| Tipo | Prioridad FCM | Canal Android | Badge iOS | Acción |
|---|---|---|---|---|
| Alerta de pánico activa en zona | HIGH | `emergency` | 🔴 | Abrir mapa de emergencia |
| Alerta resuelta en tu zona | NORMAL | `updates` | ⚠️ | Abrir historial |
| Tu suscripción vence en 3 días | NORMAL | `billing` | 💳 | Ir a suscripción |
| Nuevo vecino en tu red | LOW | `community` | 👋 | Ignorable |
| Renovación exitosa | NORMAL | `billing` | ✅ | Ignorable |

### Canal de Emergencia (Android)
```dart
const AndroidNotificationChannel emergencyChannel = AndroidNotificationChannel(
  'emergency',
  'Alertas de Emergencia',
  description: 'Notificaciones de alerta de pánico en tu zona',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  enableLights: true,
  ledColor: Color(0xFFFF0000),
);
```

---

## 7. MAPA DE VIAJE DEL USUARIO (CJM)

### Estudiante — Primera Emergencia

```
TOUCHPOINT     PRE-ALERTA           DURANTE ALERTA        POST-ALERTA
─────────────────────────────────────────────────────────────────────
App            App en background    Pantalla confirmación  "Ayuda en camino"
               (normal)             (1s tras shake)        chat abierto

Emociones      😐 Normal            😱 Miedo/Pánico        😰 Alivio parcial
                                                           esperando ayuda

Puntos dolor   • App debe estar     • 3s countdown         • ¿Llegará alguien?
               instalada y activa   muy corto/largo?       • No sé si fue enviado

Oportunidades  • Notif recordatorio • Contador visual       • Chat en tiempo real
               de mantener app     grande y claro          con vecinos

KPIs           • % app activa       • % alertas completadas • % resueltas < 5min
               en background        vs canceladas
```

### Vecino — Responde a Alerta

```
TOUCHPOINT     RECIBE NOTIF         VE ALERTA EN MAPA     DECIDE ACTUAR
─────────────────────────────────────────────────────────────────────
Canal          Push crítico         App abierta           Chat + cámaras
               (sonido aunque       mapa zona aprox.      cercanas
               silencio)

Emociones      😲 Sorpresa/Alerta   🧐 Curiosidad          💪 Quiere ayudar
                                    preocupación

Puntos dolor   • ¿Es real o falsa   • Zona imprecisa       • ¿Qué hago?
               alarma?              por privacidad         • ¿Llamo al 123?

Oportunidades  • Badge "verificada" • Instrucciones claras  • Guión de acción
               vs "posible falsa"   en pantalla            sugerido

KPIs           • % notificaciones   • % que abren la app   • % llaman al 123
               abiertas            al recibir alerta
```

---

## 8. KPIs DEL PRODUCTO — Norte Estrella

| KPI | Meta MVP (Sprint 4) | Meta 6 meses |
|---|---|---|
| Tiempo alerta enviada → recibida por vecino | < 3 segundos | < 2 segundos |
| % alertas verdaderas vs falsas alarmas | > 85% verdaderas | > 92% |
| Tasa de adopción en institución piloto | > 70% estudiantes | > 90% |
| NPS (Net Promoter Score) | > 40 | > 60 |
| Retención mensual de vecinos suscriptos | > 75% | > 85% |
| Tiempo de activación de cuenta nueva | < 24 horas | < 1 hora |

---

## 9. CRITERIOS DE EXITO DEL SPRINT 0 (Product)

```
DONE para Sprint 0 (desde perspectiva de Producto):
□ Wireframes de flujo de pánico revisados y aprobados por CTO
□ User Stories con criterios Gherkin entregadas al QA Agent
□ SKUs de Google Play definidos y documentados para Architect Agent
□ Demo Mode especificado con alcance exacto de funciones
□ KPIs acordados y sistema de medición definido
□ Guión de Demo para institución piloto (San José Popayán) preparado
```

---

## 10. NOTIFICACION A OTROS AGENTES

**→ Compliance Agent:** Las US-001 y US-004 involucran datos de menores y ubicación.
Necesito el Privacy Clearance para ambas antes de que entren al Sprint 1. El formulario
de consentimiento del padre debe estar integrado en el flujo de onboarding de US-001.

**→ Architect Agent:** Los SKUs para Google Play son:
`milojos.vecino.basico.monthly` y `milojos.vecino.pro.monthly`.
El webhook de Google Play Pub/Sub necesita endpoint en el backend:
`POST /api/v1/subscriptions/google-play/webhook`
La activación de plan debe ser < 30 segundos desde la confirmación de compra.

**→ QA Agent:** Las User Stories US-001, US-004 y US-009 son las prioritarias para
convertir en tests Gherkin (Given/When/Then). US-004 es la más crítica —
el escenario de "3 falsas alarmas" requiere un test de integración específico.
El Demo Mode no requiere tests de pagos (Google Play sandbox solo en Sprint 3).

---

## 11. BACKLOG PRIORIZADO — Resumen

| ID | Historia | Sprint | Story Points | Prioridad |
|---|---|---|---|---|
| US-001 | Registro de Estudiante con QR | 1 | 8 | MUST HAVE |
| US-002 | Registro de Vecino con verificación domicilio | 1 | 5 | MUST HAVE |
| US-003 | Login con Google OAuth | 1 | 3 | MUST HAVE |
| US-004 | Gesto de Pánico (Shake) + Confirmación | 1 | 13 | MUST HAVE |
| US-005 | Cancelación de Falsa Alarma | 1 | 3 | MUST HAVE |
| US-006 | Recepción de Alertas (Vecino) | 1 | 5 | MUST HAVE |
| US-007 | Compartir Cámara IP | 2 | 8 | SHOULD HAVE |
| US-008 | Ver Cámara en Emergencia | 2 | 13 | SHOULD HAVE |
| US-009 | Suscripción Google Play (Vecino) | 3 | 8 | MUST HAVE |
| US-010 | Suscripción Institucional (B2B) | 3 | 5 | MUST HAVE |
| US-011 | Dashboard Admin Institución | 3 | 8 | MUST HAVE |
| US-012 | Panel Policía Nacional | 3 | 5 | SHOULD HAVE |
| US-013 | Historial y Estadísticas | 4 | 5 | COULD HAVE |
| US-014 | Demo Mode (7 días gratis) | 1 | 3 | SHOULD HAVE |

**Total Sprint 1:** 37 puntos
**Total Sprint 2:** 21 puntos
**Total Sprint 3:** 26 puntos
**Total Sprint 4:** 5 puntos

---
*Product Owner Agent — MilOjos — Informe #1 — 2026-03-28*
