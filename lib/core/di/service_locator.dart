import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/vaccine_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive CE following flow project pattern
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(VaccineModelAdapter());
  Hive.registerAdapter(PetModelAdapter());

  // Open boxes with proper typing following flow project pattern
  await Hive.openBox<VaccineModel>('vaccine_types');
  await Hive.openBox<PetModel>('pets');

  // Repositories
  sl.registerLazySingleton<VaccineRepository>(() => VaccineRepository());
  sl.registerLazySingleton<PetRepository>(() => PetRepository());

  // Initialize repositories
  await sl<VaccineRepository>().init();
  await sl<PetRepository>().init();
}
