import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/moments/pet_moments_bloc.dart';
import 'package:paw_around/bloc/moments/pet_moments_event.dart';
import 'package:paw_around/bloc/moments/pet_moments_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/ui/moments/widgets/create_moment/create_moment_submit_service.dart';
import 'package:paw_around/ui/moments/widgets/create_moment/moment_draft.dart';
import 'package:paw_around/ui/moments/widgets/create_moment/moment_preview_card.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Final review before posting: renders [draft] as it will appear in the
/// feed, then uploads + submits it on "Post Moment".
class MomentPreviewScreen extends StatefulWidget {
  final MomentDraft draft;

  const MomentPreviewScreen({super.key, required this.draft});

  @override
  State<MomentPreviewScreen> createState() => _MomentPreviewScreenState();
}

class _MomentPreviewScreenState extends State<MomentPreviewScreen> {
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final moment = await CreateMomentSubmitService.buildMoment(widget.draft);

    if (moment == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.failedToUploadImage),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isSubmitting = false);
      }
      return;
    }
    if (mounted) context.read<PetMomentsBloc>().add(CreateMoment(moment));
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        sl<AuthRepository>().currentUser?.displayName ?? AppStrings.petParent;

    return BlocListener<PetMomentsBloc, PetMomentsState>(
      listener: (context, state) {
        if (state is MomentCreated) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.momentPosted)),
          );
          context.pop(true);
        } else if (state is PetMomentsError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text(AppStrings.preview,
              style: AppTextStyles.semiBoldStyle600(fontSize: 17)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MomentPreviewCard(draft: widget.draft, userName: userName),
              const SizedBox(height: 32),
              CommonButton(
                text: AppStrings.postMoment,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
