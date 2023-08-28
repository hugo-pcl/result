// Copyright 2023 Hugo Pointcheval
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:sealed_result/sealed_result.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  Result<int, String> resultOk = const Result<int, String>.ok(42);
  Future<Result<int, String>> asyncResultOk = Future.value(resultOk);
  Result<int, String> resultErr =
      const Result<int, String>.err('error', StackTrace.empty);
  Future<Result<int, String>> asyncResultErr = Future.value(resultErr);

  setUp(() {
    resultOk = const Result<int, String>.ok(42);
    asyncResultOk = Future.value(resultOk);
    resultErr = const Result<int, String>.err('error');
    asyncResultErr = Future.value(resultErr);
  });

  /// Tests of the Result creation methods (constructors and factories)
  group('Creation', () {
    test('.ok() returns Ok', () {
      const result = Result<int, Exception>.ok(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('.success() returns Ok', () {
      const result = Result<int, Exception>.success(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('.err() returns Err', () {
      final result = Result<int, Exception>.err(Exception('error'));
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('.error() returns Err', () {
      final result = Result<int, Exception>.error(Exception('error'));
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('.failure() returns Err', () {
      final result = Result<int, Exception>.failure(Exception('error'));
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('.from() returns Ok for complete function', () {
      final result = Result<int, Exception>.from(() => 42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('from() returns Err for throwing function', () {
      final result =
          Result<int, Exception>.from(() => throw Exception('error'));
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('.fromCondition() returns Ok for true condition', () {
      final result = Result.fromCondition(
        condition: true,
        value: 42,
        error: Exception('error'),
      );
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('.fromCondition() returns Err for false condition', () {
      final result = Result.fromCondition(
        condition: false,
        value: 42,
        error: Exception('error'),
      );
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('.fromConditionLazy() returns Ok for true condition', () {
      final result = Result.fromConditionLazy(
        condition: () => true,
        value: () => 42,
        error: () => Exception('error'),
      );
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('.fromConditionLazy() returns Err for false condition', () {
      final result = Result.fromConditionLazy(
        condition: () => false,
        value: () => 42,
        error: () => Exception('error'),
      );
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('.fromAsync() returns Ok for completed future', () async {
      final result =
          await Result.fromAsync<int, Exception>(() async => Future.value(42));
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('.fromAsync() returns Err for failed future', () async {
      final result = await Result.fromAsync<int, Exception>(
        () async => Future<int>.error(Exception('error')),
      );
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('.fromAsync() returns Ok for non-asynchronous function', () async {
      final result = await Result.fromAsync<int, Exception>(() => 42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test(
      '.fromAsync() returns Err for non-asynchronous but throwing function',
      () async {
        final result = await Result.fromAsync<int, Exception>(
          () => throw Exception('error'),
        );
        expect(result.isOk, isFalse);
        expect(result.isErr, isTrue);
      },
    );
  });

  /// Tests of the methods that allow the extraction of the Result values
  group('Extraction', () {
    test('.isOk returns true for Ok', () {
      expect(resultOk.isOk, isTrue);
    });

    test('(async) .isOk returns true for Ok', () async {
      expect(await asyncResultOk.isOk, isTrue);
    });

    test('.isOk returns false for Err', () {
      expect(resultErr.isOk, isFalse);
    });

    test('(async) .isOk returns false for Err', () async {
      expect(await asyncResultErr.isOk, isFalse);
    });

    test('.isErr returns true for Err', () {
      expect(resultErr.isErr, isTrue);
    });

    test('(async) .isErr returns true for Err', () async {
      expect(await asyncResultErr.isErr, isTrue);
    });

    test('isErr returns false for Ok', () {
      expect(resultOk.isErr, isFalse);
    });

    test('(async) isErr returns false for Ok', () async {
      expect(await asyncResultOk.isErr, isFalse);
    });

    test('.ok returns value for Ok', () {
      expect(resultOk.ok, equals(42));
    });

    test('(async) .ok returns value for Ok', () async {
      expect(await asyncResultOk.ok, equals(42));
    });

    test('.ok returns null for Err', () {
      expect(resultErr.ok, isNull);
    });

    test('(async) .ok returns null for Err', () async {
      expect(await asyncResultErr.ok, isNull);
    });

    test('.err returns error for Err', () {
      expect(resultErr.err, equals('error'));
    });

    test('(async) .err returns error for Err', () async {
      expect(await asyncResultErr.err, equals('error'));
    });

    test('.err returns null for Ok', () {
      expect(resultOk.err, isNull);
    });

    test('(async) .err returns null for Ok', () async {
      expect(await asyncResultOk.err, isNull);
    });

    test('.stackTrace returns captured stackTrace', () {
      final trace = Trace.parse(
        '#0      Foo._bar (file:///home/hpcl/code/stuff.dart:42:21)\n'
        '#1      zip.<anonymous closure>.zap (dart:async/future.dart:0:2)\n'
        '#2      zip.<anonymous closure>.zap (https://pub.dev/thing.dart:1:100)',
      );

      final result =
          Result<int, Exception>.err(const ResultException('error'), trace);
      expect(
        result.stackTrace,
        equals(trace),
      );
    });

    test('(async) .stackTrace returns captured stackTrace', () async {
      final trace = Trace.parse(
        '#0      Foo._bar (file:///home/hpcl/code/stuff.dart:42:21)\n'
        '#1      zip.<anonymous closure>.zap (dart:async/future.dart:0:2)\n'
        '#2      zip.<anonymous closure>.zap (https://pub.dev/thing.dart:1:100)',
      );

      final result = Future.value(
        Result<int, Exception>.err(
          const ResultException('error'),
          trace,
        ),
      );
      expect(
        await result.stackTrace,
        equals(trace),
      );
    });

    test('.stackTrace returns null for Ok', () {
      expect(resultOk.stackTrace, isNull);
    });

    test('(async) .stackTrace returns null for Ok', () async {
      expect(await asyncResultOk.stackTrace, isNull);
    });

    test('.expect() returns value for Ok', () {
      expect(resultOk.expect(), equals(42));
    });

    test('(async) .expect() returns value for Ok', () async {
      expect(await asyncResultOk.expect(), equals(42));
    });

    test('.expect() throws error for Err', () {
      expect(
        resultErr.expect,
        throwsA(
          isA<ResultException>().having((e) => e.message, 'message', 'error'),
        ),
      );
    });

    test('(async) .expect() throws error for Err', () async {
      expect(
        asyncResultErr.expect,
        throwsA(
          isA<ResultException>().having((e) => e.message, 'message', 'error'),
        ),
      );
    });

    test('.expect() throws error with custom message for Err', () {
      expect(
        () => resultErr.expect('custom message'),
        throwsA(
          isA<ResultException>().having(
            (e) => e.message,
            'message',
            'custom message: error',
          ),
        ),
      );
    });

    test('(async) .expect() throws error with custom message for Err', () {
      expect(
        () => asyncResultErr.expect('custom message'),
        throwsA(
          isA<ResultException>().having(
            (e) => e.message,
            'message',
            'custom message: error',
          ),
        ),
      );
    });

    test('.expectErr() returns error for Err', () {
      expect(resultErr.expectErr(), equals('error'));
    });

    test('(async) .expectErr() returns error for Err', () async {
      expect(await asyncResultErr.expectErr(), equals('error'));
    });

    test('.expectErr() throws error for Ok', () {
      expect(
        resultOk.expectErr,
        throwsA(
          isA<ResultException>().having(
            (e) => e.message,
            'message',
            '42',
          ),
        ),
      );
    });

    test('(async) .expectErr() throws error for Ok', () async {
      expect(
        asyncResultOk.expectErr,
        throwsA(
          isA<ResultException>().having(
            (e) => e.message,
            'message',
            '42',
          ),
        ),
      );
    });

    test('.expectErr() throws error with custom message for Ok', () {
      expect(
        () => resultOk.expectErr('custom message'),
        throwsA(
          isA<ResultException>().having(
            (e) => e.message,
            'message',
            'custom message: 42',
          ),
        ),
      );
    });

    test('(async) .expectErr() throws error with custom message for Ok', () {
      expect(
        () => asyncResultOk.expectErr('custom message'),
        throwsA(
          isA<ResultException>().having(
            (e) => e.message,
            'message',
            'custom message: 42',
          ),
        ),
      );
    });

    test('.unwrap() returns value for Ok', () {
      expect(resultOk.unwrap(), equals(42));
    });

    test('(async) .unwrap() returns value for Ok', () async {
      expect(await asyncResultOk.unwrap(), equals(42));
    });

    test('.unwrap() throws error for Err', () {
      expect(
        resultErr.unwrap,
        throwsA(
          isA<ResultException>().having((e) => e.message, 'message', 'error'),
        ),
      );
    });

    test('(async) .unwrap() throws error for Err', () async {
      expect(
        asyncResultErr.unwrap,
        throwsA(
          isA<ResultException>().having((e) => e.message, 'message', 'error'),
        ),
      );
    });

    test('.unwrapErr() returns error for Err', () {
      expect(resultErr.unwrapErr(), equals('error'));
    });

    test('(async) .unwrapErr() returns error for Err', () async {
      expect(await asyncResultErr.unwrapErr(), equals('error'));
    });

    test('.unwrapErr() throws error for Ok', () {
      expect(
        resultOk.unwrapErr,
        throwsA(
          isA<ResultException>().having((e) => e.message, 'message', '42'),
        ),
      );
    });

    test('(async) .unwrapErr() throws error for Ok', () async {
      expect(
        asyncResultOk.unwrapErr,
        throwsA(
          isA<ResultException>().having((e) => e.message, 'message', '42'),
        ),
      );
    });

    test('.unwrapOr() returns value for Ok', () {
      expect(resultOk.unwrapOr(0), equals(42));
    });

    test('(async) .unwrapOr() returns value for Ok', () async {
      expect(await asyncResultOk.unwrapOr(0), equals(42));
    });

    test('.unwrapOr() returns default value for Err', () {
      expect(resultErr.unwrapOr(0), equals(0));
    });

    test('(async) .unwrapOr() returns default value for Err', () async {
      expect(await asyncResultErr.unwrapOr(0), equals(0));
    });

    test('.unwrapOrElse() returns value for Ok', () {
      expect(
        resultOk.unwrapOrElse((err) => 0),
        equals(42),
      );
    });

    test('(async) .unwrapOrElse() returns value for Ok', () async {
      expect(
        await asyncResultOk.unwrapOrElse((err) => 0),
        equals(42),
      );
    });

    test('.unwrapOrElse() returns default value for Err', () {
      expect(
        resultErr.unwrapOrElse((err) => 0),
        equals(0),
      );
    });

    test('(async) .unwrapOrElse() returns default value for Err', () async {
      expect(
        await asyncResultErr.unwrapOrElse((err) => 0),
        equals(0),
      );
    });
  });

  /// Tests of the methods that allow the inspection of the Result values
  group('Inspection', () {
    test('.contains() returns true if value is equal to given value', () {
      expect(resultOk.contains(42), isTrue);
    });

    test('(async) .contains() returns true if value is equal to given value',
        () async {
      expect(await asyncResultOk.contains(42), isTrue);
    });

    test('.contains() returns false if value is not equal to given value', () {
      expect(resultOk.contains(0), isFalse);
    });

    test(
      '(async) .contains() returns false if value is not equal to given value',
      () async {
        expect(await asyncResultOk.contains(0), isFalse);
      },
    );

    test(
        '.containsLazy() returns true if value '
        'is equal to given function result', () {
      expect(resultOk.containsLazy(() => 42), isTrue);
    });

    test(
      '(async) .containsLazy() returns true if value '
      'is equal to given function result',
      () async {
        expect(await asyncResultOk.containsLazy(() => 42), isTrue);
      },
    );

    test(
      '.containsLazy() returns false if value '
      'is equal to given function result',
      () {
        expect(resultOk.containsLazy(() => 0), isFalse);
      },
    );

    test(
      '(async) .containsLazy() returns false if value '
      'is equal to given function result',
      () async {
        expect(await asyncResultOk.containsLazy(() => 0), isFalse);
      },
    );

    test(
      '.containsErr() returns true if '
      'error is equal to given error',
      () {
        expect(resultErr.containsErr('error'), isTrue);
      },
    );

    test(
      '(async) .containsErr() returns true if '
      'error is equal to given error',
      () async {
        expect(await asyncResultErr.containsErr('error'), isTrue);
      },
    );

    test(
      '.containsErr() returns false if '
      'error is not equal to given error',
      () {
        expect(resultErr.containsErr('oops'), isFalse);
      },
    );

    test(
      '(async) .containsErr() returns false if '
      'error is not equal to given error',
      () async {
        expect(await asyncResultErr.containsErr('oops'), isFalse);
      },
    );

    test(
      '.containsErrLazy() returns true if '
      'error is equal to given error',
      () {
        expect(
          resultErr.containsErrLazy(() => 'error'),
          isTrue,
        );
      },
    );

    test(
      '(async) .containsErrLazy() returns true if '
      'error is equal to given error',
      () async {
        expect(
          await asyncResultErr.containsErrLazy(() => 'error'),
          isTrue,
        );
      },
    );

    test(
      '.containsErrLazy() returns false if '
      'error is not equal to given error',
      () {
        expect(
          resultErr.containsErrLazy(() => 'oops'),
          isFalse,
        );
      },
    );

    test(
      '(async) .containsErrLazy() returns false if '
      'error is not equal to given error',
      () async {
        expect(
          await asyncResultErr.containsErrLazy(() => 'oops'),
          isFalse,
        );
      },
    );

    test('.inspect() calls given function if Ok', () {
      var called = false;
      resultOk.inspect((value) => called = true);
      expect(called, isTrue);
    });

    test('(async) .inspect() calls given function if Ok', () async {
      var called = false;
      await asyncResultOk.inspect((value) => called = true);
      expect(called, isTrue);
    });

    test('.inspect() does not call given function if Err', () {
      var called = false;
      resultErr.inspect((value) => called = true);
      expect(called, isFalse);
    });

    test('(async) .inspect() does not call given function if Err', () async {
      var called = false;
      await asyncResultErr.inspect((value) => called = true);
      expect(called, isFalse);
    });

    test('.inspectErr() does not call given function if Ok', () {
      var called = false;
      resultOk.inspectErr((err) => called = true);
      expect(called, isFalse);
    });

    test('(async) .inspectErr() does not call given function if Ok', () async {
      var called = false;
      await asyncResultOk.inspectErr((err) => called = true);
      expect(called, isFalse);
    });

    test('.inspectErr() calls given function if Err', () {
      var called = false;
      resultErr.inspectErr((err) => called = true);
      expect(called, isTrue);
    });

    test('(async) .inspectErr() calls given function if Err', () async {
      var called = false;
      await asyncResultErr.inspectErr((err) => called = true);
      expect(called, isTrue);
    });

    test('== returns true if both are Ok and values are equal', () {
      expect(
        const Result<int, String>.ok(42) == const Result<int, String>.ok(42),
        isTrue,
      );
    });

    test('== returns false if both are Ok and values are not equal', () {
      expect(
        const Result<int, String>.ok(42) == const Result<int, String>.ok(0),
        isFalse,
      );
    });

    test('== returns false if both are Err and errors are not equal', () {
      expect(
        const Result<int, String>.err('error') ==
            const Result<int, String>.err('oops'),
        isFalse,
      );
    });

    test('== returns true if both are Err and errors are equal', () {
      expect(
        const Result<int, String>.err('error') ==
            const Result<int, String>.err('error'),
        isTrue,
      );
    });

    test('== returns false if one is Ok and other is Err', () {
      expect(
        const Result<int, int>.ok(42) == const Result<int, int>.err(42),
        isFalse,
      );
    });

    test('.hashCode returns same value if both are Ok and values are equal',
        () {
      expect(
        const Result<int, String>.ok(42).hashCode,
        equals(const Result<int, String>.ok(42).hashCode),
      );
    });

    test(
      '.hashCode returns different value if '
      'both are Ok and values are not equal',
      () {
        expect(
          const Result<int, String>.ok(42).hashCode,
          isNot(equals(const Result<int, String>.ok(0).hashCode)),
        );
      },
    );

    test(
      '.hashCode returns different value if both '
      'are Err and errors are not equal',
      () {
        expect(
          const Result<int, String>.err('error').hashCode,
          isNot(equals(const Result<int, String>.err('oops').hashCode)),
        );
      },
    );

    test(
      '.hashCode returns same value if both are Err and errors are equal',
      () {
        expect(
          const Result<int, String>.err('error').hashCode,
          equals(const Result<int, String>.err('error').hashCode),
        );
      },
    );

    test('.hashCode returns different value if one is Ok and other is Err', () {
      expect(
        const Result<int, int>.ok(42).hashCode,
        isNot(equals(const Result<int, int>.err(42).hashCode)),
      );
    });

    test('identical() returns true if both are Ok and values are equal', () {
      expect(
        identical(
          const Result<int, String>.ok(42),
          const Result<int, String>.ok(42),
        ),
        isTrue,
      );
    });

    test('identical() returns false if both are Ok and values are not equal',
        () {
      expect(
        identical(
          const Result<int, String>.ok(42),
          const Result<int, String>.ok(0),
        ),
        isFalse,
      );
    });

    test('identical() returns false if both are Err and errors are not equal',
        () {
      expect(
        identical(
          const Result<int, String>.err('error'),
          const Result<int, String>.err('oops'),
        ),
        isFalse,
      );
    });

    test('identical() returns true if both are Err and errors are equal', () {
      expect(
        identical(
          const Result<int, String>.err('error'),
          const Result<int, String>.err('error'),
        ),
        isTrue,
      );
    });

    test('identical() returns false if one is Ok and other is Err', () {
      expect(
        identical(
          const Result<int, int>.ok(42),
          const Result<int, int>.err(42),
        ),
        isFalse,
      );
    });

    test('.toString() returns correct value if Ok', () {
      expect(
        const Result<int, String>.ok(42).toString(),
        equals('Ok(42)'),
      );
    });

    test('.toString() returns correct value if Ok and null', () {
      expect(
        const Result<int?, String>.ok(null).toString(),
        equals('Ok(null)'),
      );
    });

    test('.toString() returns correct value if Ok and async', () {
      expect(
        Result<Future<int>, String>.ok(Future.value(42)).toString(),
        equals('Ok(Future<int>)'),
      );
    });

    test('.toString() returns correct value if Err', () {
      expect(
        const Result<int, String>.err('error').toString(),
        equals('Err(error)'),
      );
    });
  });

  /// Tests of the methods that allow the mutation of the Result values
  group('Mutation', () {
    test('.and() returns other if both are Ok', () {
      const ok = Result<int, String>.ok(0);
      expect(
        resultOk.and(ok),
        equals(ok),
      );
    });

    test('(async) .and() returns other if both are Ok', () async {
      const ok = Result<int, String>.ok(0);
      expect(
        await asyncResultOk.and(ok),
        equals(ok),
      );
    });

    test('.and() returns Err if self is Err and other is Ok', () {
      const ok = Result<int, String>.ok(0);
      expect(
        resultErr.and(ok),
        equals(resultErr),
      );
    });

    test('(async) .and() returns Err if self is Err and other is Ok', () async {
      const ok = Result<int, String>.ok(0);
      expect(
        await asyncResultErr.and(ok),
        equals(resultErr),
      );
    });

    test('.and() returns other err if self is Ok and other is Err', () {
      const err = Result<int, String>.err('oops');
      expect(
        resultOk.and(err),
        equals(err),
      );
    });

    test('(async) .and() returns other err if self is Ok and other is Err',
        () async {
      const err = Result<int, String>.err('oops');
      expect(
        await asyncResultOk.and(err),
        equals(err),
      );
    });

    test('.and() returns Err if both are Err', () {
      const err = Result<int, String>.err('oops');
      expect(
        resultErr.and(err),
        equals(resultErr),
      );
    });

    test('(async) .and() returns Err if both are Err', () async {
      const err = Result<int, String>.err('oops');
      expect(
        await asyncResultErr.and(err),
        equals(resultErr),
      );
    });

    // Assert everything in one test because it's only a syntax sugar
    // and the logic is tested in the previous tests
    test('& operator acts like .and()', () {
      const ok = Result<int, String>.ok(0);
      const err = Result<int, String>.err('oops');

      expect(
        resultOk & ok,
        equals(ok),
      );

      expect(
        resultErr & ok,
        equals(resultErr),
      );

      expect(
        resultOk & err,
        equals(err),
      );

      expect(
        resultErr & err,
        equals(resultErr),
      );
    });

    test('.andThen() returns other if both are Ok', () {
      const ok = Result<int, String>.ok(0);
      expect(
        resultOk.andThen((_) => ok),
        equals(ok),
      );
    });

    test('(async) .andThen() returns other if both are Ok', () async {
      const ok = Result<int, String>.ok(0);
      expect(
        await asyncResultOk.andThen((_) => ok),
        equals(ok),
      );
    });

    test('.andThen() returns Err if self is Err and other is Ok', () {
      const ok = Result<int, String>.ok(0);
      expect(
        resultErr.andThen((_) => ok),
        equals(resultErr),
      );
    });

    test('(async) .andThen() returns Err if self is Err and other is Ok',
        () async {
      const ok = Result<int, String>.ok(0);
      expect(
        await asyncResultErr.andThen((_) => ok),
        equals(resultErr),
      );
    });

    test('.andThen() returns other err if self is Ok and other is Err', () {
      const err = Result<int, String>.err('oops');
      expect(
        resultOk.andThen((_) => err),
        equals(err),
      );
    });

    test('(async) .andThen() returns other err if self is Ok and other is Err',
        () async {
      const err = Result<int, String>.err('oops');
      expect(
        await asyncResultOk.andThen((_) => err),
        equals(err),
      );
    });

    test('.andThen() returns Err if both are Err', () {
      const err = Result<int, String>.err('oops');
      expect(
        resultErr.andThen((_) => err),
        equals(resultErr),
      );
    });

    test('(async) .andThen() returns Err if both are Err', () async {
      const err = Result<int, String>.err('oops');
      expect(
        await asyncResultErr.andThen((_) => err),
        equals(resultErr),
      );
    });

    test('.or() returns other if both are Err', () {
      const err = Result<int, String>.err('oops');
      expect(
        resultErr.or(err),
        equals(err),
      );
    });

    test('(async) .or() returns other if both are Err', () async {
      const err = Result<int, String>.err('oops');
      expect(
        await asyncResultErr.or(err),
        equals(err),
      );
    });

    test('.or() returns Ok if self is Ok and other is Err', () {
      const err = Result<int, String>.err('oops');
      expect(
        resultOk.or(err),
        equals(resultOk),
      );
    });

    test('(async) .or() returns Ok if self is Ok and other is Err', () async {
      const err = Result<int, String>.err('oops');
      expect(
        await asyncResultOk.or(err),
        equals(resultOk),
      );
    });

    test('.or() returns other if self is Err and other is Ok', () {
      const ok = Result<int, String>.ok(0);
      expect(
        resultErr.or(ok),
        equals(ok),
      );
    });

    test('(async) .or() returns other if self is Err and other is Ok',
        () async {
      const ok = Result<int, String>.ok(0);
      expect(
        await asyncResultErr.or(ok),
        equals(ok),
      );
    });

    test('.or() returns Ok if both are Ok', () {
      const ok = Result<int, String>.ok(0);
      expect(
        resultOk.or(ok),
        equals(resultOk),
      );
    });

    test('(async) .or() returns Ok if both are Ok', () async {
      const ok = Result<int, String>.ok(0);
      expect(
        await asyncResultOk.or(ok),
        equals(resultOk),
      );
    });

    test('| operator acts like .or()', () {
      const ok = Result<int, String>.ok(0);
      const err = Result<int, String>.err('oops');

      expect(
        resultErr | err,
        equals(err),
      );

      expect(
        resultOk | err,
        equals(resultOk),
      );

      expect(
        resultErr | ok,
        equals(ok),
      );

      expect(
        resultOk | ok,
        equals(resultOk),
      );
    });

    test('.orElse() returns other if both are Err', () {
      const err = Result<int, String>.err('oops');
      expect(
        resultErr.orElse((_) => err),
        equals(err),
      );
    });

    test('(async) .orElse() returns other if both are Err', () async {
      const err = Result<int, String>.err('oops');
      expect(
        await asyncResultErr.orElse((_) => err),
        equals(err),
      );
    });

    test('.orElse() returns Ok if self is Ok and other is Err', () {
      const err = Result<int, String>.err('oops');
      expect(
        resultOk.orElse((_) => err),
        equals(resultOk),
      );
    });

    test('(async) .orElse() returns Ok if self is Ok and other is Err',
        () async {
      const err = Result<int, String>.err('oops');
      expect(
        await asyncResultOk.orElse((_) => err),
        equals(resultOk),
      );
    });

    test('.orElse() returns other if self is Err and other is Ok', () {
      const ok = Result<int, String>.ok(0);
      expect(
        resultErr.orElse((_) => ok),
        equals(ok),
      );
    });

    test('(async) .orElse() returns other if self is Err and other is Ok',
        () async {
      const ok = Result<int, String>.ok(0);
      expect(
        await asyncResultErr.orElse((_) => ok),
        equals(ok),
      );
    });

    test('.orElse() returns Ok if both are Ok', () {
      const ok = Result<int, String>.ok(0);
      expect(
        resultOk.orElse((_) => ok),
        equals(resultOk),
      );
    });

    test('(async) .orElse() returns Ok if both are Ok', () async {
      const ok = Result<int, String>.ok(0);
      expect(
        await asyncResultOk.orElse((_) => ok),
        equals(resultOk),
      );
    });

    test('.orElse() chains stacktraces of errors', () {
      const trace1 =
          '#0      Foo1._bar (file:///home/hpcl/code/stuff.dart:42:21)\n'
          '#1      zip.<anonymous closure>.zap (dart:async/future.dart:0:2)\n'
          '#2      zip.<anonymous closure>.zap (https://pub.dev/thing.dart:1:100)';

      const trace2 =
          '#0      Foo2._bar (file:///home/hpcl/code/stuff.dart:42:21)\n'
          '#1      zip.<anonymous closure>.zap (dart:async/future.dart:0:2)\n'
          '#2      zip.<anonymous closure>.zap (https://pub.dev/thing.dart:1:100)';

      const chained = '$trace2\n$trace1';

      final result1 = Result<int, Exception>.err(
        const ResultException('error'),
        StackTrace.fromString(trace1),
      );
      final result2 = Result<int, Exception>.err(
        const ResultException('error'),
        StackTrace.fromString(trace2),
      );

      expect(
        result1.orElse((_) => result2).stackTrace.toString(),
        equals(chained),
      );
    });

    test('(async) .orElse() chains stacktraces of errors', () async {
      const trace1 =
          '#0      Foo1._bar (file:///home/hpcl/code/stuff.dart:42:21)\n'
          '#1      zip.<anonymous closure>.zap (dart:async/future.dart:0:2)\n'
          '#2      zip.<anonymous closure>.zap (https://pub.dev/thing.dart:1:100)';

      const trace2 =
          '#0      Foo2._bar (file:///home/hpcl/code/stuff.dart:42:21)\n'
          '#1      zip.<anonymous closure>.zap (dart:async/future.dart:0:2)\n'
          '#2      zip.<anonymous closure>.zap (https://pub.dev/thing.dart:1:100)';

      const chained = '$trace2\n$trace1';

      final result1 = Future.value(
        Result<int, Exception>.err(
          const ResultException('error'),
          StackTrace.fromString(trace1),
        ),
      );
      final result2 = Result<int, Exception>.err(
        const ResultException('error'),
        StackTrace.fromString(trace2),
      );

      expect(
        (await result1.orElse((_) => result2)).stackTrace.toString(),
        equals(chained),
      );
    });

    test('.map() returns mapped Ok if Ok', () {
      expect(
        resultOk.map((value) => value.toString()),
        equals(const Result<String, String>.ok('42')),
      );
    });

    test('(async) .map() returns mapped Ok if Ok', () async {
      expect(
        await asyncResultOk.map((value) => value.toString()),
        equals(const Result<String, String>.ok('42')),
      );
    });

    test('.map() returns Err if Err', () {
      expect(
        resultErr.map((value) => value.toString()),
        equals(const Result<String, String>.err('error')),
      );
    });

    test('(async) .map() returns Err if Err', () async {
      expect(
        (await asyncResultErr.map((value) => value.toString())).err,
        equals(const Result<String, String>.err('error').err),
      );
    });

    test('.mapAsync() returns mapped Ok if Ok', () async {
      expect(
        await resultOk.mapAsync((value) async => value.toString()),
        equals(const Result<String, String>.ok('42')),
      );
    });

    test('(async) .mapAsync() returns mapped Ok if Ok', () async {
      expect(
        await asyncResultOk.mapAsync((value) async => value.toString()),
        equals(const Result<String, String>.ok('42')),
      );
    });

    test('.mapAsync() returns Err if Err', () async {
      expect(
        (await resultErr.mapAsync((value) async => value.toString())).err,
        equals(const Result<String, String>.err('error').err),
      );
    });

    test('(async) .mapAsync() returns Err if Err', () async {
      expect(
        (await asyncResultErr.mapAsync((value) async => value.toString())).err,
        equals(const Result<String, String>.err('error').err),
      );
    });

    test('.mapErr() returns mapped Err if Err', () {
      expect(
        resultErr.mapErr((value) => value.length),
        equals(const Result<int, int>.err(5)),
      );
    });

    test('(async) .mapErr() returns mapped Err if Err', () async {
      expect(
        (await asyncResultErr.mapErr((value) => value.length)).err,
        equals(const Result<int, int>.err(5).err),
      );
    });

    test('.mapErr() returns Ok if Ok', () {
      expect(
        resultOk.mapErr((value) => value.length),
        equals(const Result<int, int>.ok(42)),
      );
    });

    test('(async) .mapErr() returns Ok if Ok', () async {
      expect(
        await asyncResultOk.mapErr((value) => value.length),
        equals(const Result<int, int>.ok(42)),
      );
    });

    test('.mapErrAsync() returns mapped Err if Err', () async {
      expect(
        await resultErr.mapErrAsync((value) async => value.length),
        equals(const Result<int, int>.err(5)),
      );
    });

    test('(async) .mapErrAsync() returns mapped Err if Err', () async {
      expect(
        (await asyncResultErr.mapErrAsync((value) async => value.length)).err,
        equals(const Result<int, int>.err(5).err),
      );
    });

    test('.mapErrAsync() returns Ok if Ok', () async {
      expect(
        await resultOk.mapErrAsync((value) async => value.length),
        equals(const Result<int, int>.ok(42)),
      );
    });

    test('(async) .mapErrAsync() returns Ok if Ok', () async {
      expect(
        await asyncResultOk.mapErrAsync((value) async => value.length),
        equals(const Result<int, int>.ok(42)),
      );
    });

    test('.mapOr() returns mapped value if Ok', () {
      expect(
        resultOk.mapOr('oops', (value) => value.toString()),
        equals('42'),
      );
    });

    test('(async) .mapOr() returns mapped value if Ok', () async {
      expect(
        await asyncResultOk.mapOr('oops', (value) async => value.toString()),
        equals('42'),
      );
    });

    test('.mapOr() returns default value if Err', () {
      expect(
        resultErr.mapOr('oops', (value) => value.toString()),
        equals('oops'),
      );
    });

    test('(async) .mapOr() returns default value if Err', () async {
      expect(
        await asyncResultErr.mapOr('oops', (value) async => value.toString()),
        equals('oops'),
      );
    });

    test('.mapOrAsync() returns mapped value if Ok', () async {
      expect(
        await resultOk.mapOrAsync('oops', (value) async => value.toString()),
        equals('42'),
      );
    });

    test('(async) .mapOrAsync() returns mapped value if Ok', () async {
      expect(
        await asyncResultOk.mapOrAsync(
          'oops',
          (value) async => value.toString(),
        ),
        equals('42'),
      );
    });

    test('.mapOrAsync() returns default value if Err', () async {
      expect(
        await resultErr.mapOrAsync('oops', (value) async => value.toString()),
        equals('oops'),
      );
    });

    test('(async) .mapOrAsync() returns default value if Err', () async {
      expect(
        await asyncResultErr.mapOrAsync(
          'oops',
          (value) async => value.toString(),
        ),
        equals('oops'),
      );
    });

    test('.mapOrElse() returns mapped value if Ok', () {
      expect(
        resultOk.mapOrElse(
          (_) => 'oops',
          (value) => value.toString(),
        ),
        equals('42'),
      );
    });

    test('(async) .mapOrElse() returns mapped value if Ok', () async {
      expect(
        await asyncResultOk.mapOrElse(
          (_) => 'oops',
          (value) => value.toString(),
        ),
        equals('42'),
      );
    });

    test('.mapOrElse() returns default value if Err', () {
      expect(
        resultErr.mapOrElse(
          (_) => 'oops',
          (value) => value.toString(),
        ),
        equals('oops'),
      );
    });

    test('(async) .mapOrElse() returns default value if Err', () async {
      expect(
        await asyncResultErr.mapOrElse(
          (_) => 'oops',
          (value) => value.toString(),
        ),
        equals('oops'),
      );
    });

    test('.mapOrElseAsync() returns mapped value if Ok', () async {
      expect(
        await resultOk.mapOrElseAsync(
          (_) async => 'oops',
          (value) async => value.toString(),
        ),
        equals('42'),
      );
    });

    test('(async) .mapOrElseAsync() returns mapped value if Ok', () async {
      expect(
        await asyncResultOk.mapOrElseAsync(
          (_) async => 'oops',
          (value) async => value.toString(),
        ),
        equals('42'),
      );
    });

    test('.mapOrElseAsync() returns default value if Err', () async {
      expect(
        await resultErr.mapOrElseAsync(
          (_) async => 'oops',
          (value) async => value.toString(),
        ),
        equals('oops'),
      );
    });

    test('(async) .mapOrElseAsync() returns default value if Err', () async {
      expect(
        await asyncResultErr.mapOrElseAsync(
          (_) async => 'oops',
          (value) async => value.toString(),
        ),
        equals('oops'),
      );
    });

    test('.fold() returns mapped value if Ok', () {
      expect(
        resultOk.fold(
          (value) => value.toString(),
          (error) => 'oops',
        ),
        equals('42'),
      );
    });

    test('(async) .fold() returns mapped value if Ok', () async {
      expect(
        await asyncResultOk.fold(
          (value) => value.toString(),
          (error) => 'oops',
        ),
        equals('42'),
      );
    });

    test('.fold() returns mapped value if Err', () {
      expect(
        resultErr.fold(
          (value) => value.toString(),
          (error) => 'oops',
        ),
        equals('oops'),
      );
    });

    test('(async) .fold() returns mapped value if Err', () async {
      expect(
        await asyncResultErr.fold(
          (value) => value.toString(),
          (error) => 'oops',
        ),
        equals('oops'),
      );
    });

    test('.foldAsync() returns mapped value if Ok', () async {
      expect(
        await resultOk.foldAsync(
          (value) async => value.toString(),
          (error) async => 'oops',
        ),
        equals('42'),
      );
    });

    test('(async) .foldAsync() returns mapped value if Ok', () async {
      expect(
        await asyncResultOk.foldAsync(
          (value) async => value.toString(),
          (error) async => 'oops',
        ),
        equals('42'),
      );
    });

    test('.foldAsync() returns mapped value if Err', () async {
      expect(
        await resultErr.foldAsync(
          (value) async => value.toString(),
          (error) async => 'oops',
        ),
        equals('oops'),
      );
    });

    test('(async) .foldAsync() returns mapped value if Err', () async {
      expect(
        await asyncResultErr.foldAsync(
          (value) async => value.toString(),
          (error) async => 'oops',
        ),
        equals('oops'),
      );
    });

    test('.flatten() returns Ok if Ok of Ok', () {
      const result = Result<Result<int, String>, String>.ok(
        Result<int, String>.ok(42),
      );
      expect(
        result.flatten<int>(),
        equals(const Result<int, String>.ok(42)),
      );
    });

    test('(async) .flatten() returns Ok if Ok of Ok', () async {
      final result = Future.value(
        const Result<Result<int, String>, String>.ok(
          Result<int, String>.ok(42),
        ),
      );
      expect(
        await result.flatten<int>(),
        equals(const Result<int, String>.ok(42)),
      );
    });

    test('.flatten() returns Err if Ok of Err', () {
      const result = Result<Result<int, String>, String>.ok(
        Result<int, String>.err('error'),
      );
      expect(
        result.flatten<int>(),
        equals(const Result<int, String>.err('error')),
      );
    });

    test('(async) .flatten() returns Err if Ok of Err', () async {
      final result = Future.value(
        const Result<Result<int, String>, String>.ok(
          Result<int, String>.err('error'),
        ),
      );
      expect(
        await result.flatten<int>(),
        equals(const Result<int, String>.err('error')),
      );
    });

    test('.flatten() returns Err if Err', () {
      const result = Result<Result<int, String>, String>.err('error');
      expect(
        result.flatten<int>(),
        equals(const Result<int, String>.err('error')),
      );
    });

    test('(async) .flatten() returns Err if Err', () async {
      final result = Future.value(
        const Result<Result<int, String>, String>.err('error'),
      );
      expect(
        await result.flatten<int>(),
        equals(const Result<int, String>.err('error')),
      );
    });

    test('.flatten() throws if not result of result', () {
      const result = Result<int, String>.ok(42);
      expect(
        () => result.flatten<int>(),
        throwsA(isA<ResultException>()),
      );
    });

    test('(async) .flatten() throws if not result of result', () async {
      final result = Future.value(const Result<int, String>.ok(42));
      expect(
        () => result.flatten<int>(),
        throwsA(isA<ResultException>()),
      );
    });
  });

  group('Exception', () {
    test('is thrown when ResultException is thrown', () {
      expect(
        () => throw const ResultException('error'),
        throwsA(isA<ResultException>()),
      );
    });

    test('.toString() contains no message', () {
      expect(
        const ResultException().toString(),
        equals('ResultException'),
      );
    });

    test('.toString() contains message', () {
      expect(
        const ResultException('error').toString(),
        equals('ResultException: error'),
      );
    });

    test('can be compared', () {
      expect(
        const ResultException(),
        equals(const ResultException()),
      );
    });

    test('can be compared with message', () {
      expect(
        const ResultException('error'),
        equals(const ResultException('error')),
      );
    });

    test('can be compared with different message', () {
      expect(
        const ResultException('error'),
        isNot(equals(const ResultException('other'))),
      );
    });

    test('.hashCode is same for same message', () {
      expect(
        const ResultException('error').hashCode,
        equals(const ResultException('error').hashCode),
      );
    });

    test('.hashCode is different for different message', () {
      expect(
        const ResultException('error').hashCode,
        isNot(equals(const ResultException('other').hashCode)),
      );
    });
  });
}
