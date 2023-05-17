// Copyright 2023 Hugo Pointcheval
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:result/src/result.dart';

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
