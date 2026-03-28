// test/unit/domain/usecases/trigger_panic_alert_usecase_test.dart
//
// ESTADO: FAIL (TDD - Red phase)
// Este test DEBE FALLAR hasta que se implementen:
//   - TriggerPanicAlertUseCase
//   - AlertRepository (abstract)
//   - AlertEntity
//   - TriggerPanicAlertParams
//   - Failures: NetworkFailure, UnauthorizedFailure, TooManyAlertsFailure
//
// Agente QA: NO modificar estos tests hasta que el Architect Agent apruebe el diseño.
// Issue de aprobación: #TBD

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:milojos_mobile/core/errors/failures.dart';
import 'package:milojos_mobile/features/panic_alert/domain/entities/alert_entity.dart';
import 'package:milojos_mobile/features/panic_alert/domain/repositories/alert_repository.dart';
import 'package:milojos_mobile/features/panic_alert/domain/usecases/trigger_panic_alert_usecase.dart';

class MockAlertRepository extends Mock implements AlertRepository {}

void main() {
  late TriggerPanicAlertUseCase useCase;
  late MockAlertRepository mockRepository;

  setUp(() {
    mockRepository = MockAlertRepository();
    useCase = TriggerPanicAlertUseCase(repository: mockRepository);
  });

  final testParams = TriggerPanicAlertParams(
    userId: 'user-test-123',
    latitude: 2.4448,
    longitude: -76.6147,
    photoBase64: 'data:image/jpeg;base64,/9j/test==',
    timestamp: 1711645717,
  );

  final testAlert = AlertEntity(
    id: 'alert-test-456',
    userId: 'user-test-123',
    latitude: 2.4448,
    longitude: -76.6147,
    status: AlertStatus.active,
    triggeredAt: DateTime.fromMillisecondsSinceEpoch(1711645717000),
    respondersCount: 0,
  );

  group('TriggerPanicAlertUseCase —', () {
    test(
      'DADO parámetros válidos '
      'CUANDO se ejecuta '
      'ENTONCES retorna AlertEntity con status active',
      () async {
        when(() => mockRepository.triggerAlert(params: testParams))
            .thenAnswer((_) async => Right<Failure, AlertEntity>(testAlert));

        final result = await useCase(testParams);

        expect(result, Right<Failure, AlertEntity>(testAlert));
        expect(
          result.getOrElse(() => throw Exception()).status,
          AlertStatus.active,
        );
        verify(() => mockRepository.triggerAlert(params: testParams)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'DADO sin conexión a internet '
      'CUANDO se ejecuta '
      'ENTONCES retorna ServerFailure',
      () async {
        when(() => mockRepository.triggerAlert(params: testParams))
            .thenAnswer((_) async => const Left<Failure, AlertEntity>(ServerFailure('Timeout')));

        final result = await useCase(testParams);

        expect(result, const Left<Failure, AlertEntity>(ServerFailure('Timeout')));
      },
    );

    test(
      'DADO cuenta inactiva o penalización'
      'CUANDO se ejecuta '
      'ENTONCES retorna ServerFailure de rechazo',
      () async {
        when(() => mockRepository.triggerAlert(params: testParams))
            .thenAnswer((_) async => const Left<Failure, AlertEntity>(ServerFailure('Unauthorized')));

        final result = await useCase(testParams);

        expect(result, const Left<Failure, AlertEntity>(ServerFailure('Unauthorized')));
      },
    );
  });
}
