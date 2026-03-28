/// Constantes de entorno — valores via --dart-define en build time
/// Ejemplo:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=your-key \
///     --dart-define=BACKEND_URL=http://10.0.2.2:3000
abstract class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  static const backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://10.0.2.2:3000', // localhost en emulador Android
  );

  static const mapboxToken = String.fromEnvironment('MAPBOX_TOKEN');
}
