import 'package:paw_around/constants/app_strings.dart';

/// Mock-only professional/sitter entry for the Book Sitters screen. No
/// backend exists for this yet — see BookSittersScreen's doc comment.
class ProfessionalModel {
  final String id;
  final String name;
  final bool isAvailable;

  const ProfessionalModel({
    required this.id,
    required this.name,
    this.isAvailable = true,
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
