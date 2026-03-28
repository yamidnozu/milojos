# INFORME #1 — Agente de Calidad y Metodologia (QA & Lead Dev Agent)
**Proyecto MilOjos · Fecha: 2026-03-28 · Estado: ACTIVO**

---

## DECLARACION DE ACTIVACION

El Agente QA & Lead Dev está operativo. A partir de este momento, la calidad del código
es una responsabilidad de diseño, no de corrección posterior. Emito las reglas técnicas
obligatorias para todo el equipo de desarrollo. El primer commit al repositorio no puede
ocurrir sin que el pipeline de CI esté configurado.

---

## 1. FILOSOFIA TDD — RED, GREEN, REFACTOR (Obligatorio)

```
┌─────────────────────────────────────────────────────────────────┐
│                     CICLO TDD MILOJOS                           │
│                                                                 │
│   1. RED     → Escribir test que FALLA (feature no existe)      │
│   2. GREEN   → Escribir MÍNIMO código para que el test pase     │
│   3. REFACTOR→ Mejorar el código SIN romper los tests           │
│                                                                 │
│   REGLA:  Si no hay test previo → no existe la feature          │
│   REGLA:  Un PR con ratio tests/código < 0.8 es RECHAZADO       │
│   REGLA:  Cada Use Case tiene mínimo 3 tests:                   │
│           happy path, edge case, error case                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. PRIMER TEST TDD — PanicAlertUseCase (Estado: FAIL)

Este test debe existir en el repositorio ANTES de que nadie escriba `PanicAlertUseCase`.

```dart
// test/unit/domain/usecases/trigger_panic_alert_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:milojos/core/errors/failures.dart';
import 'package:milojos/features/panic_alert/domain/entities/alert_entity.dart';
import 'package:milojos/features/panic_alert/domain/repositories/alert_repository.dart';
import 'package:milojos/features/panic_alert/domain/usecases/trigger_panic_alert_usecase.dart';

// Mock del repositorio (abstract interface)
class MockAlertRepository extends Mock implements AlertRepository {}

void main() {
  late TriggerPanicAlertUseCase useCase;
  late MockAlertRepository mockRepository;

  setUp(() {
    mockRepository = MockAlertRepository();
    useCase = TriggerPanicAlertUseCase(repository: mockRepository);
  });

  group('TriggerPanicAlertUseCase', () {
    const testParams = TriggerPanicAlertParams(
      userId: 'user-123',
      latitude: 2.4448,
      longitude: -76.6147,
      photoBase64: 'data:image/jpeg;base64,/9j/4AAQSkZJRg==',
      timestamp: 1711645717,
    );

    final testAlert = AlertEntity(
      id: 'alert-456',
      userId: 'user-123',
      latitude: 2.4448,
      longitude: -76.6147,
      status: AlertStatus.active,
      triggeredAt: DateTime.fromMillisecondsSinceEpoch(1711645717000),
    );

    // TEST 1: Happy Path — alerta activada exitosamente
    test(
      'GIVEN valid params WHEN executeued '
      'THEN returns AlertEntity with active status',
      () async {
        // Arrange
        when(() => mockRepository.triggerAlert(params: testParams))
            .thenAnswer((_) async => Right(testAlert));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, Right(testAlert));
        expect(result.getOrElse(() => throw Exception()).status,
            AlertStatus.active);
        verify(() => mockRepository.triggerAlert(params: testParams)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    // TEST 2: Edge Case — sin conexion a internet
    test(
      'GIVEN no internet connection WHEN executed '
      'THEN returns NetworkFailure',
      () async {
        // Arrange
        when(() => mockRepository.triggerAlert(params: testParams))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, const Left(NetworkFailure()));
      },
    );

    // TEST 3: Error Case — usuario no autorizado (cuenta inactiva)
    test(
      'GIVEN inactive user account WHEN executed '
      'THEN returns UnauthorizedFailure',
      () async {
        // Arrange
        when(() => mockRepository.triggerAlert(params: testParams))
            .thenAnswer((_) async => const Left(UnauthorizedFailure()));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, const Left(UnauthorizedFailure()));
      },
    );

    // TEST 4: Edge Case — falsa alarma, usuario en lista de bloqueo temporal
    test(
      'GIVEN user with 3 false alarms in last hour WHEN executed '
      'THEN returns TooManyAlertsFailure',
      () async {
        // Arrange
        when(() => mockRepository.triggerAlert(params: testParams))
            .thenAnswer((_) async => const Left(TooManyAlertsFailure()));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, const Left(TooManyAlertsFailure()));
      },
    );
  });
}
```

**Estado actual:** ✗ FAIL (los archivos que este test importa NO existen aún)
**Siguiente paso del Dev:** Crear `TriggerPanicAlertUseCase`, `AlertRepository`, `AlertEntity` para que este test pase.

---

## 3. PRIMER TEST TDD — ShakeDetectorBloc (Estado: FAIL)

```dart
// test/unit/presentation/blocs/panic_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:milojos/features/panic_alert/domain/usecases/trigger_panic_alert_usecase.dart';
import 'package:milojos/features/panic_alert/presentation/bloc/panic_bloc.dart';

class MockTriggerPanicAlertUseCase extends Mock
    implements TriggerPanicAlertUseCase {}

void main() {
  late PanicBloc panicBloc;
  late MockTriggerPanicAlertUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockTriggerPanicAlertUseCase();
    panicBloc = PanicBloc(triggerPanicAlert: mockUseCase);
  });

  tearDown(() => panicBloc.close());

  group('PanicBloc', () {
    // TEST: Estado inicial es PanicIdle
    test('initial state is PanicIdle', () {
      expect(panicBloc.state, isA<PanicIdle>());
    });

    // TEST: ShakeDetected → PanicConfirmationRequired
    blocTest<PanicBloc, PanicState>(
      'WHEN ShakeDetected event THEN emits PanicConfirmationRequired',
      build: () => panicBloc,
      act: (bloc) => bloc.add(const ShakeDetected()),
      expect: () => [isA<PanicConfirmationRequired>()],
    );

    // TEST: CancelConfirmation → PanicIdle
    blocTest<PanicBloc, PanicState>(
      'WHEN CancelConfirmation THEN returns to PanicIdle',
      build: () => panicBloc,
      seed: () => const PanicConfirmationRequired(),
      act: (bloc) => bloc.add(const CancelConfirmation()),
      expect: () => [isA<PanicIdle>()],
    );

    // TEST: ConfirmAlert → PanicSending → PanicAlertSent
    blocTest<PanicBloc, PanicState>(
      'WHEN ConfirmAlert THEN emits PanicSending then PanicAlertSent',
      build: () {
        when(() => mockUseCase(any())).thenAnswer(
          (_) async => Right(testAlert),
        );
        return panicBloc;
      },
      seed: () => const PanicConfirmationRequired(),
      act: (bloc) => bloc.add(ConfirmAlert(
        latitude: 2.4448,
        longitude: -76.6147,
        photoBase64: 'test_photo',
      )),
      expect: () => [isA<PanicSending>(), isA<PanicAlertSent>()],
    );
  });
}
```

---

## 4. DEFINITION OF DONE (DoD) — Checklist Oficial

```
╔══════════════════════════════════════════════════════════════╗
║         DEFINITION OF DONE — MILOJOS — v1.0                 ║
║                                                              ║
║  CODIGO                                                      ║
║  □ Tests unitarios escritos ANTES que el código (TDD)        ║
║  □ Cobertura ≥ 80% en domain/ y data/ de la feature         ║
║  □ Cobertura ≥ 60% en presentation/ de la feature           ║
║  □ flutter analyze --fatal-infos: 0 errores, 0 warnings      ║
║  □ dart format .: código formateado                          ║
║  □ No println/debugPrint en código de producción             ║
║                                                              ║
║  REVISION                                                    ║
║  □ PR aprobado por al menos 1 peer del equipo                ║
║  □ Todos los comentarios del reviewer resueltos              ║
║  □ Sin conflictos de merge con main                          ║
║                                                              ║
║  COMPLIANCE                                                  ║
║  □ Compliance Agent emitió Privacy Clearance (si aplica)     ║
║  □ No usa datos personales sin cifrado                       ║
║  □ Log de acceso registrado si toca datos sensibles          ║
║                                                              ║
║  ARQUITECTURA                                                ║
║  □ Architect Agent aprobó el diseño de la feature            ║
║  □ No viola las reglas de dependencia de Clean Architecture  ║
║  □ No introduce nuevas dependencias sin aprobación           ║
║                                                              ║
║  FUNCIONALIDAD                                               ║
║  □ Funciona en Android (API 26+) — probado en dispositivo    ║
║  □ Funciona en iOS (14+) — probado en simulador/dispositivo  ║
║  □ Funciona en modo offline (sin crash, error elegante)      ║
║  □ Product Agent validó criterios de aceptación              ║
║                                                              ║
║  DOCUMENTACION                                               ║
║  □ README de la feature actualizado en /docs                 ║
║  □ CHANGELOG.md actualizado con tipo Conventional Commit     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 5. PIPELINE CI/CD — GitHub Actions

```yaml
# .github/workflows/ci.yml

name: MilOjos CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  flutter_checks:
    name: Flutter Lint + Test + Coverage
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.x'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Verify formatting
        run: dart format --output=none --set-exit-if-changed .

      - name: Analyze code
        run: flutter analyze --fatal-infos

      - name: Run tests with coverage
        run: flutter test --coverage

      - name: Check coverage threshold (80%)
        uses: VeryGoodOpenSource/very_good_coverage@v3
        with:
          path: coverage/lcov.info
          min_coverage: 80
          exclude: "**/*.g.dart **/*.freezed.dart"

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          file: coverage/lcov.info

  backend_checks:
    name: Backend NestJS Lint + Test
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgis/postgis:16-3.4
        env:
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: milojos_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20.x'

      - name: Install dependencies
        working-directory: ./backend
        run: npm ci

      - name: Lint
        working-directory: ./backend
        run: npm run lint

      - name: Unit tests
        working-directory: ./backend
        run: npm run test:cov

      - name: Check coverage (80%)
        working-directory: ./backend
        run: |
          coverage=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
          if (( $(echo "$coverage < 80" | bc -l) )); then
            echo "Coverage $coverage% is below 80%"
            exit 1
          fi
```

---

## 6. CONFIGURACION DE LINT — analysis_options.yaml

```yaml
# analysis_options.yaml (raíz del proyecto Flutter)

include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "lib/l10n/**"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    # Reglas adicionales MilOjos
    avoid_print: true                        # usar logger en su lugar
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    sort_pub_dependencies: true
    unawaited_futures: true                  # CRITICO para async en BLoC
    cancel_subscriptions: true               # CRITICO para StreamSubscriptions
    close_sinks: true
    avoid_dynamic_calls: true
    lines_longer_than_80_chars: false        # desactivado para legibilidad
```

---

## 7. TEMPLATE DE PULL REQUEST

```markdown
<!-- .github/pull_request_template.md -->

## Descripcion
<!-- Qué hace este PR en términos de negocio? -->

## Tipo de cambio
- [ ] feat: nueva funcionalidad
- [ ] fix: corrección de bug
- [ ] test: solo tests (sin cambio de lógica)
- [ ] refactor: refactorización sin cambio de comportamiento
- [ ] docs: solo documentación
- [ ] chore: cambio de configuración/build

## Feature afectada
<!-- auth / panic_alert / cameras / subscriptions / users -->

## Checklist DoD (OBLIGATORIO — el PR no puede mergearse sin completar esto)

### Código
- [ ] Tests escritos ANTES del código (TDD)
- [ ] `flutter test --coverage` pasa con ≥ 80% de cobertura
- [ ] `flutter analyze --fatal-infos` sin errores
- [ ] `dart format .` aplicado

### Compliance
- [ ] Esta feature NO toca datos personales (ir directo a merge)
- [ ] Esta feature SÍ toca datos personales y Compliance Agent emitió Privacy Clearance
  - Issue de clearance: #___

### Arquitectura
- [ ] Architect Agent aprobó el diseño
  - Issue de aprobación: #___

### Funcionalidad
- [ ] Probado en Android (versión: ___)
- [ ] Probado en iOS (versión: ___)
- [ ] Comportamiento offline verificado

### Product
- [ ] Product Agent validó criterios de aceptación
  - User Story relacionada: #___

## Tests incluidos
<!-- Lista los archivos de test nuevos o modificados -->

## Notas adicionales
<!-- Decisiones de diseño, compromisos, deuda técnica documentada -->
```

---

## 8. ESTRATEGIA DE GESTION DE ESTADO — BLoC Deep Dive

### Estados del PanicBloc

```dart
// features/panic_alert/presentation/bloc/panic_state.dart

abstract class PanicState extends Equatable {
  const PanicState();

  @override
  List<Object?> get props => [];
}

// Estado: esperando shake (app normal)
class PanicIdle extends PanicState {
  const PanicIdle();
}

// Estado: shake detectado, mostrando dialogo de confirmacion
class PanicConfirmationRequired extends PanicState {
  final DateTime detectedAt;
  final int countdownSeconds;  // 3 segundos para cancelar

  const PanicConfirmationRequired({
    required this.detectedAt,
    this.countdownSeconds = 3,
  });

  @override
  List<Object?> get props => [detectedAt, countdownSeconds];
}

// Estado: usuario confirmo, enviando alerta
class PanicSending extends PanicState {
  const PanicSending();
}

// Estado: alerta enviada exitosamente
class PanicAlertSent extends PanicState {
  final String alertId;
  final int respondersCount;

  const PanicAlertSent({
    required this.alertId,
    required this.respondersCount,
  });

  @override
  List<Object?> get props => [alertId, respondersCount];
}

// Estado: error al enviar alerta
class PanicAlertError extends PanicState {
  final String message;
  final bool isOffline;

  const PanicAlertError({
    required this.message,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [message, isOffline];
}

// Estado: bloqueo temporal (3 falsas alarmas)
class PanicTemporarilyBlocked extends PanicState {
  final DateTime unblockedAt;

  const PanicTemporarilyBlocked({required this.unblockedAt});

  @override
  List<Object?> get props => [unblockedAt];
}
```

### Eventos del PanicBloc

```dart
// features/panic_alert/presentation/bloc/panic_event.dart

abstract class PanicEvent extends Equatable {
  const PanicEvent();
}

// El acelerometro detecto shake
class ShakeDetected extends PanicEvent {
  const ShakeDetected();

  @override
  List<Object?> get props => [];
}

// Usuario presiono "SI, ACTIVAR ALERTA"
class ConfirmAlert extends PanicEvent {
  final double latitude;
  final double longitude;
  final String photoBase64;

  const ConfirmAlert({
    required this.latitude,
    required this.longitude,
    required this.photoBase64,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

// Usuario cancelo o expiro el countdown
class CancelConfirmation extends PanicEvent {
  const CancelConfirmation();

  @override
  List<Object?> get props => [];
}

// Usuario marco "Estoy bien / Falsa alarma"
class ReportFalseAlarm extends PanicEvent {
  final String alertId;
  const ReportFalseAlarm({required this.alertId});

  @override
  List<Object?> get props => [alertId];
}
```

---

## 9. DEPENDENCIES FLUTTER — pubspec.yaml (Base)

```yaml
name: milojos
description: Plataforma de seguridad colaborativa - Popayan

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: '>=3.19.0'

dependencies:
  flutter:
    sdk: flutter

  # Estado
  flutter_bloc: ^8.1.5
  hydrated_bloc: ^9.1.5         # persistir estado Auth entre sesiones
  equatable: ^2.0.5

  # Inyeccion de dependencias
  get_it: ^7.6.7
  injectable: ^2.3.2

  # Red y API
  dio: ^5.4.1
  socket_io_client: ^2.0.3+1   # WebSocket para alertas

  # Autenticacion
  supabase_flutter: ^2.3.4

  # Sensores (gesto shake)
  sensors_plus: ^4.0.2

  # Camara (foto en alerta)
  camera: ^0.10.5+9

  # Geolocalizacion
  geolocator: ^11.0.0
  permission_handler: ^11.3.0

  # Mapas
  mapbox_maps_flutter: ^2.1.0

  # Video / RTSP
  flutter_vlc_player: ^7.4.1
  flutter_webrtc: ^0.9.47       # WebRTC client

  # Notificaciones Push
  firebase_core: ^2.27.0
  firebase_messaging: ^14.8.0

  # Suscripciones (Google Play Billing)
  in_app_purchase: ^3.1.13

  # Utilidades
  dartz: ^0.10.1               # Either<Failure, T> para resultados
  logger: ^2.2.0               # En lugar de print
  shared_preferences: ^2.2.2
  connectivity_plus: ^6.0.3

  # Funcional
  freezed_annotation: ^2.4.1

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Lint
  very_good_analysis: ^6.0.0

  # Testing
  mocktail: ^1.0.3
  bloc_test: ^9.1.7

  # Generacion de codigo
  build_runner: ^2.4.8
  freezed: ^2.4.7
  injectable_generator: ^2.4.3
  json_serializable: ^6.7.1
```

---

## 10. PLAN DE COBERTURA POR SPRINT

| Sprint | Features | Tests a escribir | Cobertura objetivo |
|---|---|---|---|
| Sprint 0 | Setup, infraestructura | PanicAlertUseCase tests (FAIL) | — |
| Sprint 1 | Auth, Shake, AlertBasica | Auth tests + Panic tests | ≥ 80% |
| Sprint 2 | Camaras, WebRTC | Camera tests + Stream tests | ≥ 80% |
| Sprint 3 | Google Pay, Roles | Subscription tests + Role tests | ≥ 80% |
| Sprint 4 | Beta, performance | E2E con Patrol | ≥ 80% total |

---

## 11. NOTIFICACION A OTROS AGENTES

**→ Architect Agent:** Confirmo que BLoC es el único gestor de estado. El `PanicBloc`
recibirá `TriggerPanicAlertUseCase` como dependencia inyectada vía GetIt. Los tests
no requieren mocks del SDK de Flutter (domain es Dart puro).

**→ Compliance Agent:** Agrego al DoD el ítem de Privacy Clearance. Ningún PR que
acceda a `photo_url`, `latitude/longitude` o `rtsp_url_encrypted` puede mergearse
sin su aprobación en el issue correspondiente.

**→ Product Agent:** Los criterios de aceptación de cada User Story deben estar en
formato Gherkin (Given/When/Then) para que pueda convertirlos directamente en
test cases. Los tests E2E de Sprint 4 cubren los flujos completos del Product Backlog.

---

## 12. ENTREGABLES — SPRINT 0

| Entregable | Deadline | Estado |
|---|---|---|
| `analysis_options.yaml` | Semana 1 | PENDIENTE |
| `.github/workflows/ci.yml` | Semana 1 | PENDIENTE |
| `.github/pull_request_template.md` | Semana 1 | PENDIENTE |
| `pubspec.yaml` base con dependencias | Semana 1 | PENDIENTE |
| Tests TDD de `PanicAlertUseCase` (estado FAIL) | Semana 2 | PENDIENTE |
| Tests TDD de `PanicBloc` (estado FAIL) | Semana 2 | PENDIENTE |
| `DEFINITION_OF_DONE.md` en el repositorio | Semana 2 | PENDIENTE |

---
*QA & Lead Dev Agent — MilOjos — Informe #1 — 2026-03-28*
