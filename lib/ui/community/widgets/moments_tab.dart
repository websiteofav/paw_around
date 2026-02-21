import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/moments/pet_moments_bloc.dart';
import 'package:paw_around/bloc/moments/pet_moments_event.dart';
import 'package:paw_around/bloc/moments/pet_moments_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/ui/moments/widgets/moment_card.dart';
import 'package:paw_around/ui/moments/widgets/moment_comments.dart';
import 'package:paw_around/ui/profile/widgets/profile_dialogs.dart';
import 'package:paw_around/ui/widgets/empty_state_widget.dart';
import 'package:paw_around/ui/home/widgets/skeleton_card.dart';

class MomentsTab extends StatefulWidget {
  const MomentsTab({super.key});

  @override
  State<MomentsTab> createState() => _MomentsTabState();
}

class _MomentsTabState extends State<MomentsTab>
    with AutomaticKeepAliveClientMixin {
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      context.read<PetMomentsBloc>().add(const LoadMoments());
    }
  }

  Future<void> _refreshMoments() async {
    context.read<PetMomentsBloc>().add(const LoadMoments());
  }

  void _handleLike(PetMoment moment) {
    final currentUser = sl<AuthRepository>().currentUser;
    if (currentUser == null) return;

    context.read<PetMomentsBloc>().add(
          LikeMoment(
            momentId: moment.id,
            userId: currentUser.uid,
          ),
        );
  }

  void _handleComment(PetMoment moment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => MomentComments(
          moment: moment,
        ),
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
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<PetMomentsBloc, PetMomentsState>(
      listener: (context, state) {
        if (state is MomentCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.momentPosted),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state is MomentDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.momentDeleted),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<PetMomentsBloc>().add(const LoadMoments());
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
            return _buildMomentsList(state.moments);
          }
          return const CommunitySkeleton();
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refreshMoments,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: AppTextStyles.regularStyle400(
                        fontSize: 14,
                        fontColor: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PetMomentsBloc>().add(const LoadMoments());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(
                        AppStrings.retry,
                        style: AppTextStyles.semiBoldStyle600(
                          fontSize: 14,
                          fontColor: AppColors.white,
                        ),
                      ),
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

  Widget _buildEmptyState() {
    const title = AppStrings.noMomentsYet;
    const subtitle = AppStrings.noMomentsDescription;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refreshMoments,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: EmptyStateWidget(
              icon: Icons.pets,
              title: title,
              subtitle: subtitle,
              actionText: AppStrings.createMoment,
              onAction: () async {
                await context.push(AppRoutes.createMoment);
                if (mounted) {
                  context.read<PetMomentsBloc>().add(const LoadMoments());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentsList(List<PetMoment> moments) {
    final currentUserId = sl<AuthRepository>().currentUser?.uid;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refreshMoments,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        itemCount: moments.length,
        itemBuilder: (context, index) {
          final moment = moments[index];
          final isOwner =
              currentUserId != null && moment.userId == currentUserId;
          return MomentCard(
            moment: moment,
            onLike: () => _handleLike(moment),
            onComment: () => _handleComment(moment),
            onDelete:
                isOwner ? () => _confirmDeleteMoment(context, moment.id) : null,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
