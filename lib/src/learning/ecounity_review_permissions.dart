import 'package:core/core.dart' as core;

const int ecoUnityReviewerAccessLevel = 10;

bool ecoUnityCanReviewContent(core.User user) {
  return user.id != null &&
      !user.isGuestUser &&
      user.accesslevel > ecoUnityReviewerAccessLevel;
}
