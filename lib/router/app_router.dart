import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/moments/pet_moments_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/repositories/user_repository.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/repositories/pet_moments_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/repositories/places_repository.dart';
import 'package:paw_around/bloc/bloc/places_bloc.dart';
import 'package:paw_around/ui/community/create_post_screen.dart';
import 'package:paw_around/ui/community/post_detail_screen.dart';
import 'package:paw_around/ui/moments/create_moment_screen.dart';
import 'package:paw_around/ui/home/dashboard.dart';
import 'package:paw_around/ui/auth/phone_login_screen.dart';
import 'package:paw_around/ui/auth/otp_screen.dart';
import 'package:paw_around/ui/auth/user_profile_setup_screen.dart';
import 'package:paw_around/ui/onboarding/onboarding_screen.dart';
import 'package:paw_around/ui/pets/add_pet_screen.dart';
import 'package:paw_around/ui/pets/add_pet_details_screen.dart';
import 'package:paw_around/ui/pets/add_vaccine_screen.dart';
import 'package:paw_around/ui/pets/grooming_settings_screen.dart';
import 'package:paw_around/ui/pets/tick_flea_settings_screen.dart';
import 'package:paw_around/ui/pets/pet_overview_screen.dart';
import 'package:paw_around/ui/pets/pet_qr_screen.dart';
import 'package:paw_around/ui/home/action_card_detail_screen.dart';
import 'package:paw_around/ui/profile/profile_screen.dart';
import 'package:paw_around/ui/profile/edit_profile_screen.dart';
import 'package:paw_around/ui/profile/my_posts_screen.dart';
import 'package:paw_around/ui/profile/help_support_screen.dart';
import 'package:paw_around/services/analytics_service.dart';

/// Notifies GoRouter after auth state changes AND profile completeness is known.
/// Profile check is done asynchronously before notifying — ensuring the redirect
/// always has the correct isProfileComplete value when it runs.
class AuthNotifier extends ChangeNotifier {
  bool _isProfileComplete = true;
  bool get isProfileComplete => _isProfileComplete;

  AuthNotifier() {
    sl<AuthRepository>().authStateChanges.listen((user) async {
      if (user != null) {
        _isProfileComplete =
            await sl<UserRepository>().isProfileComplete(user.uid);
      } else {
        _isProfileComplete = true; // logged out — reset; redirect won't apply
      }
      notifyListeners();
    });
  }

  void setProfileComplete(bool value) {
    _isProfileComplete = value;
    notifyListeners();
  }
}

class AppRouter {
  static final _authNotifier = AuthNotifier();

  static late final GoRouter _router;

  /// Call this from UserProfileSetupScreen after saving profile.
  static void setProfileComplete(bool value) =>
      _authNotifier.setProfileComplete(value);

  /// Initialize the router with the correct initial location.
  /// This MUST be called before [AppRouter.router] is accessed.
  static void init({required bool hasCompletedOnboarding}) {
    _router = GoRouter(
      initialLocation:
          hasCompletedOnboarding ? AppRoutes.phoneLogin : AppRoutes.onboarding,
      debugLogDiagnostics: false,
      refreshListenable: _authNotifier,
      observers: [AnalyticsService.observer],
      redirect: (context, state) {
        final isLoggedIn = sl<AuthRepository>().isLoggedIn;
        final path = state.matchedLocation;
        final isAuthRoute =
            path == AppRoutes.phoneLogin || path == AppRoutes.otpVerification;
        final isPublicRoute =
            path == AppRoutes.intro || path == AppRoutes.onboarding;
        final isProfileSetup = path == AppRoutes.profileSetup;

        // Logged in on an auth route → route based on profile completeness
        if (isLoggedIn && isAuthRoute) {
          return _authNotifier.isProfileComplete
              ? AppRoutes.home
              : AppRoutes.profileSetup;
        }

        // Not logged in trying to access protected routes
        if (!isLoggedIn && !isAuthRoute && !isPublicRoute) {
          return AppRoutes.phoneLogin;
        }

        // Logged in but profile incomplete → redirect to setup
        if (isLoggedIn && !_authNotifier.isProfileComplete && !isProfileSetup) {
          return AppRoutes.profileSetup;
        }

        return null;
      },
      routes: [
        // ============ PUBLIC ROUTES ============

        // Onboarding Route
        GoRoute(
          path: AppRoutes.onboarding,
          name: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),

        // Profile Setup Route
        GoRoute(
          path: AppRoutes.profileSetup,
          name: AppRoutes.profileSetup,
          builder: (context, state) => const UserProfileSetupScreen(),
        ),

        // Authentication Routes - Phone Login (Primary)
        GoRoute(
          path: AppRoutes.phoneLogin,
          name: AppRoutes.phoneLogin,
          builder: (context, state) => const PhoneLoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.otpVerification,
          name: AppRoutes.otpVerification,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final phoneNumber = extra['phoneNumber'] as String? ?? '';
            final verificationId = extra['verificationId'] as String? ?? '';
            return OTPScreen(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
            );
          },
        ),

        // ============ AUTHENTICATED ROUTES (ShellRoute) ============
        ShellRoute(
          builder: (context, state, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<CommunityBloc>(
                  create: (_) => CommunityBloc(
                    repository: sl<CommunityRepository>(),
                  ),
                ),
                BlocProvider<PetListBloc>(
                  create: (_) => PetListBloc(
                    petRepository: sl<PetRepository>(),
                  ),
                ),
                BlocProvider<PlacesBloc>(
                  create: (_) => PlacesBloc(
                    placesRepository: sl<PlacesRepository>(),
                  ),
                ),
                BlocProvider<PetMomentsBloc>(
                  create: (_) => PetMomentsBloc(
                    repository: sl<PetMomentsRepository>(),
                  ),
                ),
                BlocProvider<HomeBloc>(
                  create: (_) => HomeBloc(),
                ),
              ],
              child: child,
            );
          },
          routes: [
            // Home Route
            GoRoute(
              path: AppRoutes.home,
              name: AppRoutes.home,
              builder: (context, state) => const Dashboard(),
            ),

            // Add Pet Route - Creates fresh PetFormBloc each time
            GoRoute(
              path: AppRoutes.addPet,
              name: AppRoutes.addPet,
              builder: (context, state) {
                final petToEdit = state.extra as PetModel?;
                return BlocProvider(
                  create: (_) => PetFormBloc(
                    petRepository: sl<PetRepository>(),
                  )..add(InitializeForm(petToEdit: petToEdit)),
                  child: AddPetScreen(petToEdit: petToEdit),
                );
              },
            ),

            // Add Pet Details Route (Step 2)
            GoRoute(
              path: AppRoutes.addPetDetails,
              name: AppRoutes.addPetDetails,
              builder: (context, state) {
                final pet = state.extra as PetModel;
                return AddPetDetailsScreen(pet: pet);
              },
            ),

            // Pet Overview Route
            GoRoute(
              path: AppRoutes.petOverview,
              name: AppRoutes.petOverview,
              builder: (context, state) {
                final pet = state.extra as PetModel;
                return PetOverviewScreen(pet: pet);
              },
            ),

            // Pet QR Route
            GoRoute(
              path: AppRoutes.petQr,
              name: AppRoutes.petQr,
              builder: (context, state) {
                final pet = state.extra as PetModel;
                return PetQrScreen(pet: pet);
              },
            ),

            // Add Vaccine Route - Accepts optional pet and vaccine for editing
            GoRoute(
              path: AppRoutes.addVaccine,
              name: AppRoutes.addVaccine,
              builder: (context, state) {
                final extra = state.extra;
                if (extra is Map<String, dynamic>) {
                  final pet = extra['pet'] as PetModel?;
                  final vaccine = extra['vaccine'] as VaccineModel?;
                  return AddVaccineScreen(pet: pet, vaccineToEdit: vaccine);
                }
                final pet = extra as PetModel?;
                return AddVaccineScreen(pet: pet);
              },
            ),

            // Community - Create Post Route
            GoRoute(
              path: AppRoutes.createPost,
              name: AppRoutes.createPost,
              builder: (context, state) {
                final extra = state.extra;
                final initialType = extra is PostType ? extra : null;
                return CreatePostScreen(initialType: initialType);
              },
            ),

            // Pet Moments - Create Moment Route
            GoRoute(
              path: AppRoutes.createMoment,
              name: AppRoutes.createMoment,
              builder: (context, state) => const CreateMomentScreen(),
            ),

            // Community - Post Detail Route
            GoRoute(
              path: AppRoutes.postDetail,
              name: AppRoutes.postDetail,
              builder: (context, state) {
                final postId = state.pathParameters['id']!;
                return PostDetailScreen(postId: postId);
              },
            ),

            // Pet Care Settings Routes
            GoRoute(
              path: AppRoutes.groomingSettings,
              name: AppRoutes.groomingSettings,
              builder: (context, state) {
                final extra = state.extra;
                if (extra is Map) {
                  final pet = extra['pet'] as PetModel;
                  final groomingType = extra['groomingType'] as String?;
                  return GroomingSettingsScreen(
                      pet: pet, groomingType: groomingType);
                }
                return GroomingSettingsScreen(pet: extra as PetModel);
              },
            ),
            GoRoute(
              path: AppRoutes.tickFleaSettings,
              name: AppRoutes.tickFleaSettings,
              builder: (context, state) {
                final pet = state.extra as PetModel;
                return TickFleaSettingsScreen(pet: pet);
              },
            ),

            // Action Card Detail Route
            GoRoute(
              path: AppRoutes.actionDetail,
              name: AppRoutes.actionDetail,
              builder: (context, state) {
                final data = state.extra as ActionCardData;
                return ActionCardDetailScreen(data: data);
              },
            ),

            // Profile Route
            GoRoute(
              path: AppRoutes.profileTab,
              name: AppRoutes.profileTab,
              builder: (context, state) => const ProfileScreen(),
            ),

            // Edit Profile Route
            GoRoute(
              path: AppRoutes.editProfile,
              name: AppRoutes.editProfile,
              builder: (context, state) => const EditProfileScreen(),
            ),

            // My Posts Route
            GoRoute(
              path: AppRoutes.myPosts,
              name: AppRoutes.myPosts,
              builder: (context, state) => const MyPostsScreen(),
            ),

            // Help & Support Route
            GoRoute(
              path: AppRoutes.helpSupport,
              name: AppRoutes.helpSupport,
              builder: (context, state) => const HelpSupportScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: AppColors.navigationBackground,
          foregroundColor: AppColors.navigationText,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.uri}',
                style: AppTextStyles.regularStyle400(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text(AppStrings.goToHome),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static GoRouter get router => _router;
}
