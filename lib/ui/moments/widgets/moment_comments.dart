import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/moments/pet_moments_bloc.dart';
import 'package:paw_around/bloc/moments/pet_moments_event.dart';
import 'package:paw_around/bloc/moments/pet_moments_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/utils/date_utils.dart';

class MomentComments extends StatefulWidget {
  final PetMoment moment;

  const MomentComments({
    super.key,
    required this.moment,
  });

  @override
  State<MomentComments> createState() => _MomentCommentsState();
}

class _MomentCommentsState extends State<MomentComments> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    final currentUser = sl<AuthRepository>().currentUser;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    context.read<PetMomentsBloc>().add(
          AddComment(
            momentId: widget.moment.id,
            userId: currentUser.uid,
            userName: currentUser.displayName ?? 'Anonymous',
            text: text,
          ),
        );

    _commentController.clear();
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
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
            // Handle bar
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
            // Title
            Text(
              AppStrings.comments,
              style: AppTextStyles.semiBoldStyle600(
                fontSize: 20,
                fontColor: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // Comments list
            Flexible(
              child: BlocBuilder<PetMomentsBloc, PetMomentsState>(
                builder: (context, state) {
                  // Reload moment to get updated comments
                  if (state is PetMomentsLoaded) {
                    final updatedMoment = state.moments.firstWhere(
                      (m) => m.id == widget.moment.id,
                      orElse: () => widget.moment,
                    );
                    return _buildCommentsList(updatedMoment);
                  }
                  return _buildCommentsList(widget.moment);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Comment input
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(PetMoment moment) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    if (moment.comments.isEmpty && !isKeyboardVisible) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.noCommentsYet,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.beFirstToComment,
              style: AppTextStyles.regularStyle400(
                fontSize: 12,
                fontColor: AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: moment.comments.length,
      itemBuilder: (context, index) {
        final comment = moment.comments[index];
        return _buildCommentItem(comment);
      },
    );
  }

  Widget _buildCommentItem(PetMomentComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: AppTextStyles.semiBoldStyle600(
                        fontSize: 14,
                        fontColor: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppDateUtils.getRelativeTimeShort(comment.createdAt),
                      style: AppTextStyles.regularStyle400(
                        fontSize: 12,
                        fontColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: AppTextStyles.regularStyle400(
                    fontSize: 14,
                    fontColor: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: smoothDecoration(
        cornerRadius: 12,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: AppStrings.commentHint,
                hintStyle: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.textLight,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textPrimary,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          IconButton(
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.send,
                    color: AppColors.primary,
                  ),
            onPressed: _isSubmitting ? null : _submitComment,
          ),
        ],
      ),
    );
  }
}
