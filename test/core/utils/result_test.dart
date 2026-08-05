import 'package:finance_tracker/core/errors/app_exception.dart';
import 'package:finance_tracker/core/errors/failure.dart';
import 'package:finance_tracker/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('success carries data and folds through when()', () {
      const Result<int> result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, 42);
      expect(result.failureOrNull, isNull);
      expect(result.when(success: (d) => d * 2, failure: (_) => -1), 84);
    });

    test('failure carries the failure and folds through when()', () {
      const Result<int> result = Result<int>.failure(NetworkFailure());

      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(result.when(success: (_) => 'ok', failure: (f) => f.message),
          contains('offline'));
    });

    test('map transforms success and passes failures through untouched', () {
      const Result<int> ok = Result<int>.success(2);
      const Result<int> bad = Result<int>.failure(ServerFailure());

      expect(ok.map((v) => v.toString()).dataOrNull, '2');
      expect(bad.map((v) => v.toString()).failureOrNull, isA<ServerFailure>());
    });
  });

  group('guard', () {
    test('wraps a returned value in Success', () async {
      final result = await guard(() async => 'value');
      expect(result.dataOrNull, 'value');
    });

    test('maps a thrown AppException to the matching Failure', () async {
      final result = await guard<String>(
        () async => throw const UnauthorizedException(),
      );
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
    });

    test('maps an unknown throwable to UnknownFailure', () async {
      final result = await guard<String>(() async => throw StateError('boom'));
      expect(result.failureOrNull, isA<UnknownFailure>());
    });
  });

  group('Failure.isRetryable', () {
    test('is true only for transient failures', () {
      expect(const NetworkFailure().isRetryable, isTrue);
      expect(const TimeoutFailure().isRetryable, isTrue);
      expect(const ServerFailure().isRetryable, isTrue);
      expect(const UnauthorizedFailure().isRetryable, isFalse);
      expect(const ValidationFailure('bad').isRetryable, isFalse);
    });
  });
}
