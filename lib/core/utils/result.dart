import '../errors/failure.dart';

/// A typed success/failure wrapper for repository return values.
///
/// Why not just throw? Because a repository's failure modes are part of its
/// contract. Returning `Result<T>` forces every call site to acknowledge that
/// the call can fail, and lets Riverpod notifiers translate a [Failure] into UI
/// state without a `try/catch` in the presentation layer.
///
/// Uses Dart 3 sealed classes + pattern matching:
///
/// ```dart
/// switch (result) {
///   Success(:final data) => ...,
///   FailureResult(:final failure) => ...,
/// }
/// ```
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;

  const factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is FailureResult<T>;

  /// Value on success, `null` on failure.
  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    FailureResult<T>() => null,
  };

  /// Failure on error, `null` on success.
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    FailureResult<T>(:final failure) => failure,
  };

  /// Exhaustive fold into a single value — the idiomatic way to consume this.
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success<T>(data: final d) => success(d),
      FailureResult<T>(failure: final f) => failure(f),
    };
  }

  /// Transforms the success value, propagating failures untouched.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(data: final d) => Success<R>(transform(d)),
      FailureResult<T>(failure: final f) => FailureResult<R>(f),
    };
  }

  /// Unwraps the value or rethrows — use only where a failure is a bug.
  T getOrThrow() {
    return switch (this) {
      Success<T>(data: final d) => d,
      FailureResult<T>(failure: final f) => throw StateError(f.message),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;
}

/// Runs [action] and funnels any thrown object through [FailureMapper].
///
/// Repositories use this so a single helper owns the `try/catch` boilerplate:
///
/// ```dart
/// Future<Result<User>> login(...) => guard(() => _remote.login(...));
/// ```
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Success<T>(await action());
  } catch (error, stackTrace) {
    return FailureResult<T>(FailureMapper.from(error, stackTrace));
  }
}
