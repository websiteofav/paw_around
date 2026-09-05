/// Mock-only booking summary shown on the Upcoming Session screen after
/// tapping "Book Sitters". No booking/sitter-matching backend exists yet —
/// see BookSittersScreen's doc comment. [sitterName] is null while a sitter
/// hasn't been "matched" yet, driving the assigning-state UI.
class UpcomingSessionModel {
  final String petName;
  final String petBreed;
  final String petAgeLabel;
  final String? petImagePath;
  final String? sitterName;
  final String? sitterRole;
  final double? sitterRating;
  final int? sitterReviewCount;
  final String confirmedDateLabel;
  final String sessionDayLabel;
  final String sessionTimeLabel;
  final String? startsInLabel;
  final String locationLabel;
  final String locationAddress;
  final int totalAmount;

  const UpcomingSessionModel({
    required this.petName,
    required this.petBreed,
    required this.petAgeLabel,
    this.petImagePath,
    this.sitterName,
    this.sitterRole,
    this.sitterRating,
    this.sitterReviewCount,
    required this.confirmedDateLabel,
    required this.sessionDayLabel,
    required this.sessionTimeLabel,
    this.startsInLabel,
    required this.locationLabel,
    required this.locationAddress,
    required this.totalAmount,
  });

  bool get isSitterAssigned => sitterName != null;

  static const UpcomingSessionModel mockAssignedSession = UpcomingSessionModel(
    petName: 'Max',
    petBreed: 'Pug',
    petAgeLabel: '1y 4m',
    sitterName: 'Priya Sharma',
    sitterRole: 'Pet Care Professional',
    sitterRating: 4.8,
    sitterReviewCount: 203,
    confirmedDateLabel: 'Apr 05',
    sessionDayLabel: 'Sunday, Apr 05',
    sessionTimeLabel: '7:00 AM',
    startsInLabel: 'Starts in 2 days',
    locationLabel: 'Home',
    locationAddress: 'Indus Signature Apartment, Indiranagar',
    totalAmount: 1120,
  );

  static const UpcomingSessionModel mockPendingSession = UpcomingSessionModel(
    petName: 'Max',
    petBreed: 'Pug',
    petAgeLabel: '1y 4m',
    confirmedDateLabel: 'Apr 05',
    sessionDayLabel: 'Sunday, Apr 05',
    sessionTimeLabel: '7:00 AM',
    locationLabel: 'Home',
    locationAddress: 'Indus Signature Apartment, Indiranagar',
    totalAmount: 1120,
  );
}
