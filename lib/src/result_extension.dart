// Copyright 2023 Hugo Pointcheval
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';

import 'package:sealed_result/src/result.dart';

/// Extension on [Result] to provide some useful methods.
///
/// This extension permits to use the [Result] methods as operators.
extension ResultExt<Success, Failure> on Result<Success, Failure> {
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

/// Extension on [Future<Result>] to provide some useful methods.
///
/// This extension proxies the [Result] methods to the [Future] ones.
extension FutureResultExt<Success, Failure>
    on Future<Result<Success, Failure>> {
  /// Returns true if the result is [Ok].
  Future<bool> get isOk => then((value) => value.isOk);

  /// Returns true if the result is [Err].
  Future<bool> get isErr => then((value) => value.isErr);

  /// The value of the result, if the result was successful.
  /// Discarding any error if there was one.
  Future<Success?> get ok => then((value) => value.ok);

  /// The error that occurred while attempting to retrieve the value.
  /// Discarding any value if there was one.
  Future<Failure?> get err => then((value) => value.err);

  /// The original stack trace of [err], if provided.
  Future<StackTrace?> get stackTrace => then((value) => value.stackTrace);

  /// The value of the result, or throws an exception if there was an error.
  ///
  /// If [message] is provided, it will be used in the exception message.
  Future<Success> expect([String? message]) =>
      then((value) => value.expect(message));

  /// The value of the result, or throws an exception if there was an error.
  ///
  /// Same as [expect] without the message.
  Future<Success> unwrap() => expect(); // Just to be consistent with Rust

  /// The error of the result, or throws an exception if there was a value.
  ///
  /// If [message] is provided, it will be used in the exception message.
  Future<Failure> expectErr([String? message]) =>
      then((value) => value.expectErr(message));

  /// The error of the result, or throws an exception if there was a value.
  ///
  /// Same as [expectErr] without the message.
  Future<Failure> unwrapErr() => expectErr(); // Just to be consistent with Rust

  /// Returns the contained [Ok] value or a provided default.
  ///
  /// Arguments passed to [unwrapOr] are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to use
  /// [unwrapOrElse], which is lazily evaluated.
  Future<Success> unwrapOr(Success defaultValue) =>
      then((value) => value.unwrapOr(defaultValue));

  /// Returns the contained [Ok] value or computes it from a closure.
  ///
  /// Arguments passed to [unwrapOrElse] are lazily evaluated;
  Future<Success> unwrapOrElse(
    ResultCallbackArg<Success, Failure> defaultValue,
  ) =>
      then((value) => value.unwrapOrElse(defaultValue));

  /// Returns true if the result is an [Ok] value containing [other].
  Future<bool> contains(Success other) =>
      then((value) => value.contains(other));

  /// Returns true if the result is an [Err] value containing [other].
  Future<bool> containsErr(Failure other) =>
      then((value) => value.containsErr(other));

  /// Returns true if the result is an [Ok] value containing [other].
  ///
  /// [other] is lazily evaluated.
  Future<bool> containsLazy(ResultCallback<Success> other) =>
      then((value) => value.containsLazy(other));

  /// Returns true if the result is an [Err] value containing [other].
  ///
  /// [other] is lazily evaluated.
  Future<bool> containsErrLazy(ResultCallback<Failure> other) =>
      then((value) => value.containsErrLazy(other));

  /// Calls the provided closure with a reference to the contained
  /// value (if [Ok]).
  Future<Result<Success, Failure>> inspect(
    ResultCallbackArg<void, Success> fn,
  ) =>
      then((value) => value.inspect(fn));

  /// Calls the provided closure with a reference to the contained
  /// error (if [Err]).
  Future<Result<Success, Failure>> inspectErr(
    ResultCallbackArg<void, Failure> fn,
  ) =>
      then((value) => value.inspectErr(fn));

  /// Returns [result] if the result is [Ok], otherwise returns the [Err] value
  /// of this.
  ///
  /// Arguments passed to [and] are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to
  /// use [andThen], which is lazily evaluated.
  Future<Result<U, Failure>> and<U>(Result<U, Failure> result) =>
      then((value) => value.and(result));

  /// Call [fn] if the result is [Ok], otherwise returns the [Err] value
  /// of this.
  ///
  /// This function can be used for control flow based on [Result] values.
  ///
  /// Arguments passed to [andThen] are lazily evaluated.
  Future<Result<U, Failure>> andThen<U>(
    ResultCallbackArg<Result<U, Failure>, Success> fn,
  ) =>
      then((value) => value.andThen(fn));

  /// Returns [result] if the result is [Err], otherwise returns the [Ok] value
  /// of this.
  ///
  /// Arguments passed to [or] are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to
  /// use [orElse], which is lazily evaluated.
  ///
  /// The stack trace of the current error is chained to the stack trace of
  /// [result].
  Future<Result<Success, U>> or<U>(Result<Success, U> result) =>
      then((value) => value.or(result));

  /// Call [fn] if the result is [Err], otherwise returns the [Ok] value
  /// of this.
  ///
  /// This function can be used for control flow based on [Result] values.
  ///
  /// Arguments passed to [orElse] are lazily evaluated.
  Future<Result<Success, U>> orElse<U>(
    ResultCallbackArg<Result<Success, U>, Failure> fn,
  ) =>
      then((value) => value.orElse(fn));

  /// Maps a Result<Success, Failure> to Result<U, Failure> by applying a
  /// function to a contained [Ok] value, leaving an [Err] value untouched.
  ///
  /// This function can be used to compose the results of two functions.
  Future<Result<U, Failure>> map<U>(ResultCallbackArg<U, Success> fn) =>
      then((value) => value.map(fn));

  /// Maps a Result<Success, Failure> to Result<U, Failure> by applying a
  /// function to a contained [Ok] value, leaving an [Err] value untouched.
  Future<Result<U, Failure>> mapAsync<U>(
    ResultCallbackAsyncArg<U, Success> fn,
  ) =>
      then((value) => value.mapAsync(fn));

  /// Maps a Result<Success, Failure> to Result<Success, U> by applying a
  /// function to a contained [Err] value, leaving an [Ok] value untouched.
  ///
  /// This function can be used to pass through a successful result while
  /// handling an error.
  Future<Result<Success, U>> mapErr<U>(ResultCallbackArg<U, Failure> fn) =>
      then((value) => value.mapErr(fn));

  /// Maps a Result<Success, Failure> to Result<Success, U> by applying a
  /// function to a contained [Err] value, leaving an [Ok] value untouched.
  Future<Result<Success, U>> mapErrAsync<U>(
    ResultCallbackAsyncArg<U, Failure> fn,
  ) =>
      then((value) => value.mapErrAsync(fn));

  /// Returns the provided default (if [Err]), or applies a function to the
  /// contained value (if [Ok]),
  ///
  /// Arguments passed to [mapOr] are eagerly evaluated; if you are passing
  /// the result of a function call, it is recommended to
  /// use [mapOrElse], which is lazily evaluated.
  Future<U> mapOr<U>(U defaultValue, ResultCallbackArg<U, Success> fn) => then(
        (value) => value.mapOr(defaultValue, fn),
      );

  /// Returns the provided default (if [Err]), or applies a function to the
  /// contained value (if [Ok]),
  Future<U> mapOrAsync<U>(
    FutureOr<U> defaultValue,
    ResultCallbackAsyncArg<U, Success> fn,
  ) =>
      then((value) => value.mapOrAsync(defaultValue, fn));

  /// Maps a Result<Success, Failure> to U by applying fallback function
  /// default to a contained [Err] value, or function [fn] to a
  /// contained [Ok] value.
  ///
  /// This function can be used to unpack a successful result while
  /// handling an error.
  ///
  /// If you just want to get the value of the result, prefer using Dart 3
  /// pattern matching instead:
  /// ```dart
  /// final result = Result.ok(42);
  /// final value = switch (result) {
  ///   Ok(ok: final value) => value,
  ///   Err(err: final error) => 0,
  /// };
  /// ```
  Future<U> mapOrElse<U>(
    ResultCallbackArg<U, Failure> defaultFn,
    ResultCallbackArg<U, Success> fn,
  ) =>
      then((value) => value.mapOrElse(defaultFn, fn));

  /// Folds a Result<Success, Failure> into a single value by applying a
  /// function to it.
  ///
  /// Same as [mapOrElse] with inverted arguments.
  ///
  /// If you just want to get the value of the result, prefer using Dart 3
  /// pattern matching instead:
  /// ```dart
  /// final result = Result.ok(42);
  /// final value = switch (result) {
  ///   Ok(ok: final value) => value,
  ///   Err(err: final error) => 0,
  /// };
  /// ```
  Future<U> fold<U>(
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
  ) =>
      then((value) => value.mapOrElseAsync(defaultFn, fn));

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
  Future<Result<T, Failure>> flatten<T>() => then((value) => value.flatten());
}
