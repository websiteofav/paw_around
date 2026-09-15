import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/sitters/review_form/review_form_bloc.dart';
import 'package:paw_around/bloc/sitters/review_form/review_form_event.dart';
import 'package:paw_around/bloc/sitters/review_form/review_form_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/booking_repository.dart';
import 'package:paw_around/repositories/review_repository.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/common_text_field.dart';

/// Bottom sheet for rating a sitter after a session — pops `true` once the
/// review is saved, so the caller can show its own confirmation.
class RateSitterBottomSheet extends StatefulWidget {
  final String professionalId;
  final String professionalName;
  final String bookingId;

  const RateSitterBottomSheet({
    super.key,
    required this.professionalId,
    required this.professionalName,
    required this.bookingId,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String professionalId,
    required String professionalName,
    required String bookingId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RateSitterBottomSheet(
        professionalId: professionalId,
        professionalName: professionalName,
        bookingId: bookingId,
      ),
    );
  }

  @override
  State<RateSitterBottomSheet> createState() => _RateSitterBottomSheetState();
}

class _RateSitterBottomSheetState extends State<RateSitterBottomSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();

  late final ReviewFormBloc _bloc = ReviewFormBloc(
    reviewRepository: sl<ReviewRepository>(),
    bookingRepository: sl<BookingRepository>(),
  );

  @override
  void dispose() {
    _commentController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onSubmit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.pleaseSelectRating),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    _bloc.add(SubmitReview(
      professionalId: widget.professionalId,
      bookingId: widget.bookingId,
      rating: _rating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<ReviewFormBloc, ReviewFormState>(
        listener: (context, state) {
          if (state is ReviewFormSuccess) {
            Navigator.of(context).pop(true);
          } else if (state is ReviewFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.failedToSubmitReview),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: smoothDecoration(
              borderRadius: AppSmoothRadius.topOnly(24),
              color: AppColors.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: smoothDecoration(
                      cornerRadius: 2,
                      color: AppColors.border,
                    ),
                  ),
                ),
                Text(
                  AppStrings.rateYourSitterTitle,
                  style: AppTextStyles.semiBoldStyle600(
                      fontSize: 20, fontColor: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.rateYourSitterSubtitlePrefix} ${widget.professionalName}',
                  style: AppTextStyles.regularStyle400(
                      fontSize: 14, fontColor: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Center(child: _buildStarSelector()),
                const SizedBox(height: 20),
                CommonTextField(
                  controller: _commentController,
                  hintText: AppStrings.addACommentOptional,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                BlocBuilder<ReviewFormBloc, ReviewFormState>(
                  builder: (context, state) {
                    return CommonButton(
                      text: AppStrings.submitReview,
                      isLoading: state is ReviewFormSubmitting,
                      customColor: AppColors.secondaryCTA,
                      onPressed: _onSubmit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () => setState(() => _rating = starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starValue <= _rating
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              size: 40,
              color: AppColors.ratingColor,
            ),
          ),
        );
      }),
    );
  }
}
