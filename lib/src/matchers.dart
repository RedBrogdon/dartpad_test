import 'package:matcher/matcher.dart';

class MatchResult {
  MatchResult(this.isMatch, this.matchState);

  final bool isMatch;
  final Map<dynamic, dynamic> matchState;
}

abstract class AsyncMatcher {
  Future<MatchResult> matchAsync(dynamic item);

  Description describe(Description description);

  Description describeMismatch(item, Description mismatchDescription,
          Map matchState, bool verbose) =>
      mismatchDescription;
}

class MatcherToAsyncMatcherAdapter extends AsyncMatcher {
  final Matcher _matcher;

  MatcherToAsyncMatcherAdapter(dynamic unwrapped)
      : _matcher = wrapMatcher(unwrapped);

  Future<MatchResult> matchAsync(dynamic item) async {
    final matchState = <dynamic, dynamic>{};
    final isMatch = _matcher.matches(item, matchState);
    return MatchResult(isMatch, matchState);
  }

  @override
  Description describe(Description description) =>
      _matcher.describe(description);

  @override
  Description describeMismatch(item, Description mismatchDescription,
          Map matchState, bool verbose) =>
      _matcher.describeMismatch(item, mismatchDescription, matchState, verbose);
}

// For parity with existing API in the test package.
CompletionMatcher completion(dynamic matcher) => CompletionMatcher(matcher);

class CompletionMatcher extends AsyncMatcher {
  final Matcher _matcher;

  CompletionMatcher(dynamic unwrappedMatcher)
      : assert(unwrappedMatcher != null),
        _matcher = wrapMatcher(unwrappedMatcher);

  @override
  Future<MatchResult> matchAsync(item) async {
    final matchState = <dynamic, dynamic>{};

    if (item == null) {
      matchState['invalid_item'] = 'was null.';
      return MatchResult(false, matchState);
    } else if (item is! Future) {
      matchState['invalid_item'] = 'was not a Future.';
      return MatchResult(false, matchState);
    } else {
      try {
        // TODO(redbrogdon): Add a timeout here.
        dynamic result = await (item as Future);
        final innerMatchState = <dynamic, dynamic>{};
        final innerMatch = _matcher.matches(result, innerMatchState);
        matchState['inner_match_state'] = innerMatchState;
        matchState['inner_item'] = result;
        return MatchResult(innerMatch, matchState);
      } catch (err) {
        matchState['exception'] = err;
        return MatchResult(false, matchState);
      }
    }
  }

  @override
  Description describe(Description description) {
    if (_matcher == null) {
      description.add('a Future that completes successfully');
    } else {
      description
          .add('a Future that completes with ')
          .addDescriptionOf(_matcher);
    }
    return description;
  }

  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (matchState != null) {
      if (matchState.containsKey('invalid_item')) {
        mismatchDescription.add('${matchState['invalid_item']}');
      } else if (matchState.containsKey('exception')) {
        mismatchDescription
            .add('completed with an error: ${matchState['exception']}');
      } else if (matchState.containsKey('inner_match_state') &&
          matchState.containsKey('inner_item')) {
        mismatchDescription.add('was a Future that completed with ');
        return _matcher.describeMismatch(
            matchState['inner_item'],
            mismatchDescription,
            matchState['inner_match_state'] as Map<dynamic, dynamic>,
            verbose);
      } else {
        mismatchDescription.add('was a Future that completed incorrectly.');
      }
    }

    return mismatchDescription;
  }
}
