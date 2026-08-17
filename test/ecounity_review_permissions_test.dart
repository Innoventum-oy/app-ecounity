import 'package:core/core.dart' as core;
import 'package:ecounity/src/learning/ecounity_review_permissions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allows only non-guest privileged users to review content', () {
    expect(
      ecoUnityCanReviewContent(
        core.User(id: 10, accesslevel: ecoUnityReviewerAccessLevel + 1),
      ),
      isTrue,
    );
    expect(
      ecoUnityCanReviewContent(
        core.User(id: 10, accesslevel: ecoUnityReviewerAccessLevel),
      ),
      isFalse,
    );
    expect(
      ecoUnityCanReviewContent(
        core.User(
          id: 10,
          accesslevel: ecoUnityReviewerAccessLevel + 1,
          isGuest: true,
        ),
      ),
      isFalse,
    );
  });
}
