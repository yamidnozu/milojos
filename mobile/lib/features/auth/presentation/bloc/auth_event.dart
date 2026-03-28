import 'package:equatable/equatable.dart';
import 'package:milojos_mobile/features/auth/domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class SignInGoogleRequested extends AuthEvent {}

class SignInQRRequested extends AuthEvent {
  final String qrData;
  const SignInQRRequested(this.qrData);

  @override
  List<Object?> get props => [qrData];
}

class AuthStatusChanged extends AuthEvent {
  final UserEntity? user;
  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class SignOutRequested extends AuthEvent {}
