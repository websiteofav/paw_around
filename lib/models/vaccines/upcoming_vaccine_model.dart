import 'package:paw_around/models/vaccines/vaccine_model.dart';

class UpcomingVaccineModel {
  final VaccineModel vaccine;
  final String petName;
  final String petId;

  UpcomingVaccineModel({
    required this.vaccine,
    required this.petName,
    required this.petId,
  });
}
