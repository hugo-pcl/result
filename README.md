<p align="center">
<img width="700px" src="https://raw.githubusercontent.com/hugo-pcl/result/main/resources/result_lib.png" style="background-color: rgb(255, 255, 255)">
<h5 align="center">Result to handle errors in Dart.</h5>
</p>

<p align="center">
<img src="https://img.shields.io/badge/SDK-Dart%20%7C%20Flutter-blue" alt="SDK: Dart & Flutter" />

<a href="https://github.com/invertase/melos">
<img src="https://img.shields.io/badge/Maintained%20with-melos-f700ff.svg" alt="Maintained with Melos" />
</a>

<a href="https://pub.dev/packages/sealed_result">
<img src="https://img.shields.io/pub/v/sealed_result" alt="Maintained with Melos" />
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

Because no matter what people say, functional programming can be really cool and powerful 😏

This package is a simple implementation of the Result Monad, which is a way to handle errors in a functional way. It's a simple wrapper around a value that can be either a success or a failure. It's a way to avoid throwing exceptions and to handle errors in a more explicit way.

The used naming convention is inspired by the [Rust Result](https://doc.rust-lang.org/std/result/enum.Result.html) enum. (So you will find `Ok` and `Err` ).

## Features

> **Note** those code are pseudo-code, check tests and examples for more details and real code.

Different ways to create a Result:
* `Result.ok(value)` to create a successful result
* `Ok(value)` same as `Result.ok(value)`
* `Result.success(value)` same as `Result.ok(value)`
* `Result.err(error, [stackTrace])` to create a failed result
* `Err(error, [stackTrace])` same as `Result.err(error, [stackTrace])`
* `Result.error(error, [stackTrace])` same as `Result.err(error, [stackTrace])`
* `Result.failure(error, [stackTrace])` same as `Result.err(error, [stackTrace])`
* `Result.from(() => value)` to create a result from a function that can throw
* `Result.fromAsync(() => future)` to create a result from a future that can fail
* `Result.fromCondition({condition, value, error})` to create a result from a condition
* `Result.fromConditionLazy({condition: () => condition, value: () => value, error: () => error})` to create a result from a condition with lazy evaluation

Different ways to extract the value from a Result:
* `result.ok` to get the value if the result is successful and discard the error if it's a failure
* `result.err` to get the error if the result is a failure and discard the value if it's a success
* `result.stackTrace` to get the stack trace if the result is a failure
* `result.expect()` to get the value if the result is successful or throw an exception if it's a failure
* `result.expectErr()` to get the error if the result is a failure or throw an exception if it's a success
* `result.unwrap()` same as `result.expect()`
* `result.unwrapErr()` same as `result.expectErr()`
* `result.unwrapOr(defaultValue)` to get the value contained in the result or a default value if it's a failure
* `result.unwrapOrElse((error) => defaultValue)` to get the value contained in the result or a default value if it's a failure with lazy evaluation

Different ways to inspect the value of a Result:
* `result.isOk` to check if the result is successful
* `result.isErr` to check if the result is a failure
* `result.contains(value)` to check if the result contains a specific value
* `result.containsErr(error)` to check if the result contains a specific error
* `result.containsLazy(() => value)` to check if the result contains a specific value with lazy evaluation
* `result.containsErrLazy(() => error)` to check if the result contains a specific error with lazy evaluation
* `result.inspect((value) => void)` to inspect the value of the result
* `result.inspectErr((error) => void)` to inspect the error of the result
* `result1 == result2` to check if two results are equal
* `result1 != result2` to check if two results are not equal

Different ways to transform a Result:
* `result.map<U>(U Function(value) transform)` to transform the value of the result
* `result.mapAsync<U>(FutureOr<U> Function(value) transform)` to transform the value of the result asynchronously
* `result.mapErr<U>(U Function(error) transform)` to transform the error of the result
* `result.mapErrAsync<U>(FutureOr<U> Function(error) transform)` to transform the error of the result asynchronously
* `result.mapOr<U>(U defaultValue, U Function(value) transform)` to transform the value of the result or return a default value if it's a failure
* `result.mapOrAsync<U>(FutureOr<U> defaultValue, FutureOr<U> Function(value) transform)` to transform the value of the result or return a default value if it's a failure asynchronously
* `result.mapOrElse<U>(U Function(value) defaultFn, U Function(error) transform)` to transform the value and the error of the result
* `result.mapOrElseAsync<U>(FutureOr<U> Function(value) defaultFn, FutureOr<U> Function(error) transform)` to transform the value and the error of the result asynchronously
* `result.fold<U>(U Function(value) okFn, U Function(error) errFn)` same as `mapOrElse` with a different syntax
* `result.foldAsync<U>(FutureOr<U> Function(value) okFn, FutureOr<U> Function(error) errFn)` same as `mapOrElseAsync` with a different syntax
* `result.flatten()` to flatten a result of type `Result<Result<T,E>,E>` into a result of type `Result<T,E>`
* `result.and<U>(Result<U,E> other)` to combine two results
* `result.andThen<U>(Result<U,E> Function(value) transform)` to combine two results with a function
* `result.or<F>(Result<T,F> other)` to combine two results
* `result.orElse<F>(Result<T,F> Function(error) transform)` to combine two results with a function
* `result1 & result2` to combine two results with the `and` operator
* `result1 | result2` to combine two results with the `or` operator

## Usage

Import the package:

```dart
import 'package:sealed_result/sealed_result.dart';
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

## Notes

`Result` is a sealed class, so you can exhaustively match it with `switch` . So if you just want to get the value of the result, prefer using Dart 3 pattern matching instead of the `fold` method:

```dart
final result = Result.ok(42);
final value = switch (result) {
  Ok(ok: final value) => value,
  Err(err: final error) => 0,
};
```

---

Multiple factory constructors are available to create a `Result` :

```dart
Result.ok(42);
Ok(42);
Result.success(42);
```

are equivalent, and

```dart
Result.err('error');
Err('error');
Result.error('error');
Result.failure('error');
```

are equivalent too.

---

This project uses [Just](https://github.com/casey/just) for managing tasks, so you can run tests with:

```sh
just test
```

and generate coverage with:

```sh
just coverage
```

---
