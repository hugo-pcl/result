// Copyright 2023 Hugo Pointcheval
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';

import 'package:meta/meta.dart';

/// {@template result_exception}
/// [ResultException] is sometimes threw by [Result] objects.
///
/// ```dart
/// throw ResultException('Emergency failure!');
/// ```
/// {@endtemplate}
@immutable
class ResultException implements Exception {
  /// {@macro result_exception}
  const ResultException(this.message);

  /// The message of the exception.
  final String message;

  @override
  String toString() => 'ResultException: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultException &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

typedef ResultCallback<Success extends Object?, Failure extends Exception>
    = Success Function();

@immutable
sealed class Result<Success extends Object?, Failure extends Exception> {
  const Result._();

  /// Create a successful result.
  const factory Result.ok(Success ok) = Ok<Success, Failure>;

  /// Create an unsuccessful result.
  const factory Result.err(Failure err, [StackTrace? stackTrace]) =
      Err<Success, Failure>;

  /// Create a result from a callback.
  ///
  /// [callback] is called and the result is returned.
  factory Result.of(
    ResultCallback<Success, Failure> callback,
  ) {
    try {
      return Result.ok(callback());
    } catch (e, stackTrace) {
      return Result.err(e as Failure, stackTrace);
    }
  }

  /// Create a result from a condition.
  /// If [condition] is true, then return [value] in [Result.ok], otherwise
  /// return [error] in [Result.err].
  factory Result.fromCondition({
    required bool condition,
    required Success value,
    required Failure error,
  }) =>
      condition ? Result.ok(value) : Result.err(error);

  /// Create a result from a condition lazily.
  /// If [condition]'s result is true, then return [value] in
  /// [Result.ok], otherwise return [error] in [Result.err].
  ///
  /// [value] and [error] are only called if [condition] is true.
  factory Result.fromConditionLazy({
    required bool Function() condition,
    required Success Function() value,
    required Failure Function() error,
  }) =>
      condition.call() ? Result.ok(value()) : Result.err(error());

  /// Create a result from a [FutureOr] callback.
  static Future<Result<Success, Failure>>
      fromFuture<Success extends Object?, Failure extends Exception>(
    FutureOr<Success> Function() futureOr,
  ) async {
    try {
      return Result.ok(await futureOr());
    } catch (e, stackTrace) {
      return Result.err(e as Failure, stackTrace);
    }
  }

  /// Returns true if the result is [Ok].
  bool get isOk => this is Ok;

  /// Returns true if the result is [Err].
  bool get isErr => this is Err;

  /// The value of the result, if the result was successful.
  /// Discarding any error if there was one.
  Success? get ok;

  /// The exception that occurred while attempting to retrieve the value.
  /// Discarding any value if there was one.
  Failure? get err;

  /// The original stack trace of [err], if provided.
  StackTrace? get stackTrace;

  /// The value of the result, or throws an exception if there was an error.
  Success expect([String? message]) {
    if (isOk) {
      return ok!;
    } else {
      final buffer = StringBuffer(message ?? '');
      if (message != null && err != null) {
        buffer.write(': ');
      }
      if (err != null) {
        buffer.write(err);
      }
      throw ResultException(buffer.toString());
    }
  }

  /// The error of the result, or throws an exception if there was a value.
  Failure expectErr([String? message]) {
    if (isErr) {
      return err!;
    } else {
      final buffer = StringBuffer(message ?? '');
      if (message != null && ok != null) {
        buffer.write(': ');
      }
      if (ok != null) {
        buffer.write(ok);
      }
      throw ResultException(buffer.toString());
    }
  }

  /// Get [U] value, may throw an exception.
  U unwrap<U>() {
    final u = switch (this) {
      Ok(ok: final value) when value is U && value != null => value,
      Err(err: final error) when error is U => error as U,
      _ => throw const ResultException(
          'Illegal use. You should check isOk or isErr before calling unwrap',
        )
    };

    // Need to assert that [u] is not null, otherwise the compiler will complain
    // that [u] is nullable. Even though we know it's not, because we checked
    // for it in the switch statement above.
    return u!;
  }

  /// Get [U] value, or [defaultValue] if there was an error retrieving it.
  U? unwrapOr<U>({U? defaultValue}) => switch (this) {
        Ok(ok: final value) when value is U => value,
        Err(err: final error) when error is U => error as U,
        _ => defaultValue,
      };

  /// Get [U] value, or [defaultValue] if there was an error retrieving it.
  ///
  /// [defaultValue] is lazily evaluated.
  U? unwrapOrElse<U>({required U Function() defaultValue}) => switch (this) {
        Ok(ok: final value) when value is U => value,
        Err(err: final error) when error is U => error as U,
        _ => defaultValue(),
      };

  /// Check if this result contains a value that is equal to [other].
  bool contains<U>(U other) => switch (this) {
        Ok(ok: final value) when value is U => value == other,
        _ => false,
      };

  /// Check if this result contains an error that is equal to [other].
  bool containsErr<U>(U other) => switch (this) {
        Err(err: final error) when error is U => error == other,
        _ => false,
      };

  /// Check if this result contains a value that is equal to [other].
  ///
  /// [other] is lazily evaluated.
  bool containsLazy<U>(U Function() other) => switch (this) {
        Ok(ok: final value) when value is U => value == other(),
        _ => false,
      };

  /// Check if this result contains an error that is equal to [other].
  ///
  /// [other] is lazily evaluated.
  bool containsErrLazy<U>(U Function() other) => switch (this) {
        Err(err: final error) when error is U => error == other(),
        _ => false,
      };

  /// Returns [result] if the result is [Ok], otherwise returns the [Err] value
  /// of this.
  Result<U, Failure> and<U>(Result<U, Failure> result) => switch (this) {
        Ok() => result,
        Err(err: final error) => Err(error),
      };

  /// Call [fn] if the result is [Ok], otherwise returns the [Err] value
  /// of this.
  Result<U, Failure> andThen<U>(Result<U, Failure> Function(Success) fn) =>
      switch (this) {
        Ok(ok: final value) => fn(value),
        Err(err: final error) => Err(error),
      };

  /// Returns [result] if the result is [Err], otherwise returns the [Ok] value
  /// of this.
  Result<Success, U> or<U extends Exception>(Result<Success, U> result) =>
      switch (this) {
        Ok(ok: final value) => Ok(value),
        Err() => result,
      };

  /// Call [fn] if the result is [Err], otherwise returns the [Ok] value
  /// of this.
  Result<Success, U> orElse<U extends Exception>(
    Result<Success, U> Function(Failure) fn,
  ) =>
      switch (this) {
        Ok(ok: final value) => Ok(value),
        Err(err: final error) => fn(error),
      };

  /// Maps a [Result<T, E>] to [Result<U, E>] by applying a function
  /// to a contained Ok value, leaving an Err value untouched.
  Result<U, Failure> map<U>(U Function(Success) fn) => switch (this) {
        Ok(ok: final value) => Ok(fn(value)),
        Err(err: final error) => Err(error),
      };

  /// Maps a [Result<T, E>] to [Result<U, E>] by applying a function
  /// to a contained Ok value, leaving an Err value untouched.
  Future<Result<U, Failure>> mapAsync<U>(
    FutureOr<U> Function(Success) fn,
  ) async =>
      switch (this) {
        Ok(ok: final value) => Ok(await fn(value)),
        Err(err: final error) => Err(error),
      };

  /// Maps a [Result<T, E>] to [Result<T, F>] by applying a function
  /// to a contained Err value, leaving an Ok value untouched.
  Result<Success, F> mapErr<F extends Exception>(F Function(Failure) fn) =>
      switch (this) {
        Ok(ok: final value) => Ok(value),
        Err(err: final error) => Err(fn(error)),
      };

  /// Maps a [Result<T, E>] to [Result<T, F>] by applying a function
  /// to a contained Err value, leaving an Ok value untouched.
  Future<Result<Success, F>> mapErrAsync<F extends Exception>(
    FutureOr<F> Function(Failure) fn,
  ) async =>
      switch (this) {
        Ok(ok: final value) => Ok(value),
        Err(err: final error) => Err(await fn(error)),
      };

  /// Maps a [Result<T, E>] to [Result<U, F>] by applying functions
  /// to a contained [Ok] value and [Err] respectively.
  Result<U, F> mapOrElse<U, F extends Exception>(
    U Function(Success) ok,
    F Function(Failure) err,
  ) =>
      switch (this) {
        Ok(ok: final value) => Ok(ok(value)),
        Err(err: final error) => Err(err(error)),
      };

  /// Maps a [Result<Success, Failure>] to [Result<U, F>] asynchronously by
  /// applying a function to a contained [Ok] value and [Err] respectively.
  Future<Result<U, F>> mapOrElseAsync<U, F extends Exception>(
    FutureOr<U> Function(Success) ok,
    FutureOr<F> Function(Failure) err,
  ) async =>
      switch (this) {
        Ok(ok: final value) => Future.sync(() async => Ok(await ok(value))),
        Err(err: final error) => Future.sync(() async => Err(await err(error))),
      };

  /// Flattens a nested [Result] structure.
  Result<U, Failure> flatten<U>() => switch (this) {
        Ok(ok: final value) when value is Result<U, Failure> => value,
        Err(err: final error) => Err(error),
        _ => throw ResultException(
            'Illegal use. Nested Result must be of type Result<$U, Failure>',
          ),
      };

  /// Flattens a nested [Result] structure asynchronously.
  Future<Result<U, Failure>> flattenAsync<U>() => switch (this) {
        Ok(ok: final value) when value is Future<Result<U, Failure>> =>
          value.then<Result<U, Failure>>((value) => value),
        Err(err: final error) => Future.value(Err(error)),
        _ => throw ResultException(
            'Illegal use. Nested Result must be of type Result<$U, Failure>',
          ),
      };

  /// Fold a [Result<Success, Failure>] into a single value by applying a
  /// function to it.
  U fold<U>(
    U Function(Success) ok,
    U Function(Failure) err,
  ) =>
      switch (this) {
        Ok(ok: final value) => ok(value),
        Err(err: final error) => err(error),
      };

  /// Fold a [Result<Success, Failure>] into a single value by applying a
  /// function to it asynchronously.
  Future<U> foldAsync<U>(
    FutureOr<U> Function(Success) ok,
    FutureOr<U> Function(Failure) err,
  ) =>
      switch (this) {
        Ok(ok: final value) => Future.sync(() => ok(value)),
        Err(err: final error) => Future.sync(() => err(error)),
      };

  /// Compares the result to [other], returning true if they are equal.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Result &&
          runtimeType == other.runtimeType &&
          ok == other.ok &&
          err == other.err;

  /// Returns a hash code for this result.
  @override
  int get hashCode => ok.hashCode ^ err.hashCode;
}

class Ok<Success extends Object?, Failure extends Exception>
    extends Result<Success, Failure> {
  const Ok(this.ok) : super._();

  @override
  final Success ok;

  @override
  Failure? get err => null;

  @override
  StackTrace? get stackTrace => null;

  @override
  String toString() => switch (ok) {
        null => 'Ok(null)',
        Future() => 'Ok(${ok.runtimeType})',
        _ => 'Ok($ok)',
      };
}

class Err<Success extends Object?, Failure extends Exception>
    extends Result<Success, Failure> {
  const Err(this.err, [this.stackTrace]) : super._();

  @override
  final Failure err;

  @override
  final StackTrace? stackTrace;

  @override
  Success? get ok => null;

  @override
  String toString() => switch (err) {
        _ => 'Err($err)',
      };
}

extension ResultExt<Success extends Object?, Failure extends Exception>
    on Result<Success, Failure> {
  /// Returns [result] if the result is [Ok], otherwise returns the [Err] value
  /// of this.
  ///
  /// This is equivalent to [Result.and].
  Result<Success, Failure> operator &(Result<Success, Failure> result) =>
      and(result);

  /// Returns [result] if the result is [Err], otherwise returns the [Ok] value
  /// of this.
  ///
  /// This is equivalent to [Result.or].
  Result<Success, Failure> operator |(Result<Success, Failure> result) =>
      or(result);
}
