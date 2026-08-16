import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/moments/pet_moments_bloc.dart';
import 'package:paw_around/bloc/moments/pet_moments_event.dart';
import 'package:paw_around/bloc/moments/pet_moments_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/ui/home/widgets/skeleton_card.dart';
import 'package:paw_around/ui/moments/widgets/moment_card.dart';
import 'package:paw_around/ui/moments/widgets/moment_comments.dart';
import 'package:paw_around/ui/profile/widgets/profile_dialogs.dart';
import 'package:paw_around/ui/widgets/empty_state_widget.dart';

class MyMomentsTab extends StatefulWidget {
  const MyMomentsTab({super.key});

  @override
  State<MyMomentsTab> createState() => _MyMomentsTabState();
}

class _MyMomentsTabState extends State<MyMomentsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    _loadMyMoments();
  }

  void _loadMyMoments() {
    final userId = sl<AuthRepository>().currentUser?.uid;
    if (userId != null) {
      context.read<PetMomentsBloc>().add(LoadMyMoments(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<PetMomentsBloc, PetMomentsState>(
      listener: (context, state) {
        if (state is MomentDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.momentDeleted),
              backgroundColor: AppColors.success,
            ),
          );
          _loadMyMoments();
        }
      },
      child: BlocBuilder<PetMomentsBloc, PetMomentsState>(
        builder: (context, state) {
          if (state is PetMomentsLoading) {
            return const CommunitySkeleton();
          }
          if (state is PetMomentsError) {
            return _buildError(state.message);
          }
          if (state is PetMomentsLoaded) {
            if (state.moments.isEmpty) {
              return _buildEmptyState();
            }
            return _buildList(state.moments);
          }
          return const CommunitySkeleton();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadMyMoments(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: EmptyStateWidget(
              icon: Icons.pets,
              title: AppStrings.noMyMomentsYet,
              subtitle: AppStrings.noMyMomentsSubtitle,
              actionText: AppStrings.createMoment,
              onAction: () async {
                await context.push(AppRoutes.createMoment);
                if (mounted) _loadMyMoments();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadMyMoments(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: AppEdgeInsets.allLarge,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    AppSpacing.vertical16,
                    Text(
                      message,
                      style: AppTextStyles.regularStyle400(
                        fontSize: 14,
                        fontColor: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.vertical16,
                    ElevatedButton(
                      onPressed: _loadMyMoments,
                      child: const Text(AppStrings.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<PetMoment> moments) {
    final currentUser = sl<AuthRepository>().currentUser;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadMyMoments(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppConstants.space32),
        itemCount: moments.length,
        itemBuilder: (context, index) {
          final moment = moments[index];
          return MomentCard(
            moment: moment,
            onLike: currentUser != null
                ? () => context.read<PetMomentsBloc>().add(
                      LikeMoment(
                        momentId: moment.id,
                        userId: currentUser.uid,
                      ),
                    )
                : null,
            onComment: () => _showMomentComments(moment),
            onDelete: () => _confirmDeleteMoment(context, moment.id),
          );
        },
      ),
    );
  }

  void _showMomentComments(PetMoment moment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => MomentComments(moment: moment),
      ),
    );
  }

  void _confirmDeleteMoment(BuildContext context, String momentId) {
    showDeleteMomentDialog(
      context,
      onConfirm: () =>
          context.read<PetMomentsBloc>().add(DeleteMoment(momentId)),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
