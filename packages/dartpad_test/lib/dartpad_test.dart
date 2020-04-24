// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Classes and methods for conveniently running tests against user code in
/// DartPad.
///
/// This package includes two things:
///
/// ## Test methods
///
/// A set of top-level functions that (along with a few class definitions) form
/// a testing API that works in DartPad and resembles as closely as possible the
/// basic API surface offered by `package:test`.
///
/// ## AsyncMatcher
///
/// The AsyncMatcher class offered in package:matcher is designed to be used
/// with Dart's test runner, and relies on some globals created by that package.
/// Because DartPad cannot use the test runner, it can't use that AsyncMatcher.
/// This library therefore includes its own, similar AsyncMatcher that's capable
/// of running on its own.
///
/// Only one subclass, [CompletionMatcher], currently exists, but others may be
/// added as DartPad grows.
library dartpad_test;

export 'src/test_methods.dart';
export 'src/matchers.dart';
