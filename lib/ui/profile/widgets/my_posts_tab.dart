import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/ui/community/widgets/community_empty_state.dart';
import 'package:paw_around/ui/home/widgets/post_card.dart';
import 'package:paw_around/ui/home/widgets/skeleton_card.dart';

class MyPostsTab extends StatefulWidget {
  const MyPostsTab({super.key});

  @override
  State<MyPostsTab> createState() => _MyPostsTabState();
}

class _MyPostsTabState extends State<MyPostsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    _loadMyPosts();
  }

  void _loadMyPosts() {
    final userId = sl<AuthRepository>().currentUser?.uid;
    if (userId != null) {
      context.read<CommunityBloc>().add(LoadMyPosts(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        if (state is MyPostsLoading) {
          return const CommunitySkeleton();
        }
        if (state is CommunityError) {
          return _buildError(state.message);
        }
        if (state is MyPostsLoaded) {
          if (state.posts.isEmpty) {
            return _buildEmptyState();
          }
          return _buildList(state);
        }
        return const CommunitySkeleton();
      },
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadMyPosts(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: CommunityEmptyState(
          title: AppStrings.noMyPostsYet,
          checklistItems: const [
            AppStrings.noMyPostsSubtitle,
            AppStrings.stayAlertInYourArea,
          ],
          ctaText: AppStrings.createLostFoundPost,
          onCta: () async {
            await context.push(AppRoutes.createPost);
            if (mounted) _loadMyPosts();
          },
          tipText: AppStrings.lostPetsAreOftenFoundWithinTheFirst2448Hours,
        ),
      ),
    );
  }

  Widget _buildError(String message) {
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

  Widget _buildList(MyPostsLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadMyPosts(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: AppConstants.space32),
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
                    decoration: smoothDecoration(
                      cornerRadius: 16,
                      color: AppColors.textSecondary,
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

  @override
  bool get wantKeepAlive => true;
}
