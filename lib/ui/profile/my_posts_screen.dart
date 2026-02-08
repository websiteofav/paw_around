import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
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
import 'package:paw_around/ui/home/widgets/post_card.dart';
import 'package:paw_around/ui/home/widgets/skeleton_card.dart';
import 'package:paw_around/ui/moments/widgets/moment_card.dart';
import 'package:paw_around/ui/moments/widgets/moment_comments.dart';
import 'package:paw_around/ui/profile/widgets/profile_dialogs.dart';
import 'package:paw_around/ui/widgets/empty_state_widget.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadMyPosts();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && _tabController.indexIsChanging == false) {
      _loadMyMoments();
    }
  }

  void _loadMyPosts() {
    final userId = sl<AuthRepository>().currentUser?.uid;
    if (userId != null) {
      context.read<CommunityBloc>().add(LoadMyPosts(userId));
    }
  }

  void _loadMyMoments() {
    final userId = sl<AuthRepository>().currentUser?.uid;
    if (userId != null) {
      context.read<PetMomentsBloc>().add(LoadMyMoments(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.myPosts,
          style: AppTextStyles.semiBoldStyle600(fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.semiBoldStyle600(fontSize: 14),
          unselectedLabelStyle: AppTextStyles.mediumStyle500(fontSize: 14),
          tabs: const [
            Tab(text: AppStrings.posts),
            Tab(text: AppStrings.myMoments),
          ],
        ),
      ),
      body: BlocListener<PetMomentsBloc, PetMomentsState>(
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(),
            _buildMomentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        if (state is MyPostsLoading) {
          return const CommunitySkeleton();
        }
        if (state is CommunityError) {
          return _buildPostsError(state.message);
        }
        if (state is MyPostsLoaded) {
          if (state.posts.isEmpty) {
            return _buildPostsEmptyState();
          }
          return _buildPostsList(state);
        }
        return const CommunitySkeleton();
      },
    );
  }

  Widget _buildMomentsTab() {
    return BlocBuilder<PetMomentsBloc, PetMomentsState>(
      builder: (context, state) {
        if (state is PetMomentsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state is PetMomentsError) {
          return _buildMomentsError(state.message);
        }
        if (state is PetMomentsLoaded) {
          if (state.moments.isEmpty) {
            return _buildMomentsEmptyState();
          }
          return _buildMomentsList(state.moments);
        }
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
    );
  }

  Widget _buildPostsEmptyState() {
    return EmptyStateWidget(
      icon: Icons.article_outlined,
      title: AppStrings.noMyPostsYet,
      subtitle: AppStrings.noMyPostsSubtitle,
      actionText: AppStrings.createLostFoundPost,
      onAction: () async {
        await context.push('/community/create');
        if (mounted) _loadMyPosts();
      },
    );
  }

  Widget _buildMomentsEmptyState() {
    return EmptyStateWidget(
      icon: Icons.pets,
      title: AppStrings.noMyMomentsYet,
      subtitle: AppStrings.noMyMomentsSubtitle,
      actionText: AppStrings.createMoment,
      onAction: () async {
        await context.push(AppRoutes.createMoment);
        if (mounted) _loadMyMoments();
      },
    );
  }

  Widget _buildPostsError(String message) {
    return Center(
      child: Padding(
        padding: AppEdgeInsets.allLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
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
              onPressed: _loadMyPosts,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMomentsError(String message) {
    return Center(
      child: Padding(
        padding: AppEdgeInsets.allLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
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
    );
  }

  Widget _buildPostsList(MyPostsLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadMyPosts(),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppConstants.space8,
          bottom: AppConstants.space32,
        ),
        itemCount: state.posts.length,
        itemBuilder: (context, index) {
          final post = state.posts[index];
          return Stack(
            children: [
              PostCard(
                post: post,
                isFromYourPosts: true,
                onTap: () async {
                  await context
                      .push(AppRoutes.postDetail.replaceAll(':id', post.id));
                  if (mounted) _loadMyPosts();
                },
              ),
              if (post.isResolved)
                Positioned(
                  top: 16,
                  right: 24,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary,
                      borderRadius: AppBorderRadius.md,
                    ),
                    child: Text(
                      AppStrings.resolved,
                      style: AppTextStyles.semiBoldStyle600(
                        fontSize: 12,
                        fontColor: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMomentsList(List<PetMoment> moments) {
    final currentUser = sl<AuthRepository>().currentUser;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadMyMoments(),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppConstants.space8,
          bottom: AppConstants.space32,
        ),
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
}
