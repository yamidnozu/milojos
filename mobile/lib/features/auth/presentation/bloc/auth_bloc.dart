import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milojos_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:milojos_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_state.dart';

/// BLoC que centraliza la Autenticación de Supabase + MilOjos Roles.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  late final StreamSubscription<UserEntity?> _authSubscription;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<SignInGoogleRequested>(_onSignInGoogle);
    on<SignInQRRequested>(_onSignInQR);
    on<SignOutRequested>(_onSignOut);
    
    // Escuchar cambios de sesión de Supabase
    _authSubscription = authRepository.watchCurrentUser().listen((user) {
      add(AuthStatusChanged(user));
    });
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    // La subscripción ya maneja el estado inicial si existe sesión.
    // Solo mostramos 'cargando' si aún estamos en Initial
    if (state is AuthInitial) {
      emit(AuthLoading());
    }
  }

  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInGoogle(SignInGoogleRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.signInWithGoogle();
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignInQR(SignInQRRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // Lógica para conectarse al QR Token del estudiante
    final result = await authRepository.signInWithStudentQR(event.qrData);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.signOut();
    emit(Unauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
