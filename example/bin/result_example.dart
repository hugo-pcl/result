// Copyright 2023 Hugo Pointcheval
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:result_example/main.dart';

Future<void> main(List<String> args) async {
  print('Example 1:');
  await ResultExample.example1(args);
  print('Example 2:');
  await ResultExample.example2(args);
  print('Example 3:');
  await ResultExample.example3(args);
  exit(0);
}
