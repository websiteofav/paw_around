import 'package:get_it/get_it.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/repositories/places_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';
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

  // PetRepository depends on AuthRepository for user ID
  sl.registerLazySingleton<PetRepository>(
    () => PetRepository(authRepository: sl<AuthRepository>()),
  );
}
