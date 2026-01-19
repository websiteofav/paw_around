import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/ui/home/widgets/post_card.dart';
import 'package:paw_around/ui/home/widgets/skeleton_card.dart';
import 'package:paw_around/ui/widgets/empty_state_widget.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
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
      ),
      body: BlocBuilder<CommunityBloc, CommunityState>(
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
            return _buildPostsList(state);
          }
          return const CommunitySkeleton();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.article_outlined,
      title: AppStrings.noMyPostsYet,
      subtitle: AppStrings.noMyPostsSubtitle,
      actionText: AppStrings.createLostFoundPost,
      onAction: () async {
        await context.push('/community/create');
        if (mounted) {
          _loadMyPosts();
        }
      },
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

  Widget _buildPostsList(MyPostsLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        _loadMyPosts();
      },
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
                  await context.push(AppRoutes.postDetail.replaceAll(':id', post.id));
                  if (mounted) {
                    _loadMyPosts();
                  }
                },
              ),
              if (post.isResolved)
                Positioned(
                  top: 16,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary,
                      borderRadius: BorderRadius.circular(16),
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
}
