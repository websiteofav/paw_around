import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

/// Shows a success/error snackbar and pops on [PostCreated]; always calls
/// [onSubmittingDone] so the caller can clear its local submitting flag.
class CreatePostResultListener extends StatelessWidget {
  final VoidCallback onSubmittingDone;
  final Widget child;

  const CreatePostResultListener({
    super.key,
    required this.onSubmittingDone,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is PostCreated) {
          onSubmittingDone();
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(AppStrings.postCreatedSuccessfully),
              backgroundColor: AppColors.success));
          context.pop();
        } else if (state is CommunityError) {
          onSubmittingDone();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: AppColors.error));
        }
      },
      child: child,
    );
  }
}
