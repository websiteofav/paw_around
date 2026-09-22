import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_location_card.dart';
import 'package:paw_around/ui/sitter/widgets/booking_summary_date_row.dart';
import 'package:paw_around/ui/sitter/widgets/payment_flow_helper.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/utils/date_utils.dart';

/// Everything BookingSummaryScreen needs to render and to pay — built once
/// in BookSittersScreen and handed over via GoRouter's `extra`.
class BookingSummaryArgs {
  final AddressModel address;
  final DateTime scheduledDate;
  final String scheduledTimeSlot;
  final int totalAmount;
  final String description;
  final String? contactPhone;

  const BookingSummaryArgs({
    required this.address,
    required this.scheduledDate,
    required this.scheduledTimeSlot,
    required this.totalAmount,
    required this.description,
    this.contactPhone,
  });
}

/// Review-and-pay step between the booking form and the actual booking —
/// shows the address and date/time the user picked, then runs the Razorpay
/// flow via PaymentFlowHelper. Pops with a PaymentFlowResult on success so
/// BookSittersScreen can create the BookingModel; pops nothing (null) on
/// cancel/failure, since PaymentFlowHelper already shows its own error.
class BookingSummaryScreen extends StatefulWidget {
  final BookingSummaryArgs args;

  const BookingSummaryScreen({super.key, required this.args});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _isProcessingPayment = false;

  Future<void> _handlePay() async {
    setState(() => _isProcessingPayment = true);
    final payment = await PaymentFlowHelper.collectPayment(
      context: context,
      totalAmount: widget.args.totalAmount,
      description: widget.args.description,
      contactPhone: widget.args.contactPhone,
    );
    if (!mounted) return;
    setState(() => _isProcessingPayment = false);
    if (payment != null) context.pop(payment);
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeLabel =
        '${AppDateUtils.fullWeekdayName(widget.args.scheduledDate)}, '
        '${AppDateUtils.formatMonthDay(widget.args.scheduledDate)} - '
        '${widget.args.scheduledTimeSlot}';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          AppStrings.petSittersTitle,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 18,
            fontColor: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppEdgeInsets.horizontalLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.vertical24,
              BookSittersLocationCard(
                address: widget.args.address,
                onEdit: () => context.pop(),
              ),
              AppSpacing.vertical24,
              const Divider(color: AppColors.grey100),
              AppSpacing.vertical24,
              BookingSummaryDateRow(
                dateTimeLabel: dateTimeLabel,
                onEdit: () => context.pop(),
              ),
              AppSpacing.vertical24,
              const Divider(color: AppColors.grey100),
              const Spacer(),
              CommonButton(
                text: _isProcessingPayment
                    ? AppStrings.processingPayment
                    : AppStrings.payAmount(widget.args.totalAmount),
                onPressed: _isProcessingPayment ? null : _handlePay,
                isLoading: _isProcessingPayment,
                customColor: AppColors.primary,
                textStyle: AppTextStyles.interBoldStyle700(
                  fontSize: 16,
                  fontColor: AppColors.grey1000,
                ),
                customTextColor: AppColors.grey1000,
              ),
              AppSpacing.vertical32,
            ],
          ),
        ),
      ),
    );
  }
}
