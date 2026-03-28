import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/// Sprint 1 (US-006): Notificaciones Push con FCM para Alertas Vecinales
/// 
/// Esta clase maneja la inicialización de Firebase Messaging y los callbacks
/// para recibir notificaciones (Alerta de Pánico en radio de 500m).
class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // 1. Inicializar Firebase Core 
    // NOTA: Requiere google-services.json (Android) / GoogleService-Info.plist (iOS)
    // await Firebase.initializeApp(); // Comentado temporalmente hasta tener los archivos

    try {
      // 2. Solicitar permisos (Principalmente para iOS y Android 13+)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true, // Importante para evadir modo "No Molestar" (requiere entitlement en iOS)
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('Permiso de Push Notifications CONCEDIDO.');
      }

      // 3. Obtener el Token del dispositivo (FCM Token) para enviarlo al NestJS / Supabase
      String? token = await _messaging.getToken();
      log('FCM Token del Dispositivo: $token');
      // -> Aquí dispararíamos un evento de BLoC para guardar el token en PostgreSQL (users.fcm_token)

      // 4. Configurar Callbacks
      
      // A) Cuando la App está en PRIMER PLANO (Foreground)
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // B) Cuando el usuario toca la notificación con la App abierta en BACKGROUND
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      // C) Cuando la notificación llega con la App CERRADA (Terminated)
      // Se maneja a través de un handler global de alto nivel (fuera de esta clase)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch (e) {
      log('Error inicializando Firebase Messaging: $e');
    }
  }

  static void _onForegroundMessage(RemoteMessage message) {
    log('Recibió Push Notification en FOREGROUND: ${message.notification?.title}');
    // Idealmente inyectar a un BLoC o GlobalKey para mostrar un Dialog Rojo!
    
    // Si contiene datos de alerta de pánico:
    if (message.data['type'] == 'panic_alert') {
      // context.read<PanicBloc>().add(IncomingAlertReceived(message.data['alert_id']));
    }
  }

  static void _onMessageOpenedApp(RemoteMessage message) {
    log('Usuario tocó la notificación. Abriendo alerta: ${message.data}');
    // GoRouter.of(context).push('/alert-detail/${message.data['alert_id']}');
  }
}

/// Handler Global para mensajes cuando la APP ESTÁ MUERTA (Terminated / Background).
/// ESTUDIO: Debe ser una función top-level o estática pura.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicializamos core si se necesita base de datos en bg
  // await Firebase.initializeApp();
  
  log('Handling a background message: ${message.messageId}');
  // Aquí podríamos usar flutter_local_notifications para forzar un ringtone
  // estilo sirena de policía, o levantar un CallKit/ConnectionService nativo.
}
