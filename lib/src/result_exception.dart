// Copyright 2023 Hugo Pointcheval
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:meta/meta.dart';

/// {@template result_exception}
/// [ResultException] is sometimes threw by Result operations.
///
/// ```dart
/// throw const ResultException('Emergency failure!');
/// ```
/// {@endtemplate}
@immutable
class ResultException implements Exception {
  /// {@macro result_exception}
  const ResultException([this.message]);

  /// The message of the exception.
  final String? message;

  @override
  String toString() => 'ResultException${message != null ? ': $message' : ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultException &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
