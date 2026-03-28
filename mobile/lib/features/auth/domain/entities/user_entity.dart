import 'package:equatable/equatable.dart';

enum UserRole {
  student, // Estudiante
  neighbor, // Vecino
  admin, // Institución o SuperAdmin
  police, // Policía Nacional
  none,
}

/// Entidad de Usuario - Dominio puro
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.photoUrl,
    required this.isActive,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? photoUrl;
  final bool isActive;

  @override
  List<Object?> get props => [id, email, fullName, role, photoUrl, isActive];
}
