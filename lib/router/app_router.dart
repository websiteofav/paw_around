import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/repositories/places_repository.dart';
import 'package:paw_around/bloc/bloc/places_bloc.dart';
import 'package:paw_around/ui/community/create_post_screen.dart';
import 'package:paw_around/ui/community/post_detail_screen.dart';
import 'package:paw_around/ui/home/dashboard.dart';
import 'package:paw_around/ui/auth/login_screen.dart';
import 'package:paw_around/ui/auth/signup_screen.dart';
import 'package:paw_around/ui/onboarding/onboarding_screen.dart';
import 'package:paw_around/ui/intro/intro_screen.dart';
import 'package:paw_around/ui/pets/add_pet_screen.dart';
import 'package:paw_around/ui/pets/add_vaccine_screen.dart';

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
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: false,
    refreshListenable: _authNotifier, // <-- Add this line
    redirect: (context, state) {
      final authRepository = sl<AuthRepository>();
      final isLoggedIn = authRepository.isLoggedIn;
      final isAuthRoute = state.matchedLocation == AppRoutes.login || state.matchedLocation == AppRoutes.signup;
      final isPublicRoute = state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.intro ||
          state.matchedLocation == AppRoutes.onboarding;

      // If user is logged in and trying to access auth routes, redirect to home
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }

      // If user is not logged in and trying to access protected routes
      if (!isLoggedIn && !isAuthRoute && !isPublicRoute) {
        return AppRoutes.login;
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

      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
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
              BlocProvider<PetsBloc>(
                create: (_) => PetsBloc(
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

          // Add Pet Route
          GoRoute(
            path: AppRoutes.addPet,
            name: AppRoutes.addPet,
            builder: (context, state) {
              final petToEdit = state.extra as PetModel?;
              return AddPetScreen(petToEdit: petToEdit);
            },
          ),

          // Add Vaccine Route
          GoRoute(
            path: AppRoutes.addVaccine,
            name: AppRoutes.addVaccine,
            builder: (context, state) {
              return const AddVaccineScreen();
            },
          ),

          // Community - Create Post Route
          GoRoute(
            path: AppRoutes.createPost,
            name: 'createPost',
            builder: (context, state) => const CreatePostScreen(),
          ),

          // Community - Post Detail Route
          GoRoute(
            path: AppRoutes.postDetail,
            name: 'postDetail',
            builder: (context, state) {
              final postId = state.pathParameters['id']!;
              return PostDetailScreen(postId: postId);
            },
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
