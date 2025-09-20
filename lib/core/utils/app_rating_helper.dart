import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRatingHelper {
  static final _prefs = SharedPreferences.getInstance();
  static const _lastRatingPromptKey = 'last_rating_prompt';
  static const _completedActionsKey = 'rating_completed_actions';
  static final _inAppReview = InAppReview.instance;

  static const int _minActionsForRating = 5;
  static const Duration _minTimeBetweenPrompts = Duration(days: 30);

  /// Increments the action counter and shows rating prompt if conditions are met
  static Future<void> incrementActionCount() async {
    final prefs = await _prefs;
    final completedActions = prefs.getInt(_completedActionsKey) ?? 0;
    await prefs.setInt(_completedActionsKey, completedActions + 1);

    await checkAndShowRatingPrompt();
  }

  /// Checks if we should show the rating prompt and shows it if conditions are met
  static Future<void> checkAndShowRatingPrompt() async {
    final prefs = await _prefs;
    final completedActions = prefs.getInt(_completedActionsKey) ?? 0;
    final lastPromptTime = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt(_lastRatingPromptKey) ?? 0,
    );

    if (completedActions >= _minActionsForRating &&
        DateTime.now().difference(lastPromptTime) >= _minTimeBetweenPrompts) {
      await requestReview();
    }
  }

  /// Shows the app review dialog
  static Future<void> requestReview() async {
    if (await _inAppReview.isAvailable()) {
      final prefs = await _prefs;
      await prefs.setInt(
        _lastRatingPromptKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      await _inAppReview.requestReview();
    }
  }

  /// Opens the store listing
  static Future<void> openStoreListing() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.openStoreListing(
        appStoreId: 'your_app_store_id', // iOS App Store ID
        microsoftStoreId: 'your_microsoft_store_id', // Microsoft Store ID
      );
    }
  }

  /// Resets the completed actions counter
  static Future<void> resetActionCount() async {
    final prefs = await _prefs;
    await prefs.setInt(_completedActionsKey, 0);
  }
}
