# INFORME #1 — Agente Legal y Privacidad (Compliance Agent)
**Proyecto MilOjos · Fecha: 2026-03-28 · Estado: ACTIVO**

---

## DECLARACION DE ACTIVACION

El Agente de Compliance está operativo. A partir de este momento, ninguna funcionalidad
que trate datos personales, biométricos o de menores puede avanzar al sprint de desarrollo
sin mi aprobación formal. Emito este primer informe con las definiciones críticas para Sprint 0.

---

## 1. CLASIFICACION LEGAL DE DATOS (Ley 1581/2012)

### Datos de Categoría CRITICA (Art. 5 — Datos Sensibles)
Requieren: consentimiento EXPRESO + cifrado AES-256 en reposo + TLS 1.3 en tránsito.
NO pueden compartirse entre vecinos sin re-autorización.

| Dato | Quién lo genera | Periodo de retención | Base legal |
|---|---|---|---|
| Fotografía del estudiante en alerta | Estudiante | 90 días → eliminación automática | Consentimiento expreso (Art. 9) |
| Ubicación GPS en tiempo real | Todos los roles | Solo durante la emergencia activa | Interés legítimo de seguridad |
| Feed de cámara IP en emergencia | Vecino (propietario) | NO se almacena por defecto | Consentimiento + autorización ad-hoc |
| Biometría facial (futuro) | Estudiante | PROHIBIDO sin ley habilitante separada | N/A por ahora |
| Historial de alertas con geolocalización | Sistema | 1 año → anonimización | Consentimiento + interés legítimo |

### Datos de Categoría SENSIBLE
Requieren: consentimiento informado + cifrado en BD + acceso por rol.

| Dato | Retención | Notas |
|---|---|---|
| Número de celular verificado | Duración de la cuenta | No compartir con terceros |
| Dirección del hogar del vecino | Duración de la cuenta | Solo para geolocalización de zona |
| Imágenes de cámara IP (no emergencia) | NO se almacenan | Solo streaming en tiempo real |

### Datos de Categoría BASICA
Tratamiento estándar con política de privacidad.

---

## 2. PROTOCOLO LEGAL — MENORES DE EDAD

### Marco Normativo Aplicable
- Ley 1581/2012 Art. 7: datos de menores requieren autorización del representante legal.
- Código de Infancia y Adolescencia (Ley 1098/2006): interés superior del menor.
- Circular Externa 002/2015 de la SIC: datos sensibles de menores.

### Consentimiento Informado Dual — Estructura

**DOCUMENTO A: Autorización del Padre/Madre/Tutor**
```
Yo, [NOMBRE], identificado con [CC/CE/PASS] [NUMERO],
en calidad de padre/madre/tutor legal del menor [NOMBRE DEL ESTUDIANTE],
AUTORIZO EXPRESAMENTE a MilOjos SAS a:

✓ Recolectar la ubicación GPS del dispositivo de mi hijo/a
  ÚNICAMENTE cuando active una alerta de pánico.

✓ Capturar una fotografía frontal desde la cámara del dispositivo
  ÚNICAMENTE en el momento de activar la alerta de pánico.

✓ Compartir dicha información con:
  - Autoridades de la institución educativa [NOMBRE COLEGIO]
  - Policía Nacional (en caso de emergencia confirmada)
  - Vecinos en un radio de 500 metros (solo ubicación aproximada)

✗ NO autorizo el almacenamiento permanente de fotografías.
✗ NO autorizo el procesamiento de datos biométricos.
✗ NO autorizo compartir datos con terceros distintos a los listados.

Esta autorización es REVOCABLE en cualquier momento enviando
solicitud a privacidad@milojos.com.co
```

**DOCUMENTO B: Resolución Rectoral de la Institución**
```
La institución educativa [NOMBRE], NIT [NUMERO], mediante
Resolución Rectoral No. [NUMERO] del [FECHA], AUTORIZA la
implementación del sistema MilOjos para sus estudiantes,
bajo las condiciones establecidas en el contrato de prestación
de servicios No. [REFERENCIA].
```

### Flujo de Activación de Cuenta Estudiante
```
1. Institución firma contrato con MilOjos SAS
2. Admin de institución carga lista de estudiantes (CSV)
3. Sistema genera QR único por estudiante
4. QR se entrega físicamente al padre/madre/tutor
5. Padre escanea QR → formulario de consentimiento digital
6. Firma electrónica del padre (válida en Colombia: Ley 527/1999)
7. Sistema activa cuenta del estudiante SOLO después del paso 6
8. Estudiante recibe credenciales de acceso
```

---

## 3. TERMINOS LEGALES — CAMARAS IP COMUNITARIAS

### Naturaleza Jurídica de MilOjos en el Ecosistema de Cámaras

MilOjos actúa como **ENCARGADO DEL TRATAMIENTO** (no responsable), según Art. 3 lit. d)
de la Ley 1581/2012. El Vecino propietario es el RESPONSABLE del tratamiento de su cámara.

### Cláusulas Obligatorias en Términos de Uso (Vecino)

**Cláusula 1 — Ownership del Stream**
"El usuario declara ser propietario o tener autorización expresa del propietario
de la cámara IP registrada. MilOjos no adquiere ningún derecho sobre el contenido
del video. El usuario es el único responsable de que su cámara esté ubicada en
espacio privado o semiprivado de su propiedad."

**Cláusula 2 — Ámbito de Acceso de Terceros**
"El feed de video podrá ser visualizado en tiempo real, sin almacenamiento,
por vecinos registrados en MilOjos ubicados en un radio máximo de [RADIO]
ÚNICAMENTE durante una alerta de pánico activa en dicho radio.
Fuera de una alerta activa, el feed es completamente privado."

**Cláusula 3 — Acceso Policial**
"En caso de emergencia confirmada, las autoridades de Policía Nacional
con acuerdo interinstitucional vigente con MilOjos podrán acceder al feed
en tiempo real. Este acceso queda registrado en log inmutable."

**Cláusula 4 — No Almacenamiento por Defecto**
"MilOjos NO almacena, graba, ni retiene el contenido de video de cámaras
privadas. Si el usuario activa la función de 'Grabación de Emergencia',
los fragmentos se almacenan por 72 horas bajo cifrado AES-256 y se eliminan
automáticamente. El usuario puede descargarlos durante ese periodo."

**Cláusula 5 — Retiro de la Red**
"El usuario puede desvincular su cámara de la red MilOjos en cualquier
momento desde la aplicación. El retiro es inmediato. No quedan copias del feed."

---

## 4. GOOGLE PAY — IMPLICACIONES LEGALES

### Marco Aplicable
- Ley 1480/2011 (Estatuto del Consumidor) — compras digitales en Colombia.
- Decreto 2364/2012 — firma electrónica en transacciones comerciales.
- Regulación de Google Pay en Colombia: opera bajo licencia de Google Payment Corp.

### Obligaciones de MilOjos con Google Pay

```
REQUERIMIENTO LEGAL                    ACCION REQUERIDA
─────────────────────────────────────────────────────────
Política de reembolsos visible         → Publicar en app y web ANTES del lanzamiento
Descripción clara del cobro recurrente → Mostrar monto, frecuencia y condiciones
Cancelación self-service obligatoria   → Usuario puede cancelar desde la app
Factura electrónica (DIAN)             → Integrar con habilitador de factura-e
Notificación de renovación             → Push/email 3 días antes del cobro
```

### Cláusula de Suscripción Obligatoria (en la app)
```
"Al suscribirte al Plan [NOMBRE], autorizas a MilOjos a cobrar
[MONTO] COP mensualmente a través de Google Pay. Puedes cancelar
en cualquier momento desde Configuración > Mi Suscripción.
La cancelación aplica al siguiente período de facturación."
```

---

## 5. ACUERDO CON POLICIA NACIONAL

### Marco Legal
- Decreto 1070/2015 — Decreto Único Reglamentario del Sector Defensa.
- Ley 62/1993 — Ley de la Policía Nacional.
- Memorando de Entendimiento requerido desde ANTES del lanzamiento.

### Condiciones Mínimas del Acuerdo Interinstitucional
1. Designar un oficial enlace de la SIJIN o MEVAL de Popayán.
2. Acceso policial solo con credenciales verificadas por Super Admin.
3. Log de acceso policial a cámaras: inmutable, auditado cada 30 días.
4. Prohibición de usar MilOjos como sistema de vigilancia masiva.
5. Protocolo de respuesta: Policía debe confirmar recepción de alerta en < 2 min.

---

## 6. REGISTRO ANTE LA SIC

### Pasos Obligatorios Antes del Lanzamiento Público

```
PASO 1: Constitución en Cámara de Comercio de Popayán
  → SAS o empresa unipersonal con objeto social que incluya "servicios de seguridad digital"

PASO 2: Registro de Base de Datos ante la SIC
  → Formulario en línea: www.sic.gov.co/registro-bases-de-datos
  → Costo: 0 pesos (registro gratuito)
  → Tiempo: 15-30 días hábiles

PASO 3: Designación de Responsable de Datos
  → Nombre del responsable legal del tratamiento
  → Correo de contacto: privacidad@milojos.com.co (obligatorio publicar)

PASO 4: Publicación de la Política de Privacidad
  → Debe estar enlazada desde la app store listing
  → Debe estar accesible sin autenticación en la web
```

---

## 7. ENTREGABLES — SPRINT 0 (Prioridades)

| Entregable | Deadline | Estado |
|---|---|---|
| Política de Tratamiento de Datos v1 | Semana 1 | PENDIENTE |
| Formulario Consentimiento Menores v1 | Semana 1 | PENDIENTE |
| Términos de Uso Vecinos — Cámaras IP v1 | Semana 2 | PENDIENTE |
| Cláusulas legales para Google Pay | Semana 2 | PENDIENTE |
| Borrador Memorando con Policía Nacional | Semana 2 | PENDIENTE |
| Checklist de registro ante SIC | Semana 2 | PENDIENTE |

---

## 8. NOTIFICACION A OTROS AGENTES

**→ Architect Agent:** Todo endpoint que reciba datos de ubicación, foto o video DEBE
implementar cifrado TLS 1.3. La tabla de usuarios en PostgreSQL debe tener cifrado
en columnas sensibles (pgcrypto). Los logs de acceso a cámaras son INMUTABLES
(append-only, sin UPDATE/DELETE permitido).

**→ QA Agent:** El DoD de cualquier feature con datos personales debe incluir el item:
"Compliance Agent emitió Privacy Clearance para esta feature".

**→ Product Agent:** El flujo de onboarding de menores NO puede simplificarse más allá
del Consentimiento Dual. El flujo de compartición de cámara DEBE mostrar explícitamente
quién puede ver el feed y en qué condiciones.

---
*Compliance Agent — MilOjos — Informe #1 — 2026-03-28*
*Próxima revisión: al inicio de cada sprint*
