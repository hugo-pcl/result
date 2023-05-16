<p align="center">
<img width="700px" src="resources/result_lib.png" style="background-color: rgb(255, 255, 255)">
<h5 align="center">Result Monad to handle errors in pure Dart.</h5>
</p>

<p align="center">
<a href="https://git.wyatt-studio.fr/Wyatt-FOSS/wyatt-packages/src/branch/master/packages/wyatt_analysis">
<img src="https://img.shields.io/badge/Style-Wyatt%20Analysis-blue.svg?style=flat-square" alt="Style: Wyatt Analysis" />
</a>

<img src="https://img.shields.io/badge/SDK-Dart%20%7C%20Flutter-blue?style=flat-square" alt="SDK: Dart & Flutter" />

<a href="https://github.com/invertase/melos">
<img src="https://img.shields.io/badge/Maintained%20with-melos-f700ff.svg?style=flat-square" alt="Maintained with Melos" />
</a>

<a href="https://drone.wyatt-studio.fr/hugo/result">
  <img src="https://drone.wyatt-studio.fr/api/badges/hugo/result/status.svg?ref=refs/heads/main" />
</a>

</p>

---

[[Changelog]](./CHANGELOG.md) | [[License]](./LICENSE)

---

## Introduction

It's while exploring the new features of Dart 3 and its sealed classes that I felt like packaging this little piece of code to exploit the power of pattern matching.

This package is a simple implementation of the Result Monad, which is a way to handle errors in a functional way. It's a simple wrapper around a value that can be either a success or a failure. It's a way to avoid throwing exceptions and to handle errors in a more explicit way.

The used naming convention is inspired by the [Rust Result](https://doc.rust-lang.org/std/result/enum.Result.html) enum. (So you will find `Ok` and `Err` ).

## Features

> **Note** those code are pseudo-code, check tests and examples for more details and real code.

Different ways to create a Result:
* `Result.ok(value)` to create a successful result
* `Result.err(error, [stackTrace])` to create a failed result
* `Result.of(() => value)` to create a result from a function that can throw
* `Result.fromFuture(() => future)` to create a result from a future that can fail
* `Result.fromCondition(condition: bool, value: T, error: E)` to create a result from a condition
* `Result.fromConditionLazy(condition: () => bool, value: () => T, error: () => E)` to create a result from a condition with lazy evaluation

Different ways to extract the value from a Result:
* `result.ok` to get the value if the result is successful and discard the error if it's a failure
* `result.err` to get the error if the result is a failure and discard the value if it's a success
* `result.stackTrace` to get the stack trace if the result is a failure
* `result.expect()` to get the value if the result is successful or throw an exception if it's a failure
* `result.expectErr()` to get the error if the result is a failure or throw an exception if it's a success
* `result.unwrap<U>()` to get the value of type `U` contained in the result
* `result.unwrapOr<U>(defaultValue: U)` to get the value of type `U` contained in the result or a default value if it's a failure
* `result.unwrapOrElse<U>(defaultValue: () => U)` to get the value of type `U` contained in the result or a default value if it's a failure with lazy evaluation

Different ways to check the value of a Result:
* `result.isOk` to check if the result is successful
* `result.isErr` to check if the result is a failure
* `result.contains<U>(value: U)` to check if the result contains a specific value
* `result.containsErr<E>(error: E)` to check if the result contains a specific error
* `result.containsLazy<U>(value: () => U)` to check if the result contains a specific value with lazy evaluation
* `result.containsErrLazy<E>(error: () => E)` to check if the result contains a specific error with lazy evaluation
* `result1 == result2` to check if two results are equal
* `result1 != result2` to check if two results are not equal

Different ways to transform a Result:
* `result.map<U>(U Function(T value) transform)` to transform the value of the result
* `result.mapAsync<U>(FutureOr<U> Function(T value) transform)` to transform the value of the result asynchronously
* `result.mapErr<E>(E Function(E error) transform)` to transform the error of the result
* `result.mapErrAsync<E>(FutureOr<E> Function(E error) transform)` to transform the error of the result asynchronously
* `result.mapOrElse<U,F>(U Function(T value) transform, F Function(E error) transformErr)` to transform the value and the error of the result
* `result.mapOrElseAsync<U,F>(FutureOr<U> Function(T value) transform, FutureOr<F> Function(E error) transformErr)` to transform the value and the error of the result asynchronously
* `result.and<U>(Result<U,E> other)` to combine two results
* `result.andThen<U>(Result<U,E> Function(T value) transform)` to combine two results with a function
* `result.or<F>(Result<T,F> other)` to combine two results
* `result.orElse<F>(Result<T,F> Function(E error) transform)` to combine two results with a function
* `result1 & result2` to combine two results with the `and` operator
* `result1 | result2` to combine two results with the `or` operator
* `result.flatten()` to flatten a result of type `Result<Result<T,E>,E>` into a result of type `Result<T,E>`
* `result.flattenAsync()` to flatten a result of type `Result<FutureOr<Result<T,E>>,E>` into a result of type `Result<T,E>`
* `result.fold<U>(U Function(T value) transform, U Function(E error) transformErr)` to transform the value and the error of the result
* `result.foldAsync<U>(FutureOr<U> Function(T value) transform, FutureOr<U> Function(E error) transformErr)` to transform the value and the error of the result asynchronously

## Usage

Import the package:

```dart
import 'package:result/result.dart';
```

Create a function that can fail:

```dart
enum Version { version1, version2 }

Result<Version, ResultException> parseVersion(List<int> header) =>
  switch (header) {
    final header when header.isEmpty =>
      const Result.err(ResultException('invalid header length')),
    final header when header[0] == 1 => const Result.ok(Version.version1),
    final header when header[0] == 2 => const Result.ok(Version.version2),
    _ => const Result.err(ResultException('invalid version')),
  };
```

Use the function:

```dart
final version = parseVersion([1, 2, 3, 4]);
print(
  switch (version) {
    Ok(ok: final value) => 'working with version: $value',
    Err(err: final error) => 'error parsing header: $error',
  },
);
```

If, `version = parseVersion([1, 2, 3, 4])` , then the output will be:

```dart
working with version: Version.version1
```

if, `version = parseVersion([3, 2, 3, 4])` , then the output will be:

```dart
error parsing header: ResultException: invalid version
```

and, if `version = parseVersion([])` , then the output will be:

```dart
error parsing header: ResultException: invalid header length
```

See more examples in [example](./example/lib/main.dart) and [test](./test/result_test.dart) folders.
