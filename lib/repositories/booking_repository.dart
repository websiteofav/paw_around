import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paw_around/models/sitters/booking_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';

class BookingRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  BookingRepository({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

  // Get reference to current user's bookings collection
  CollectionReference<Map<String, dynamic>> get _bookingsRef {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('bookings');
  }

  // Add a new booking, returns the new document id
  Future<String> createBooking(BookingModel booking) async {
    final docRef = await _bookingsRef.add(booking.toFirestore());
    return docRef.id;
  }

  // Live updates for a single booking, e.g. for the Upcoming Session screen
  Stream<BookingModel> bookingStream(String bookingId) {
    return _bookingsRef.doc(bookingId).snapshots().map(BookingModel.fromFirestore);
  }

  Future<void> cancelBooking(String bookingId) {
    return _bookingsRef.doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Marks a booking as reviewed so it isn't prompted for a review again
  Future<void> markReviewed(String bookingId) {
    return _bookingsRef.doc(bookingId).update({
      'hasReview': true,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
