import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/sitters/booking_model.dart';
import 'package:paw_around/models/sitters/professional_model.dart';
import 'package:paw_around/ui/sitter/booking_summary_screen.dart';
import 'package:paw_around/ui/sitter/widgets/payment_flow_helper.dart';

/// Runs the Booking Summary + payment step and, on success, builds the
/// BookingModel ready for BookingFormBloc — kept out of BookSittersScreen
/// to keep that screen under the 200-line limit.
class BookingSubmitHelper {
  BookingSubmitHelper._();

  /// Returns null if the user backed out of Booking Summary or the payment
  /// failed/was cancelled — PaymentFlowHelper already shows its own error
  /// in that case, so there's nothing more for the caller to report.
  static Future<BookingModel?> collectBookingAfterPayment({
    required BuildContext context,
    required AddressModel address,
    required ProfessionalModel professional,
    required PetModel pet,
    required DateTime scheduledDate,
    required String scheduledTimeSlot,
    required double hours,
    required int totalAmount,
    String? contactPhone,
  }) async {
    final payment = await context.pushNamed<PaymentFlowResult>(
      AppRoutes.bookingSummary,
      extra: BookingSummaryArgs(
        address: address,
        scheduledDate: scheduledDate,
        scheduledTimeSlot: scheduledTimeSlot,
        totalAmount: totalAmount,
        description: 'Pet sitting session with ${professional.name}',
        contactPhone: contactPhone,
      ),
    );
    if (payment == null) return null;

    return BookingModel.create(
      petId: pet.id,
      petName: pet.name,
      petBreed: pet.breed,
      petAgeLabel: pet.ageString,
      petImagePath: pet.imagePath,
      professionalId: professional.id,
      professionalName: professional.name,
      professionalRole: professional.role,
      professionalRating: professional.rating,
      professionalReviewCount: professional.reviewCount,
      professionalPhone: professional.phoneNumber,
      addressLabel: address.label,
      addressText: address.fullAddress,
      scheduledDate: scheduledDate,
      scheduledTimeSlot: scheduledTimeSlot,
      durationHours: hours,
      totalAmount: totalAmount,
      paymentId: payment.paymentId,
      razorpayOrderId: payment.razorpayOrderId,
    );
  }
}
