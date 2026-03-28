import 'package:dartz/dartz.dart';
import 'package:milojos_mobile/core/errors/failures.dart';
import 'package:milojos_mobile/features/auth/domain/entities/user_entity.dart';

/// Contrato del repositorio de autenticación - Capa de Dominio.
abstract class AuthRepository {
  /// Devuelve el usuario actualmente autenticado (via Stream para el BLoC)
  Stream<UserEntity?> watchCurrentUser();

  /// Inicia sesión o registro con Google OAuth (Vecinos)
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Inicia sesión con el Escaneo de un Código QR (Estudiantes / Menores)
  /// Product Agent (US-001): El estudiante solo requiere escanear su código para activar.
  Future<Either<Failure, UserEntity>> signInWithStudentQR(String qrCode);

  /// Cierra sesión
  Future<Either<Failure, void>> signOut();

  /// Recupera el Token JWT actual para inyectarlo en WebSockets/REST
  Future<String?> getAccessToken();
}
