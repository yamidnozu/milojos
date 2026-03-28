import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:milojos_mobile/core/errors/failures.dart';
import 'package:milojos_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:milojos_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Implementación real del repositorio conectado a Supabase Auth.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.supabase});

  final SupabaseClient supabase;
  final _currentUserController = StreamController<UserEntity?>.broadcast();

  // Mapear strings de RLS a ENUM interno
  UserRole _stringToRole(String roleStr) {
    switch (roleStr) {
      case 'student':
        return UserRole.student;
      case 'neighbor':
        return UserRole.neighbor;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.none;
    }
  }

  UserEntity _mapSupabaseUserToEntity(User? user) {
    if (user == null) {
      return const UserEntity(
        id: '',
        email: '',
        fullName: 'Desconocido',
        role: UserRole.none,
        isActive: false,
      );
    }
    
    // Supabase permite Metadata adjunta, donde se guardaría el rol.
    final metadata = user.userMetadata ?? {};
    
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      fullName: metadata['full_name'] ?? 'Usuario MilOjos',
      role: _stringToRole(metadata['role'] ?? 'none'),
      photoUrl: metadata['avatar_url'],
      isActive: true,
    );
  }

  @override
  Stream<UserEntity?> watchCurrentUser() {
    // Al conectar una suscripción nativa de Supabase, emite el estado (login/out)
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _currentUserController.add(_mapSupabaseUserToEntity(session.user));
      } else {
        _currentUserController.add(null); // Usuario deslogueado
      }
    });
    
    // Devolvemos el estado actual al iniciar
    // TODO: Envoltorio para cuando se abra en main.dart
    return _currentUserController.stream;
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      // In-App browser Google OAuth request
      final result = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.milojos.app://login-callback',
      );
      
      if (!result) {
        return const Left(ServerFailure('No se pudo abrir el navegador seguro.'));
      }
      
      // La respuesta llegará al listener de onAuthStateChange
      // Por consistencia, se puede esperar la sesión para el Either.
      final user = supabase.auth.currentUser;
      if (user != null) {
         return Right(_mapSupabaseUserToEntity(user));
      } else {
         return const Left(ServerFailure('Autenticación cancelada o en proceso...'));
      }
    } catch (e) {
      return Left(ServerFailure('Fallo Supabase: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithStudentQR(String qrToken) async {
    try {
      // Un Estudiante menor no lee cuentas OAuth ni correos por privacidad.
      // Se generó un Hash (qrToken) cifrado por el Rector que la APP usará
      const functionParams = {'qr_token': qrToken};
      final AuthResponse res = await supabase.functions.invoke(
        'verify-student-qr', 
        body: functionParams
      );
      
      if (res.session != null) {
        // La Edge Function devuelve un JWT estático anónimo con sub=student_id 
        await supabase.auth.setSession(res.session!.refreshToken!);
        return Right(_mapSupabaseUserToEntity(res.session!.user));
      }
      
      return const Left(ConsentRequiredFailure('El QR expiró o el Padre no ha firmado.'));
    } catch (e) {
      return Left(ServerFailure('Error con Servidor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await supabase.auth.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error al cerrar sesión.'));
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return supabase.auth.currentSession?.accessToken;
  }
}
