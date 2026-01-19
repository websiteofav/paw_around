import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paw_around/bloc/onboarding/onboarding_bloc.dart';
import 'package:paw_around/bloc/auth/auth_bloc.dart';
import 'package:paw_around/bloc/auth/auth_event.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/bloc/places_bloc.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/preferences_constants.dart';
import 'package:paw_around/core/observers/auth_bloc_observer.dart';
import 'package:paw_around/firebase_options.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/repositories/places_repository.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paw_around/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables FIRST (before Firebase)
  await dotenv.load(fileName: ".env");

  // Initialize Firebase (needs dotenv for API keys)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check for Play Integrity
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );

  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize service locator
  await init();

  // Initialize notification service
  await NotificationService().init();

  // Determine if onboarding has already been completed
  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding =
      prefs.getBool(PreferencesConstants.hasCompletedOnboarding) ?? false;

  // Configure router with correct initial route (onboarding vs auth)
  AppRouter.init(hasCompletedOnboarding: hasCompletedOnboarding);

  // Register global bloc observer for auth error handling
  Bloc.observer = AuthBlocObserver();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // App-level blocs
        BlocProvider<OnboardingBloc>(
          create: (context) => OnboardingBloc(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: sl<AuthRepository>(),
          )..add(CheckAuthStatus()),
        ),
        // Feature blocs - available to all routes
        BlocProvider<CommunityBloc>(
          create: (context) => CommunityBloc(
            repository: sl<CommunityRepository>(),
          ),
        ),
        BlocProvider<PetListBloc>(
          create: (context) => PetListBloc(
            petRepository: sl<PetRepository>(),
          ),
        ),
        BlocProvider<PlacesBloc>(
          create: (context) => PlacesBloc(
            placesRepository: sl<PlacesRepository>(),
          ),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            background: AppColors.background,
            onPrimary: AppColors.white,
            onSecondary: AppColors.textPrimary,
            onSurface: AppColors.textPrimary,
          ),
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.nunitoTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
