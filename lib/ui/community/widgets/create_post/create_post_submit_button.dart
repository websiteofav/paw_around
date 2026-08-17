import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Submit CTA whose label follows [postType] and disables while a create
/// request is in flight (locally submitting or the bloc reports so).
class CreatePostSubmitButton extends StatelessWidget {
  final PostType postType;
  final bool isSubmitting;
  final VoidCallback onPressed;

  const CreatePostSubmitButton({
    super.key,
    required this.postType,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        final isLoading = isSubmitting || state is PostCreating;
        return CommonButton(
          text: postType == PostType.lost
              ? AppStrings.reportLostPetNow
              : AppStrings.reportFoundPetNow,
          onPressed: isLoading ? null : onPressed,
          isLoading: isLoading,
          customTextColor: AppColors.grey1000,
          textStyle: AppTextStyles.interBoldStyle700(
              fontSize: 16, fontColor: AppColors.grey1000),
          borderRadius: 999,
        );
      },
    );
  }
}
