// Copyright (c) 2019, the Flutter authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:dartpad_test/dartpad_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart'
    show LiveWidgetController, WidgetController;

/// A function suitable for testing by the [testWidgets] method.
typedef WidgetTestableFunction = Future<void> Function(
    WidgetController controller);

/// Creates a single test that will execute [fn] with a [LiveWidgetController].
///
/// Test authors should use the controller to inspect/manipulate the widget tree
/// similar to the way it would be done with the `tester` in a standard Flutter
/// widget test. They should also use `await expect` to check for
/// success/failure inside the functions passed as [fn].
///
/// Any errors thrown during [fn]'s execution will be treated as failed tests.
/// If nothing is thrown, the test is considered successful.
TestRunnerFunction testWidgets(
  String description,
  Widget widget,
  WidgetTestableFunction fn, {
  String successMessage = 'Test passed!',
  String defaultHintMessage =
      'Not quite right. Keep trying, and check the console for details.',
  LoggerFunction logFn = print,
}) {
  assert(description != null);
  assert(fn != null);
  assert(successMessage != null);
  assert(defaultHintMessage != null);
  assert(logFn != null);

  return () async {
    final completer = Completer<void>();

    runApp(widget);

    // This block registers a callback that guarantees the LiveWidgetController
    // created below will have an element tree that's fully built and attached.
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timestamp) async {
      completer.complete();
    });

    await completer.future;

    final controller = LiveWidgetController(WidgetsBinding.instance);

    return test(
      description,
      () => fn(controller),
      successMessage: successMessage,
      defaultHintMessage: defaultHintMessage,
      logFn: logFn,
    )();
  };
}
