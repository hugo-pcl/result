// Copyright 2023 Hugo Pointcheval
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:result/result.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  group('constructor', () {
    test('ok returns Ok', () {
      const result = Result.ok(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('err returns Err', () {
      final result = Result.err(Exception('error'));
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('of returns Ok for complete function', () {
      final result = Result.of(() => 42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('of returns Err for throwing function', () {
      final result = Result.of(() => throw Exception('error'));
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('fromCondition returns Ok for true condition', () {
      final result = Result.fromCondition(
        condition: true,
        value: 42,
        error: Exception('error'),
      );
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('fromCondition returns Err for false condition', () {
      final result = Result.fromCondition(
        condition: false,
        value: 42,
        error: Exception('error'),
      );
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('fromConditionLazy returns Ok for true condition', () {
      final result = Result.fromConditionLazy(
        condition: () => true,
        value: () => 42,
        error: () => Exception('error'),
      );
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('fromConditionLazy returns Err for false condition', () {
      final result = Result.fromConditionLazy(
        condition: () => false,
        value: () => 42,
        error: () => Exception('error'),
      );
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('fromFuture returns Ok for completed future', () async {
      final result = await Result.fromFuture(() async => Future.value(42));
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('fromFuture returns Err for failed future', () async {
      final result = await Result.fromFuture(
        () async => Future<int>.error(Exception('error')),
      );
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
    });

    test('fromFuture returns Ok for non-asynchronous function', () async {
      final result = await Result.fromFuture(() => 42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test(
      'fromFuture returns Err for non-asynchronous but throwing function',
      () async {
        final result = await Result.fromFuture(() => throw Exception('error'));
        expect(result.isOk, isFalse);
        expect(result.isErr, isTrue);
      },
    );
  });

  group('getter', () {
    test('isOk returns true for Ok', () {
      const result = Result.ok(42);
      expect(result.isOk, isTrue);
    });

    test('isOk returns false for Err', () {
      final result = Result.err(Exception('error'));
      expect(result.isOk, isFalse);
    });

    test('isErr returns true for Err', () {
      final result = Result.err(Exception('error'));
      expect(result.isErr, isTrue);
    });

    test('isErr returns false for Ok', () {
      const result = Result.ok(42);
      expect(result.isErr, isFalse);
    });

    test('ok returns value for Ok', () {
      const result = Result.ok(42);
      expect(result.ok, equals(42));
    });

    test('ok returns null for Err', () {
      final result = Result.err(Exception('error'));
      expect(result.ok, isNull);
    });

    test('err returns error for Err', () {
      final result = Result.err(Exception('error'));
      expect(result.err, isA<Exception>());
    });

    test('err returns null for Ok', () {
      const result = Result.ok(42);
      expect(result.err, isNull);
    });

    test('expect returns value for Ok', () {
      const result = Result.ok(42);
      expect(result.expect('error'), equals(42));
    });

    test('expect throws error for Err', () {
      final result = Result.err(Exception('oops'));
      expect(
        result.expect,
        throwsA(
          isA<ResultException>().having(
            (e) => e.message,
            'message',
            'Exception: oops',
          ),
        ),
      );
    });

    test('expect throws error with custom message for Err', () {
      final result = Result.err(Exception('oops'));
      expect(
        () => result.expect('custom message'),
        throwsA(
          isA<ResultException>().having(
            (e) => e.message,
            'message',
            'custom message: Exception: oops',
          ),
        ),
      );
    });

    test('expectErr returns error for Err', () {
      final result = Result.err(Exception('error'));
      expect(result.expectErr('error'), isA<Exception>());
    });

    test('expectErr throws error for Ok', () {
      const result = Result.ok(42);
      expect(
        () => result.expectErr(),
        throwsA(
          isA<ResultException>().having(
            (e) => e.message,
            'message',
            '42',
          ),
        ),
      );
    });

    test('expectErr throws error with custom message for Ok', () {
      const result = Result.ok(42);
      expect(
        () => result.expectErr('custom message'),
        throwsA(
          isA<ResultException>().having(
            (e) => e.message,
            'message',
            'custom message: 42',
          ),
        ),
      );
    });
  });

  group('unwrap', () {
    test('unwrap<U> returns U value from ok', () {
      const result = Result.ok(42);
      expect(result.unwrap<int>(), equals(42));
    });

    test('unwrap<U> returns U value from err', () {
      final exception = Exception('error');
      final result = Result.err(exception);
      expect(result.unwrap<Exception>(), equals(exception));
    });

    test('unwrap<U> throws when U is not a subtype of Result', () {
      const result = Result.ok(42);
      expect(
        () => result.unwrap<String>(),
        throwsA(isA<ResultException>()),
      );
    });

    test('unwrapOr<U> returns value for Ok', () {
      const result = Result.ok(42);
      expect(result.unwrapOr<int>(defaultValue: 0), equals(42));
    });

    test('unwrapOr<U> returns default value for Err', () {
      final result = Result.err(Exception('error'));
      expect(result.unwrapOr<int>(defaultValue: 0), equals(0));
    });

    test('unwrapOr<U> returns default value of another type', () {
      const result = Result.ok(42);
      expect(
        result.unwrapOr<String>(defaultValue: 'default'),
        equals('default'),
      );
    });

    test('unwrapOrElse<U> returns value for Ok', () {
      const result = Result.ok(42);
      expect(
        result.unwrapOrElse<int>(
          defaultValue: () => 0,
        ),
        equals(42),
      );
    });

    test('unwrapOrElse<U> returns default value for Err', () {
      final result = Result.err(Exception('error'));
      expect(
        result.unwrapOrElse<int>(
          defaultValue: () => 0,
        ),
        equals(0),
      );
    });

    test('unwrapOrElse<U> returns default value of another type', () {
      const result = Result.ok(42);
      expect(
        result.unwrapOrElse<String>(
          defaultValue: () => 'default',
        ),
        equals('default'),
      );
    });
  });

  group('contains', () {
    test('contains<U> returns true if value is equal to given value', () {
      const result = Result.ok(42);
      expect(result.contains(42), isTrue);
    });

    test('contains<U> returns false if value is not equal to given value', () {
      const result = Result.ok(42);
      expect(result.contains(0), isFalse);
    });

    test('containsLazy<U> returns true if value is equal to given value', () {
      const result = Result.ok(42);
      expect(result.containsLazy(() => 42), isTrue);
    });

    test(
      'containsLazy<U> returns false if value is not equal to given value',
      () {
        const result = Result.ok(42);
        expect(result.containsLazy(() => 0), isFalse);
      },
    );

    test(
      'containsErr<U> returns true if '
      'error is equal to given error',
      () {
        final exception = Exception('error');
        final result = Result.err(exception);
        expect(result.containsErr(exception), isTrue);
      },
    );

    test(
      'containsErr<U> returns false if '
      'error is not equal to given error',
      () {
        final result = Result.err(Exception('error'));
        expect(result.containsErr(Exception('oops')), isFalse);
      },
    );

    test(
      'containsErrLazy<U> returns true if '
      'error is equal to given error',
      () {
        final exception = Exception('error');
        final result = Result.err(exception);
        expect(
          result.containsErrLazy(() => exception),
          isTrue,
        );
      },
    );

    test(
      'containsErrLazy<U> returns false if '
      'error is not equal to given error',
      () {
        final result = Result.err(Exception('error'));
        expect(
          result.containsErrLazy(() => Exception('oops')),
          isFalse,
        );
      },
    );
  });

  group('operation', () {
    test('and returns result of operation if Ok', () {
      const result = Result.ok(42);
      expect(
        result.and(const Result.ok(0)),
        equals(const Result.ok(0)),
      );
    });

    test('and returns Err if late Err', () {
      final err = Result.err(Exception('late error'));
      const result = Result.ok(42);
      expect(
        result.and(err),
        equals(err),
      );
    });

    test('and returns Err if early Err', () {
      final err = Result<int, Exception>.err(Exception('early error'));
      final result = err;
      expect(
        result.and(const Result.ok(42)),
        equals(err),
      );
    });

    test('and returns first Err if both are Err', () {
      final err1 = Result.err(Exception('error 1'));
      final err2 = Result.err(Exception('error 2'));
      expect(
        err1.and(err2),
        equals(err1),
      );
    });

    test('& operator acts like and', () {
      const result = Result.ok(42);
      expect(
        result & const Result.ok(0),
        equals(const Result.ok(0)),
      );

      final err = Result<int, Exception>.err(Exception('late error'));
      expect(
        result & err,
        equals(err),
      );

      final err2 = Result<int, Exception>.err(Exception('early error'));
      expect(
        err2 & const Result.ok(42),
        equals(err2),
      );

      final err1 = Result.err(Exception('error 1'));
      final err3 = Result.err(Exception('error 2'));
      expect(
        err1 & err3,
        equals(err1),
      );
    });

    test('andThen returns result of operation if Ok', () {
      const result = Result.ok(42);
      expect(
        result.andThen((_) => const Result.ok(0)),
        equals(const Result.ok(0)),
      );
    });

    test('andThen returns Err if late Err', () {
      final err = Result.err(Exception('late error'));
      const result = Result.ok(42);
      expect(
        result.andThen((_) => err),
        equals(err),
      );
    });

    test('andThen returns Err if early Err', () {
      final err = Result<int, Exception>.err(Exception('early error'));
      final result = err;
      expect(
        result.andThen((_) => const Result.ok(42)),
        equals(err),
      );
    });

    test('andThen returns first Err if both are Err', () {
      final err1 = Result.err(Exception('error 1'));
      final err2 = Result.err(Exception('error 2'));
      expect(
        err1.andThen((_) => err2),
        equals(err1),
      );
    });

    test('or returns Ok if late error', () {
      const ok = Result.ok(42);
      final result = Result.err(Exception('late error'));
      expect(
        result.or(ok),
        equals(ok),
      );
    });

    test('or returns Ok if early error', () {
      const ok = Result.ok(42);
      const result = ok;
      expect(
        result.or(Result.err(Exception('early error'))),
        equals(ok),
      );
    });

    test('or returns result of operation if both are Err', () {
      final err1 = Result.err(Exception('error 1'));
      final err2 = Result.err(Exception('error 2'));
      expect(
        err1.or(err2),
        equals(err2),
      );
    });

    test('or returns first Ok if both are Ok', () {
      const ok1 = Result.ok(42);
      const ok2 = Result.ok(0);
      expect(
        ok1.or(ok2),
        equals(ok1),
      );
    });

    test('| operator acts like or', () {
      const ok = Result.ok(42);
      final result = Result.err(Exception('late error'));
      expect(
        result | ok,
        equals(ok),
      );

      const ok2 = Result.ok(42);
      const result2 = ok2;
      expect(
        result2 | Result.err(Exception('early error')),
        equals(ok2),
      );

      final err1 = Result.err(Exception('error 1'));
      final err2 = Result.err(Exception('error 2'));
      expect(
        err1 | err2,
        equals(err2),
      );

      const ok1 = Result.ok(42);
      const ok3 = Result.ok(0);
      expect(
        ok1 | ok3,
        equals(ok1),
      );
    });

    test('orElse returns Ok if late error', () {
      const ok = Result.ok(42);
      final result = Result.err(Exception('late error'));
      expect(
        result.orElse((_) => ok),
        equals(ok),
      );
    });

    test('orElse returns Ok if early error', () {
      const ok = Result.ok(42);
      const result = ok;
      expect(
        result.orElse((_) => Result.err(Exception('early error'))),
        equals(ok),
      );
    });

    test('orElse returns result of operation if both are Err', () {
      final err1 = Result.err(Exception('error 1'));
      final err2 = Result.err(Exception('error 2'));
      expect(
        err1.orElse((_) => err2),
        equals(err2),
      );
    });

    test('orElse returns first Ok if both are Ok', () {
      const ok1 = Result.ok(42);
      const ok2 = Result.ok(0);
      expect(
        ok1.orElse((_) => ok2),
        equals(ok1),
      );
    });
  });

  group('map', () {
    test('map returns mapped Ok if Ok', () {
      const result = Result.ok(42);
      expect(
        result.map((value) => value.toString()),
        equals(const Result.ok('42')),
      );
    });

    test('map returns Err if Err', () {
      final result = Result<int, Exception>.err(Exception('error'));
      expect(
        result.map((value) => value.toString()).err,
        equals(result.err),
      );
    });

    test('mapAsync returns mapped Ok if Ok', () async {
      const result = Result.ok(42);
      expect(
        await result.mapAsync((value) async => value.toString()),
        equals(const Result.ok('42')),
      );
    });

    test('mapAsync returns Err if Err', () async {
      final result = Result<int, Exception>.err(Exception('error'));
      expect(
        (await result.mapAsync((value) async => value.toString())).err,
        equals(result.err),
      );
    });

    test('mapErr returns Ok if Ok', () {
      const result = Result.ok(42);
      expect(
        result.mapErr<Exception>((error) => ResultException(error.toString())),
        equals(result),
      );
    });

    test('mapErr returns mapped Err if Err', () {
      final result = Result<int, Exception>.err(Exception('error'));
      expect(
        result.mapErr<Exception>((error) => ResultException(error.toString())),
        equals(
          const Result<int, Exception>.err(
            ResultException('Exception: error'),
          ),
        ),
      );
    });

    test('mapErrAsync returns Ok if Ok', () async {
      const result = Result.ok(42);
      expect(
        await result.mapErrAsync<Exception>(
          (error) async => ResultException(error.toString()),
        ),
        equals(result),
      );
    });

    test('mapErrAsync returns mapped Err if Err', () async {
      final result = Result<int, Exception>.err(Exception('error'));
      expect(
        (await result.mapErrAsync<Exception>(
          (error) async => ResultException(error.toString()),
        ))
            .err,
        equals(
          const ResultException('Exception: error'),
        ),
      );
    });

    test('mapOrElse returns mapped Ok if Ok', () {
      const result = Result.ok(42);
      expect(
        result
            .mapOrElse(
              (value) => value.toString(),
              (error) => ResultException(error.toString()),
            )
            .ok,
        equals('42'),
      );
    });

    test('mapOrElse returns mapped Err if Err', () {
      final result = Result<int, Exception>.err(Exception('error'));
      expect(
        result
            .mapOrElse(
              (value) => value.toString(),
              (error) => ResultException(error.toString()),
            )
            .err,
        equals(
          const ResultException('Exception: error'),
        ),
      );
    });

    test('mapOrElseAsync returns mapped Ok if Ok', () async {
      const result = Result.ok(42);
      expect(
        (await result.mapOrElseAsync(
          (value) async => value.toString(),
          (error) async => ResultException(error.toString()),
        ))
            .ok,
        equals('42'),
      );
    });

    test('mapOrElseAsync returns mapped Err if Err', () async {
      final result = Result<int, Exception>.err(Exception('error'));
      expect(
        (await result.mapOrElseAsync(
          (value) async => value.toString(),
          (error) async => ResultException(error.toString()),
        ))
            .err,
        equals(
          const ResultException('Exception: error'),
        ),
      );
    });
  });

  group('flat', () {
    test('flatten returns Ok if value is Ok', () {
      const result = Result.ok(Result.ok(42));
      expect(
        result.flatten<int>(),
        equals(const Result.ok(42)),
      );
    });

    test('flatten returns Err if value is Err', () {
      final result = Result<Result<int, Exception>, Exception>.err(
        Exception('error'),
      );
      expect(
        result.flatten<int>().err,
        equals(result.err),
      );
    });

    test('flatter throws if nested type is incorrect', () {
      final result = Result<Result<String, Exception>, Exception>.ok(
        Result<String, Exception>.err(Exception('error')),
      );
      expect(
        () => result.flatten<int>(),
        throwsA(isA<ResultException>()),
      );
    });

    test('flattenAsync returns Ok if value is Ok', () async {
      final result = Result.ok(Future.value(const Result.ok(42)));
      expect(
        await result.flattenAsync<int>(),
        equals(const Result.ok(42)),
      );
    });

    test('flattenAsync returns Err if value is Err', () async {
      final result = Result<Future<Result<int, Exception>>, Exception>.err(
        Exception('error'),
      );
      expect(
        (await result.flattenAsync<int>()).err,
        equals(result.err),
      );
    });

    test('flattenAsync throws if nested type is incorrect', () async {
      final result = Result<Future<Result<String, Exception>>, Exception>.ok(
        Future.value(Result<String, Exception>.err(Exception('error'))),
      );
      expect(
        () => result.flattenAsync<int>(),
        throwsA(isA<ResultException>()),
      );
    });
  });

  group('fold', () {
    test('fold returns mapped Ok if Ok', () {
      const result = Result.ok(42);
      expect(
        result.fold(
          (value) => value.toString(),
          (error) => ResultException(error.toString()),
        ),
        equals('42'),
      );
    });

    test('fold returns mapped Err if Err', () {
      final result = Result<int, Exception>.err(Exception('error'));
      expect(
        result.fold(
          (value) => value.toString(),
          (error) => ResultException(error.toString()),
        ),
        equals(
          const ResultException('Exception: error'),
        ),
      );
    });

    test('foldAsync returns mapped Ok if Ok', () async {
      const result = Result.ok(42);
      expect(
        await result.foldAsync(
          (value) => value.toString(),
          (error) => ResultException(error.toString()),
        ),
        equals('42'),
      );
    });

    test('foldAsync returns mapped Err if Err', () async {
      final result = Result<int, Exception>.err(Exception('error'));
      expect(
        await result.foldAsync(
          (value) => value.toString(),
          (error) => ResultException(error.toString()),
        ),
        equals(
          const ResultException('Exception: error'),
        ),
      );
    });

    test('foldAsync returns mapped Ok if Ok and async', () async {
      final result = Result.ok(Future.value(42));
      expect(
        await result.foldAsync(
          (value) async => (await value).toString(),
          (error) => ResultException(error.toString()),
        ),
        equals('42'),
      );
    });

    test('foldAsync returns mapped Err if Err and async', () async {
      final result = Result<Future<int>, Exception>.err(Exception('error'));
      expect(
        await result.foldAsync(
          (value) => value.toString(),
          (error) => ResultException(error.toString()),
        ),
        equals(
          const ResultException('Exception: error'),
        ),
      );
    });
  });

  group('comparison', () {
    test('== returns true if both ok and values are equal', () {
      const result = Result.ok(42);
      expect(
        result == (const Result.ok(42)),
        isTrue,
      );
    });

    test('== returns false if both ok and values are not equal', () {
      const result = Result.ok(42);
      expect(
        result == (const Result.ok(43)),
        isFalse,
      );
    });

    test('== returns false if both err and errors are not equal', () {
      final result = Result<int, Exception>.err(Exception('error'));
      expect(
        result == (Result<int, Exception>.err(Exception('error2'))),
        isFalse,
      );
    });

    test('== returns true if both err and errors are equal', () {
      const result = Result<int, ResultException>.err(ResultException('error'));
      expect(
        result ==
            (const Result<int, ResultException>.err(ResultException('error'))),
        isTrue,
      );
    });

    test('== returns false if one is ok and the other is err', () {
      const result = Result.ok(42);
      expect(
        result == (const Result<int, Exception>.err(ResultException('error'))),
        isFalse,
      );
    });

    test('== returns false if one is err and the other is ok', () {
      const result = Result<int, Exception>.err(ResultException('error'));
      expect(
        result == (const Result.ok(42)),
        isFalse,
      );
    });

    test('hashCode returns same hashcode if both ok and values are equal', () {
      const result = Result.ok(42);
      expect(
        result.hashCode == const Result.ok(42).hashCode,
        isTrue,
      );
    });

    test(
      'hashCode returns different hashcode if both ok and values are not equal',
      () {
        const result = Result.ok(42);
        expect(
          result.hashCode == const Result.ok(43).hashCode,
          isFalse,
        );
      },
    );

    test(
      'hashCode returns different hashcode if '
      'both err and errors are not equal',
      () {
        final result = Result<int, Exception>.err(Exception('error'));
        expect(
          result.hashCode ==
              Result<int, Exception>.err(Exception('error2')).hashCode,
          isFalse,
        );
      },
    );

    test('hashCode returns same hashcode if both err and errors are equal', () {
      const result = Result<int, ResultException>.err(ResultException('error'));
      expect(
        result.hashCode ==
            const Result<int, ResultException>.err(ResultException('error'))
                .hashCode,
        isTrue,
      );
    });

    test(
      'hashCode returns different hashcode if one is ok and the other is err',
      () {
        const result = Result.ok(42);
        expect(
          result.hashCode ==
              const Result<int, Exception>.err(ResultException('error'))
                  .hashCode,
          isFalse,
        );
      },
    );

    test(
      'hashCode returns different hashcode if one is err and the other is ok',
      () {
        const result = Result<int, Exception>.err(ResultException('error'));
        expect(
          result.hashCode == const Result.ok(42).hashCode,
          isFalse,
        );
      },
    );

    test('identical returns true if both ok and values are equal', () {
      const result = Result.ok(42);
      expect(
        identical(result, const Result.ok(42)),
        isTrue,
      );
    });

    test('identical returns false if both ok and values are not equal', () {
      const result = Result.ok(42);
      expect(
        identical(result, const Result.ok(43)),
        isFalse,
      );
    });

    test('identical returns false if both err and errors are not equal', () {
      final result = Result<int, Exception>.err(Exception('error'));
      expect(
        identical(result, Result<int, Exception>.err(Exception('error2'))),
        isFalse,
      );
    });

    test('identical returns true if both err and errors are equal', () {
      const result = Result<int, ResultException>.err(ResultException('error'));
      expect(
        identical(
          result,
          const Result<int, ResultException>.err(ResultException('error')),
        ),
        isTrue,
      );
    });

    test('identical returns false if one is ok and the other is err', () {
      const result = Result.ok(42);
      expect(
        identical(
          result,
          const Result<int, Exception>.err(ResultException('error')),
        ),
        isFalse,
      );
    });

    test('identical returns false if one is err and the other is ok', () {
      const result = Result<int, Exception>.err(ResultException('error'));
      expect(
        identical(result, const Result.ok(42)),
        isFalse,
      );
    });
  });

  group('toString', () {
    test('toString returns Ok if ok', () {
      const result = Result.ok(42);
      expect(
        result.toString(),
        equals('Ok(42)'),
      );
    });

    test('toString returns Ok if ok and null', () {
      const result = Result.ok(null);
      expect(
        result.toString(),
        equals('Ok(null)'),
      );
    });

    test('toString returns Ok if ok and async', () {
      final result = Result.ok(Future.value(42));
      expect(
        result.toString(),
        equals('Ok(Future<int>)'),
      );
    });

    test('toString returns Err if err', () {
      const result = Result<int, Exception>.err(ResultException('error'));
      expect(
        result.toString(),
        equals('Err(ResultException: error)'),
      );
    });
  });

  group('stackTrace', () {
    test('stackTrace returns null if ok', () {
      const result = Result.ok(42);
      expect(
        result.stackTrace,
        isNull,
      );
    });

    test('stackTrace returns captured stackTrace', () {
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
  });
}
