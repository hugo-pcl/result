// Copyright 2023 Hugo Pointcheval
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:result/result.dart';

enum Version { version1, version2 }

class ResultExample {
  /// Rust example (https://doc.rust-lang.org/std/result/):
  /// ```rust
  /// #[derive(Debug)]
  /// enum Version { Version1, Version2 }
  ///
  /// fn parse_version(header: &[u8]) -> Result<Version, &'static str> {
  ///     match header.get(0) {
  ///         None => Err("invalid header length"),
  ///         Some(&1) => Ok(Version::Version1),
  ///         Some(&2) => Ok(Version::Version2),
  ///         Some(_) => Err("invalid version"),
  ///     }
  /// }
  ///
  /// let version = parse_version(&[1, 2, 3, 4]);
  /// match version {
  ///     Ok(v) => println!("working with version: {v:?}"),
  ///     Err(e) => println!("error parsing header: {e:?}"),
  /// }
  /// ```
  static Future<void> example1(List<String> args) async {
    Result<Version, ResultException> parseVersion(List<int> header) =>
        switch (header) {
          final header when header.isEmpty =>
            const Result.err(ResultException('invalid header length')),
          final header when header[0] == 1 => const Result.ok(Version.version1),
          final header when header[0] == 2 => const Result.ok(Version.version2),
          _ => const Result.err(ResultException('invalid version')),
        };

    final version = parseVersion([1, 2, 3, 4]);
    print(
      switch (version) {
        Ok(ok: final value) => 'working with version: $value',
        Err(err: final error) => 'error parsing header: $error',
      },
    );
  }

  /// Rust example (https://doc.rust-lang.org/std/result/):
  /// ```rust
  /// #[derive(Debug)]
  /// let good_result: Result<i32, i32> = Ok(10);
  /// let bad_result: Result<i32, i32> = Err(10);
  ///
  /// // The `is_ok` and `is_err` methods do what they say.
  /// assert!(good_result.is_ok() && !good_result.is_err());
  /// assert!(bad_result.is_err() && !bad_result.is_ok());
  ///
  /// // `map` consumes the `Result` and produces another.
  /// let good_result: Result<i32, i32> = good_result.map(|i| i + 1);
  /// let bad_result: Result<i32, i32> = bad_result.map(|i| i - 1);
  ///
  /// // Use `and_then` to continue the computation.
  /// let good_result: Result<bool, i32> = good_result.and_then(|i| Ok(i == 11));
  ///
  /// // Use `or_else` to handle the error.
  /// let bad_result: Result<i32, i32> = bad_result.or_else(|i| Ok(i + 20));
  ///
  /// // Consume the result and return the contents with `unwrap`.
  /// let final_awesome_result = good_result.unwrap();
  /// ```
  static Future<void> example2(List<String> args) async {
    const goodResult = Result.ok(10);
    const badResult = Result<int, Exception>.err(ResultException('Error'));

    // The `is_ok` and `is_err` methods do what they say.
    assert(goodResult.isOk && !goodResult.isErr, 'goodResult is not ok');
    assert(badResult.isErr && !badResult.isOk, 'badResult is not err');

    // `map` consumes the `Result` and produces another.
    final goodResult2 = goodResult.map((i) => i + 1);
    final badResult2 = badResult.map((i) => i - 1);

    // Use `and_then` to continue the computation.
    final goodResult3 = goodResult2.andThen((i) => Result.ok(i == 11));

    // Use `or_else` to handle the error.
    final badResult3 = badResult2.orElse((i) => const Result.ok(20));

    print(badResult3);

    // Consume the result and return the contents with `unwrap`.
    final finalAwesomeResult = goodResult3.unwrap<bool>();

    print(finalAwesomeResult);
  }
}
