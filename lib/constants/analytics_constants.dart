/// Analytics event names
class AnalyticsEvents {
  // Auth
  static const String userSignupComplete = 'user_signup_complete';
  static const String loginSuccess = 'login_success';
  static const String loginFailed = 'login_failed';
  static const String logout = 'logout';
  static const String accountDeleted = 'account_deleted';

  // Pets
  static const String petAdded = 'pet_added';
  static const String firstPetAdded = 'first_pet_added';
  static const String petEdited = 'pet_edited';

  // Care Setup
  static const String vaccineAdded = 'vaccine_added';
  static const String groomingSetup = 'grooming_setup';
  static const String tickFleaSetup = 'tick_flea_setup';

  // Action Cards
  static const String actionCardShown = 'action_card_shown';
  static const String actionCardClicked = 'action_card_clicked';
  static const String actionCardMarkDone = 'action_card_mark_done';
  static const String actionCardSnoozed = 'action_card_snoozed';

  // CTA
  static const String ctaFindNearbyClicked = 'cta_find_nearby_clicked';

  // Notifications
  static const String localNotificationScheduled = 'local_notification_scheduled';
  static const String localNotificationTapped = 'local_notification_tapped';

  // Community
  static const String postCreated = 'post_created';
  static const String postResolved = 'post_resolved';

  // Navigation
  static const String tabViewed = 'tab_viewed';
  static const String placeSearched = 'place_searched';
}

/// Analytics parameter names
class AnalyticsParams {
  static const String method = 'method';
  static const String error = 'error';
  static const String species = 'species';
  static const String hasPhoto = 'has_photo';
  static const String hasVaccines = 'has_vaccines';
  static const String vaccineType = 'vaccine_type';
  static const String petType = 'pet_type';
  static const String frequency = 'frequency';
  static const String actionType = 'action_type';
  static const String cardType = 'card_type';
  static const String postType = 'post_type';
  static const String hasImage = 'has_image';
  static const String tabName = 'tab_name';
  static const String filterType = 'filter_type';
  static const String notificationType = 'notification_type';
}
