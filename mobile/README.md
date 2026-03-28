# MilOjos Mobile — Flutter App

## Estructura del proyecto

```
lib/
├── core/                    # Utilidades compartidas
│   ├── constants/
│   ├── errors/              # Failures + Exceptions
│   ├── network/             # Dio client + interceptors
│   ├── usecase/             # Clase base UseCase<T, P>
│   └── utils/
│
├── features/
│   ├── auth/                # Autenticación con Supabase
│   ├── panic_alert/         # Gesto de pánico + alertas ← SPRINT 1 PRIORITARIO
│   ├── cameras/             # Red de cámaras IP + WebRTC ← SPRINT 2
│   ├── subscriptions/       # Google Play Billing ← SPRINT 3
│   └── map/                 # Mapa Mapbox con alertas
│
├── injection_container.dart # GetIt dependency injection
└── main.dart
```

## Convenciones

- **Estado:** Solo BLoC + Cubit (flutter_bloc). Prohibido setState(), Provider, Riverpod.
- **Arquitectura:** Clean Architecture estricta. Domain = Dart puro, sin imports de Flutter.
- **Tests:** TDD obligatorio. Tests se escriben ANTES que la implementación.
- **Lint:** very_good_analysis. `flutter analyze --fatal-infos` debe pasar sin errores.
- **Formato:** `dart format .` antes de cada commit.

## Comandos

```bash
# Instalar dependencias
flutter pub get

# Ejecutar la app
flutter run

# Tests con cobertura
flutter test --coverage

# Análisis de lint
flutter analyze --fatal-infos

# Generar código (freezed, injectable)
dart run build_runner build --delete-conflicting-outputs
```

## Variables de entorno

Ver `lib/core/constants/env.dart` — las variables se pasan en build time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-key \
  --dart-define=MAPBOX_TOKEN=pk.xxx \
  --dart-define=BACKEND_URL=http://localhost:3000
```
