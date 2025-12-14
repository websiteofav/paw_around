import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/bloc/pets/pets_event.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/repositories/vaccine_repository.dart';
import 'package:paw_around/ui/community/create_post_screen.dart';
import 'package:paw_around/ui/community/post_detail_screen.dart';
import 'package:paw_around/ui/home/dashboard.dart';
import 'package:paw_around/ui/auth/login_screen.dart';
import 'package:paw_around/ui/auth/signup_screen.dart';
import 'package:paw_around/ui/onboarding/onboarding_screen.dart';
import 'package:paw_around/ui/intro/intro_screen.dart';
import 'package:paw_around/ui/pets/add_pet_screen.dart';
import 'package:paw_around/ui/pets/add_vaccine_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    routes: [
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
          return BlocProvider(
            create: (context) => PetsBloc(
              vaccineRepository: sl<VaccineRepository>(),
              petRepository: sl<PetRepository>(),
            ),
            child: AddPetScreen(petToEdit: petToEdit),
          );
        },
      ),

      // Add Vaccine Route
      GoRoute(
        path: AppRoutes.addVaccine,
        name: AppRoutes.addVaccine,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => PetsBloc(
              vaccineRepository: sl<VaccineRepository>(),
              petRepository: sl<PetRepository>(),
            )..add(const ResetVaccineForm()),
            child: const AddVaccineScreen(),
          );
        },
      ),

      // Community - Create Post Route
      GoRoute(
        path: AppRoutes.createPost,
        name: 'createPost',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => CommunityBloc(
              repository: sl<CommunityRepository>(),
            ),
            child: const CreatePostScreen(),
          );
        },
      ),

      // Community - Post Detail Route
      GoRoute(
        path: AppRoutes.postDetail,
        name: 'postDetail',
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return BlocProvider(
            create: (context) => CommunityBloc(
              repository: sl<CommunityRepository>(),
            ),
            child: PostDetailScreen(postId: postId),
          );
        },
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
