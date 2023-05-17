// Copyright 2023 Hugo Pointcheval
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sealed_result/src/result_exception.dart';

typedef ResultCallback<T> = T Function();
typedef ResultCallbackArg<T, Arg> = T Function(Arg arg);
typedef ResultCallbackAsync<T> = FutureOr<T> Function();
typedef ResultCallbackAsyncArg<T, Arg> = FutureOr<T> Function(Arg arg);

/// {@template result}
/// The Result object is a monad that allows to handle errors easily.
/// It can be either [Ok] or [Err], and gives access to a lot of
/// functions to handle them.
/// {@endtemplate}
@immutable
sealed class Result<Success, Failure> {
  /// {@macro result}
  const Result._();

  /// Create a successful result.
  ///
  /// {@macro result}
  const factory Result.ok(Success ok) = Ok<Success, Failure>;

  /// Create an unsuccessful result.
  ///
  /// You can optionally provide a [stackTrace] to be used in [ResultException].
  ///
  /// {@macro result}
  const factory Result.err(Failure err, [StackTrace? stackTrace]) =
      Err<Success, Failure>;

  /// Create a result from a function that can throw.
  ///
  /// [fn] is called and the result is returned.
  ///
  /// {@macro result}
  factory Result.from(
    ResultCallback<Success> fn,
  ) {
    try {
      return Result.ok(fn.call());
    } catch (e, stackTrace) {
      return Result.err(e as Failure, stackTrace);
    }
  }

  /// Create a result from a condition.
  ///
  /// If [condition] is true, then return [value] in [Result.ok], otherwise
  /// return [error] in [Result.err].
  ///
  /// {@macro result}
  factory Result.fromCondition({
    required bool condition,
    required Success value,
    required Failure error,
  }) =>
      condition ? Result.ok(value) : Result.err(error);

  /// Create a result from a condition lazily.
  ///
  /// If [condition]'s result is true, then return [value] in
  /// [Result.ok], otherwise return [error] in [Result.err].
  ///
  /// [value] and [error] are only called if [condition] is true or false.
  ///
  /// {@macro result}
  factory Result.fromConditionLazy({
    required bool Function() condition,
    required ResultCallback<Success> value,
    required ResultCallback<Failure> error,
  }) =>
      condition.call() ? Result.ok(value.call()) : Result.err(error.call());

  /// Create a result from a function that can throw asynchronously.
  ///
  /// [fn] is called and the result is returned.
  ///
  /// {@macro result}
  static Future<Result<Success, Failure>> fromAsync<Success, Failure>(
    ResultCallbackAsync<Success> fn,
  ) async {
    try {
      return Result.ok(await fn.call());
    } catch (e, stackTrace) {
      return Result.err(e as Failure, stackTrace);
    }
  }

  /// Returns true if the result is [Ok].
  bool get isOk;

  /// Returns true if the result is [Err].
  bool get isErr;

  /// The value of the result, if the result was successful.
  /// Discarding any error if there was one.
  Success? get ok;

  /// The error that occurred while attempting to retrieve the value.
  /// Discarding any value if there was one.
  Failure? get err;

  /// The original stack trace of [err], if provided.
  StackTrace? get stackTrace;

  Never _throwOnErr<T>(T value, [String? message]) {
    final buffer = StringBuffer(message ?? '');
    if (message != null && value != null) {
      buffer.write(': ');
    }
    if (value != null) {
      buffer.write(value);
    }
    throw ResultException(buffer.toString());
  }

  /// The value of the result, or throws an exception if there was an error.
  ///
  /// If [message] is provided, it will be used in the exception message.
  Success expect([String? message]) =>
      switch (this) { Ok() => ok!, _ => _throwOnErr(err, message) };

  /// The value of the result, or throws an exception if there was an error.
  ///
  /// Same as [expect] without the message.
  Success unwrap() => expect(); // Just to be consistent with Rust

  /// The error of the result, or throws an exception if there was a value.
  ///
  /// If [message] is provided, it will be used in the exception message.
  Failure expectErr([String? message]) =>
      switch (this) { Err() => err!, _ => _throwOnErr(ok, message) };

  /// The error of the result, or throws an exception if there was a value.
  ///
  /// Same as [expectErr] without the message.
  Failure unwrapErr() => expectErr(); // Just to be consistent with Rust

  /// Returns the contained [Ok] value or a provided default.
  ///
  /// Arguments passed to [unwrapOr] are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to use
  /// [unwrapOrElse], which is lazily evaluated.
  Success unwrapOr(Success defaultValue) => switch (this) {
        Ok() => ok!,
        _ => defaultValue,
      };

  /// Returns the contained [Ok] value or computes it from a closure.
  ///
  /// Arguments passed to [unwrapOrElse] are lazily evaluated;
  Success unwrapOrElse(ResultCallbackArg<Success, Failure> defaultValue) =>
      switch (this) {
        Ok() => ok!,
        Err(err: final error) => defaultValue.call(error),
      };

  /// Returns true if the result is an [Ok] value containing [other].
  bool contains(Success other) => switch (this) {
        Ok(ok: final value) when value == other => true,
        _ => false,
      };

  /// Returns true if the result is an [Err] value containing [other].
  bool containsErr(Failure other) => switch (this) {
        Err(err: final error) when error == other => true,
        _ => false,
      };

  /// Returns true if the result is an [Ok] value containing [other].
  ///
  /// [other] is lazily evaluated.
  bool containsLazy(ResultCallback<Success> other) => switch (this) {
        Ok(ok: final value) when value == other.call() => true,
        _ => false,
      };

  /// Returns true if the result is an [Err] value containing [other].
  ///
  /// [other] is lazily evaluated.
  bool containsErrLazy(ResultCallback<Failure> other) => switch (this) {
        Err(err: final error) when error == other.call() => true,
        _ => false,
      };

  /// Calls the provided closure with a reference to the contained
  /// value (if [Ok]).
  Result<Success, Failure> inspect(ResultCallbackArg<void, Success> fn) =>
      map((value) {
        fn.call(value);
        return value;
      });

  /// Calls the provided closure with a reference to the contained
  /// error (if [Err]).
  Result<Success, Failure> inspectErr(ResultCallbackArg<void, Failure> fn) =>
      mapErr((error) {
        fn.call(error);
        return error;
      });

  /// Returns [result] if the result is [Ok], otherwise returns the [Err] value
  /// of this.
  ///
  /// Arguments passed to [and] are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to
  /// use [andThen], which is lazily evaluated.
  Result<U, Failure> and<U>(Result<U, Failure> result) => switch (this) {
        Ok() => result,
        Err(err: final error, stackTrace: final st) => Err(error, st),
      };

  /// Call [fn] if the result is [Ok], otherwise returns the [Err] value
  /// of this.
  ///
  /// This function can be used for control flow based on [Result] values.
  ///
  /// Arguments passed to [andThen] are lazily evaluated.
  Result<U, Failure> andThen<U>(
    ResultCallbackArg<Result<U, Failure>, Success> fn,
  ) =>
      switch (this) {
        Ok(ok: final value) => fn.call(value),
        Err(err: final error, stackTrace: final st) => Err(error, st),
      };

  /// Returns [result] if the result is [Err], otherwise returns the [Ok] value
  /// of this.
  ///
  /// Arguments passed to [or] are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to
  /// use [orElse], which is lazily evaluated.
  ///
  /// The stack trace of the current error is chained to the stack trace of
  /// [result].
  Result<Success, U> or<U>(Result<Success, U> result) => switch (this) {
        Ok(ok: final value) => Ok(value),
        Err(stackTrace: final stackTrace) when result.isErr => Err(
            result.err as U,
            StackTrace.fromString(
              '${result.stackTrace}\n$stackTrace',
            ),
          ),
        Err() => result,
      };

  /// Call [fn] if the result is [Err], otherwise returns the [Ok] value
  /// of this.
  ///
  /// This function can be used for control flow based on [Result] values.
  ///
  /// Arguments passed to [orElse] are lazily evaluated.
  Result<Success, U> orElse<U>(
    ResultCallbackArg<Result<Success, U>, Failure> fn,
  ) =>
      switch (this) {
        Ok(ok: final value) => Ok(value),
        Err(err: final error, stackTrace: final stackTrace) => switch (
              fn.call(error)) {
            Ok(ok: final value) => Ok(value),
            Err(err: final err, stackTrace: final st) => Err(
                err,
                StackTrace.fromString(
                  switch (st) {
                    null => '$stackTrace',
                    _ => '$st\n$stackTrace',
                  },
                ),
              ),
          }
      };

  /// Maps a Result<Success, Failure> to Result<U, Failure> by applying a
  /// function to a contained [Ok] value, leaving an [Err] value untouched.
  ///
  /// This function can be used to compose the results of two functions.
  Result<U, Failure> map<U>(ResultCallbackArg<U, Success> fn) => switch (this) {
        Ok(ok: final value) => Ok(fn.call(value)),
        Err(err: final error, stackTrace: final st) => Err(error, st),
      };

  /// Maps a Result<Success, Failure> to Result<U, Failure> by applying a
  /// function to a contained [Ok] value, leaving an [Err] value untouched.
  Future<Result<U, Failure>> mapAsync<U>(
    ResultCallbackAsyncArg<U, Success> fn,
  ) async =>
      switch (this) {
        Ok(ok: final value) => Ok(await fn.call(value)),
        Err(err: final error, stackTrace: final st) => Err(error, st),
      };

  /// Maps a Result<Success, Failure> to Result<Success, U> by applying a
  /// function to a contained [Err] value, leaving an [Ok] value untouched.
  ///
  /// This function can be used to pass through a successful result while
  /// handling an error.
  Result<Success, U> mapErr<U>(ResultCallbackArg<U, Failure> fn) =>
      switch (this) {
        Ok(ok: final value) => Ok(value),
        Err(err: final error) => Err(fn.call(error), StackTrace.current),
      };

  /// Maps a Result<Success, Failure> to Result<Success, U> by applying a
  /// function to a contained [Err] value, leaving an [Ok] value untouched.
  Future<Result<Success, U>> mapErrAsync<U>(
    ResultCallbackAsyncArg<U, Failure> fn,
  ) async =>
      switch (this) {
        Ok(ok: final value) => Ok(value),
        Err(err: final error) => Err(await fn.call(error), StackTrace.current),
      };

  /// Returns the provided default (if [Err]), or applies a function to the
  /// contained value (if [Ok]),
  ///
  /// Arguments passed to [mapOr] are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to
  /// use [mapOrElse], which is lazily evaluated.
  U mapOr<U>(U defaultValue, ResultCallbackArg<U, Success> fn) =>
      switch (this) {
        Ok(ok: final value) => fn.call(value),
        Err() => defaultValue,
      };

  /// Returns the provided default (if [Err]), or applies a function to the
  /// contained value (if [Ok]),
  Future<U> mapOrAsync<U>(
    FutureOr<U> defaultValue,
    ResultCallbackAsyncArg<U, Success> fn,
  ) async =>
      switch (this) {
        Ok(ok: final value) => fn.call(value),
        Err() => defaultValue,
      };

  /// Maps a Result<Success, Failure> to U by applying fallback function
  /// default to a contained [Err] value, or function [fn] to a
  /// contained [Ok] value.
  ///
  /// This function can be used to unpack a successful result while
  /// handling an error.
  U mapOrElse<U>(
    ResultCallbackArg<U, Failure> defaultFn,
    ResultCallbackArg<U, Success> fn,
  ) =>
      switch (this) {
        Ok(ok: final value) => fn.call(value),
        Err(err: final error) => defaultFn.call(error),
      };

  /// Folds a Result<Success, Failure> into a single value by applying a
  /// function to it.
  ///
  /// Same as [mapOrElse] with inverted arguments.
  U fold<U>(
    ResultCallbackArg<U, Success> okFn,
    ResultCallbackArg<U, Failure> errFn,
  ) =>
      mapOrElse(errFn, okFn);

  /// Maps a Result<Success, Failure> to U by applying fallback function
  /// default to a contained [Err] value, or function [fn] to a
  /// contained [Ok] value.
  ///
  /// This function can be used to unpack a successful result while
  /// handling an error.
  Future<U> mapOrElseAsync<U>(
    ResultCallbackAsyncArg<U, Failure> defaultFn,
    ResultCallbackAsyncArg<U, Success> fn,
  ) async =>
      switch (this) {
        Ok(ok: final value) => fn.call(value),
        Err(err: final error) => defaultFn.call(error),
      };

  /// Folds a Result<Success, Failure> into a single value by applying a
  /// function to it.
  ///
  /// Same as [mapOrElseAsync] with inverted arguments.
  Future<U> foldAsync<U>(
    ResultCallbackAsyncArg<U, Success> okFn,
    ResultCallbackAsyncArg<U, Failure> errFn,
  ) async =>
      mapOrElseAsync(errFn, okFn);

  /// Flattens a nested [Result] structure.
  ///
  /// Converts from Result<Result<T, E>, E> to Result<T, E>
  Result<T, Failure> flatten<T>() => switch (this) {
        Ok(ok: final value) => switch (value) {
            Ok(ok: final value) => Ok(value as T),
            Err(err: final error, stackTrace: final st) =>
              Err(error as Failure, st),
            _ => throw ResultException(
                'Illegal use. Nested Result must be '
                'of type Result<$Success, $Failure>',
              ),
          },
        Err(err: final error, stackTrace: final st) => Err(error, st),
      };

  /// Compares this result to [other], returning true if they are equal.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Result &&
          runtimeType == other.runtimeType &&
          ok == other.ok &&
          err == other.err;

  /// Returns a hash code for this result.
  @override
  int get hashCode {
    if (isErr) {
      return err.hashCode ^ stackTrace.hashCode;
    } else {
      return ok.hashCode;
    }
  }
}

final class Ok<Success, Failure> extends Result<Success, Failure> {
  const Ok(this.ok) : super._();

  @override
  final Success ok;

  @override
  bool get isErr => false;

  @override
  bool get isOk => true;

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

final class Err<Success, Failure> extends Result<Success, Failure> {
  const Err(this.err, [this.stackTrace]) : super._();

  @override
  final Failure err;

  @override
  final StackTrace? stackTrace;

  @override
  bool get isErr => true;

  @override
  bool get isOk => false;

  @override
  Success? get ok => null;

  @override
  String toString() => switch (err) {
        _ => 'Err($err)',
      };
}
