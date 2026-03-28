## Descripción
<!-- ¿Qué hace este PR en términos de negocio? -->

## Tipo de cambio
- [ ] `feat:` nueva funcionalidad
- [ ] `fix:` corrección de bug
- [ ] `test:` solo tests (sin cambio de lógica)
- [ ] `refactor:` refactorización sin cambio de comportamiento
- [ ] `docs:` solo documentación
- [ ] `chore:` cambio de configuración/build
- [ ] `perf:` mejora de rendimiento

## Feature afectada
<!-- auth / panic_alert / cameras / subscriptions / users / backend / infrastructure -->

## Issue relacionado
Closes #___

---

## ✅ Checklist DoD — OBLIGATORIO

> ⚠️ El PR no puede mergearse sin completar este checklist.

### Código
- [ ] Tests unitarios escritos **ANTES** del código (TDD — Red → Green → Refactor)
- [ ] `flutter test --coverage` pasa con **≥ 80%** de cobertura en la feature
- [ ] `flutter analyze --fatal-infos` sin errores ni warnings
- [ ] `dart format .` aplicado

### Compliance (Privacidad)
- [ ] Esta feature **NO** toca datos personales → continuar sin clearance
- [ ] Esta feature **SÍ** toca datos personales → Compliance Agent emitió Privacy Clearance
  - Issue de clearance: #___

### Arquitectura
- [ ] Architect Agent aprobó el diseño (no viola Clean Architecture ni ADRs)
  - Issue de aprobación: #___

### Funcionalidad
- [ ] Probado en **Android** (versión API ___) en dispositivo físico o emulador
- [ ] Probado en **iOS** (versión ___) en simulador o dispositivo
- [ ] Comportamiento **offline** verificado (sin crash, error elegante)

### Product
- [ ] Product Agent validó los criterios de aceptación (Gherkin)
  - User Story relacionada: US-___

### Documentación
- [ ] `/docs` actualizado con información de la feature
- [ ] `CHANGELOG.md` actualizado

---

## Tests incluidos
<!-- Lista los archivos de test nuevos o modificados -->

```
test/unit/...
test/integration/...
```

## Capturas / Videos (si aplica)
<!-- Agrega screenshots o clips de la feature funcionando -->

## Notas adicionales
<!-- Decisiones de diseño, compromisos aceptados, deuda técnica documentada -->
