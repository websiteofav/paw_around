class AppRoutes {
  // Main Routes
  static const String splash = '/';
  static const String intro = '/intro';
  static const String onboarding = '/onboarding';
  static const String phoneLogin = '/phone-login';
  static const String otpVerification = '/otp-verification';
  static const String login = '/login';
  static const String home = '/home';

  // Home Tab Routes
  static const String homeTab = '/home';
  static const String mapTab = '/home/map';
  static const String communityTab = '/home/community';
  static const String profileTab = '/home/profile';

  // Pet Management Routes
  static const String addPet = '/add-pet';
  static const String addVaccine = '/add-vaccine';
  static const String groomingSettings = '/pets/grooming-settings';
  static const String tickFleaSettings = '/pets/tick-flea-settings';

  // Profile Sub-routes
  static const String editPet = '/home/profile/edit-pet';
  static const String premium = '/home/profile/premium';

  // Map Sub-routes
  static const String vetDetails = '/home/map/vet';
  static const String groomerDetails = '/home/map/groomer';
  static const String petStoreDetails = '/home/map/pet-store';

  // Community Sub-routes
  static const String lostPetDetails = '/home/community/lost-pet';
  static const String foundPetDetails = '/home/community/found-pet';
  static const String createAlert = '/home/community/create-alert';
  static const String createPost = '/community/create';
  static const String postDetail = '/community/:id';

  // Deep Link Routes
  static const String vetLocation = '/vet/:vetId';
  static const String lostPetAlert = '/lost-pet/:alertId';
  static const String foundPetPost = '/found-pet/:postId';

  // Private constructor to prevent instantiation
  AppRoutes._();
}
