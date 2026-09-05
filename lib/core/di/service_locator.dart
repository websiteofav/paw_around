import 'package:get_it/get_it.dart';
import 'package:paw_around/repositories/address_repository.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/repositories/booking_repository.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/repositories/pet_moments_repository.dart';
import 'package:paw_around/repositories/places_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/repositories/user_repository.dart';
import 'package:paw_around/services/location_service.dart';
import 'package:paw_around/services/storage_service.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<StorageService>(() => StorageService());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerLazySingleton<PlacesRepository>(() => PlacesRepository());
  sl.registerLazySingleton<CommunityRepository>(() => CommunityRepository());
  sl.registerLazySingleton<PetMomentsRepository>(() => PetMomentsRepository());

  // PetRepository depends on AuthRepository for user ID
  sl.registerLazySingleton<PetRepository>(
    () => PetRepository(authRepository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(authRepository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepository(authRepository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepository(authRepository: sl<AuthRepository>()),
  );
}
