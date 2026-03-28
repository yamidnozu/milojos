import 'package:dartz/dartz.dart';
import 'package:milojos_mobile/core/errors/failures.dart';

/// Clase base abstracta para todos los Use Cases de la capa de dominio.
///
/// REGLA: Domain es 100% Dart puro.
/// Ningún UseCase puede importar packages de Flutter (solo dart:core y dartz).
///
/// Uso:
/// ```dart
/// class MiUseCase extends UseCase<MiEntidad, MiParams> {
///   @override
///   Future<Either<Failure, MiEntidad>> call(MiParams params) async {
///     return repository.hacerAlgo(params);
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// UseCase sin parámetros — usar [NoParams] como tipo de Params.
/// ```dart
/// class GetCurrentUser extends UseCase<UserEntity, NoParams>
/// ```
class NoParams {
  const NoParams();
}
