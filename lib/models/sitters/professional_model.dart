import 'package:paw_around/constants/app_strings.dart';

/// Mock-only professional/sitter entry for the Book Sitters screen. No
/// professionals backend/marketplace exists yet — see BookSittersScreen's
/// doc comment. `role`/`rating`/`reviewCount` are snapshotted onto a
/// BookingModel when a booking is created, so they need real-looking
/// values even though the roster itself stays hardcoded.
class ProfessionalModel {
  final String id;
  final String name;
  final bool isAvailable;
  final String role;
  final double rating;
  final int reviewCount;

  const ProfessionalModel({
    required this.id,
    required this.name,
    this.isAvailable = true,
    this.role = 'Pet Care Professional',
    this.rating = 4.8,
    this.reviewCount = 203,
  });

  static const List<ProfessionalModel> mockProfessionals = [
    ProfessionalModel(id: 'best-available', name: "Malikka"),
    ProfessionalModel(
      id: 'stella',
      name: 'Stella',
      isAvailable: false,
    ),
  ];
}
