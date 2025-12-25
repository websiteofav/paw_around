import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/repositories/places_repository.dart';
import 'package:paw_around/bloc/bloc/places_bloc.dart';
import 'package:paw_around/ui/community/create_post_screen.dart';
import 'package:paw_around/ui/community/post_detail_screen.dart';
import 'package:paw_around/ui/home/dashboard.dart';
import 'package:paw_around/ui/auth/phone_login_screen.dart';
import 'package:paw_around/ui/auth/otp_screen.dart';
import 'package:paw_around/ui/onboarding/onboarding_screen.dart';
import 'package:paw_around/ui/intro/intro_screen.dart';
import 'package:paw_around/ui/pets/add_pet_screen.dart';
import 'package:paw_around/ui/pets/add_vaccine_screen.dart';
import 'package:paw_around/ui/pets/grooming_settings_screen.dart';
import 'package:paw_around/ui/pets/tick_flea_settings_screen.dart';
import 'package:paw_around/ui/pets/vaccines_setup_screen.dart';
import 'package:paw_around/ui/pets/pet_overview_screen.dart';
import 'package:paw_around/ui/home/action_card_detail_screen.dart';
import 'package:paw_around/ui/profile/edit_profile_screen.dart';

/// Notifies GoRouter when auth state changes
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    sl<AuthRepository>().authStateChanges.listen((_) {
      notifyListeners();
    });
  }
}

class AppRouter {
  static final _authNotifier = AuthNotifier();

  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.phoneLogin,
    debugLogDiagnostics: false,
    refreshListenable: _authNotifier,
    redirect: (context, state) {
      final authRepository = sl<AuthRepository>();
      final isLoggedIn = authRepository.isLoggedIn;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.phoneLogin || state.matchedLocation == AppRoutes.otpVerification;
      final isPublicRoute = state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.intro ||
          state.matchedLocation == AppRoutes.onboarding;

      // If user is logged in and trying to access auth routes, redirect to home
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }

      // If user is not logged in and trying to access protected routes
      if (!isLoggedIn && !isAuthRoute && !isPublicRoute) {
        return AppRoutes.phoneLogin;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // ============ PUBLIC ROUTES ============
      // Splash/Intro Route
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        builder: (context, state) => const IntroScreen(),
      ),

      // Intro Route
      GoRoute(
        path: AppRoutes.intro,
        name: AppRoutes.intro,
        builder: (context, state) => const IntroScreen(),
      ),

      // Onboarding Route
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
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
            ],
            child: child,
          );
        },
        routes: [
          // Home Route
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.home,
            builder: (context, state) => BlocProvider(
              create: (context) => HomeBloc(),
              child: const Dashboard(),
            ),
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

          // Pet Overview Route
          GoRoute(
            path: AppRoutes.petOverview,
            name: AppRoutes.petOverview,
            builder: (context, state) {
              final pet = state.extra as PetModel;
              return PetOverviewScreen(pet: pet);
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
            builder: (context, state) => const CreatePostScreen(),
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
              final pet = state.extra as PetModel;
              return GroomingSettingsScreen(pet: pet);
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
          GoRoute(
            path: AppRoutes.vaccinesSetup,
            name: AppRoutes.vaccinesSetup,
            builder: (context, state) {
              final pet = state.extra as PetModel;
              return VaccinesSetupScreen(pet: pet);
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

          // Edit Profile Route
          GoRoute(
            path: AppRoutes.editProfile,
            name: AppRoutes.editProfile,
            builder: (context, state) => const EditProfileScreen(),
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
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pushNamed(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}
