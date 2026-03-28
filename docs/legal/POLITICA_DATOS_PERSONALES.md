# POLÍTICA DE TRATAMIENTO DE DATOS PERSONALES
**Proyecto de Seguridad Colaborativa "MilOjos"**
*Versión 1.0 — 2026-03-28 | En cumplimiento de la Ley 1581 de 2012 (Colombia)*

## 1. OBJETIVO Y MARCO LEGAL
La presente Política establece los términos, condiciones y finalidades bajo las cuales **MilOjos** (en adelante "El Responsable"), en colaboración con las Instituciones Educativas y la red comunitaria de Popayán, Cauca, realiza la recolección, almacenamiento, uso, circulación y supresión de datos personales. 

Este documento cumple con la **Ley 1581 de 2012**, el **Decreto 1377 de 2013**, la **Ley 1098 de 2006** (Código de la Infancia y la Adolescencia) y demás normativas complementarias en Colombia.

## 2. RESPONSABLE DEL TRATAMIENTO
* **Razón Social / Proyecto:** MilOjos S.A.S. (En constitución)
* **Ciudad:** Popayán, Cauca, Colombia
* **Correo Electrónico de Privacidad:** privacidad@milojos.com.co

## 3. CLASIFICACIÓN DE DATOS (NIVELES DE SENSIBILIDAD)
El ecosistema MilOjos clasifica los datos recolectados en tres niveles estrictos:

### Nivel 1: Datos Críticos (Máxima Protección)
* **Datos biométricos y fotográficos:** Fotografías faciales capturadas mediante el sistema de "Alerta Silenciosa".
* **Geolocalización exacta en tiempo real:** Coordenadas GPS exactas (latitud/longitud) tomadas exclusivamente durante una Alerta de Pánico.
* **Datos de acceso a video:** Videos en tiempo real (streams WebRTC) desde las cámaras IP comunitarias durante emergencias.
* *Nota:* Estos datos **NUNCA** se exhiben públicamente. Su acceso está encriptado y restringido.

### Nivel 2: Datos Sensibles Especiales (Menores de Edad)
* Identificación de niños, niñas y adolescentes (NNA).
* Vinculación de parentesco mediante formularios escolares (Consentimiento Dual).
* *Regla Habilitante:* El tratamiento requiere el consentimiento explícito y previo del padre, madre o representante legal, avalado mediante firma electrónica.

### Nivel 3: Datos Básicos (Gestión de Plataforma)
* Nombres completos, correos electrónicos, números de teléfono.
* Dirección de residencia (para validación de vecinos).
* Información de facturación o suscripción procesada mediante los SDK nativos (Ej: Google Play Billing).

## 4. PERIODOS DE RETENCIÓN POR TIPO DE DATO

| Tipo de Dato / Evento | Periodo de Retención Máximo | Acción Post-Retención |
|-----------------------|-----------------------------|-----------------------|
| Fotos de Alertas (S3) | 90 días naturales           | Eliminación automática irreversible |
| Logs de Cámaras IP    | Perpetuo                    | Registro inmutable (Solo auditoría) |
| Geolocalización       | 30 días tras alerta inactiva| Anonimización espacial |
| Cuentas de Inactivos  | 2 años sin login            | Supresión de la base de datos |

## 5. PROCEDIMIENTO ARCOP
Todo Titular (o su representante legal en el caso de NNA) tiene derecho a los mecanismos ARCOP: **Acceso, Rectificación, Cancelación, Oposición y Portabilidad**.

**5.1. Canal de Atención:** 
* La solicitud debe enviarse a `privacidad@milojos.com.co` con el asunto "Derechos ARCOP - [Nombre Titular]".

**5.2. Tiempos de Respuesta (Ley 1581/12):**
* Consultas (Acceso/Portabilidad): Máximo de **diez (10) días hábiles**. 
* Reclamos (Rectificación/Cancelación/Oposición): Máximo de **quince (15) días hábiles**, con posibilidad de prórroga excepcional de ocho (8) días.

## 6. SEGURIDAD DE LA INFORMACIÓN
MilOjos implementa, mediante su Arquitectura Técnica, los siguientes mecanismos:
* **Row Level Security (RLS)** en PostgreSQL para garantizar que los usuarios solo accedan a sus propios datos.
* **Encriptación en tránsito y reposo** utilizando `pgcrypto` para URLs de cámaras (RTSP).
* El registro de acceso a cámaras comunitarias y alertas es **inmutable** en base de datos. Nadie cuenta con permisos especiales de borrado.

## 7. CÁMARAS IP DE TERCEROS
En el plan MilOjos para "Vecinos", un tercero conecta una cámara IP de uso privado (Ej. apuntando a la calle externa) a la red de la plataforma. Quien aporta el hardware de cámara actúa como **Responsable primario** frente a la captura visual, concediendo a MilOjos la condición de **Encargado de Tratamiento** exclusivamente en los instantes en donde el área entra en *Estado de Alerta Activa*.

## 8. VIGENCIA Y MODIFICACIÓN
La presente Política rige a partir del 28 de marzo de 2026. Cualquier modificación sustancial será notificada a través de la aplicación móvil MilOjos.
