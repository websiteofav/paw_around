import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/home/widgets/post_card.dart';
import 'package:paw_around/ui/home/widgets/skeleton_card.dart';
import 'package:paw_around/ui/widgets/dashboard_app_bar.dart';
import 'package:paw_around/ui/widgets/empty_state_widget.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    context.read<CommunityBloc>().add(LoadPosts());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is PostDeleted || state is PostResolved || state is PostUnresolved) {
          _loadPosts();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Custom App Bar
            DashboardAppBar(
              title: AppStrings.communityTitle,
              actions: [
                DashboardAppBarAction(
                  icon: Icons.add_circle_outline,
                  onTap: () async {
                    await context.push('/community/create');
                    if (mounted) {
                      _loadPosts();
                    }
                  },
                ),
              ],
            ),

            // Content
            Expanded(
              child: BlocBuilder<CommunityBloc, CommunityState>(
                builder: (context, state) {
                  if (state is CommunityLoading) {
                    return const CommunitySkeleton();
                  }
                  if (state is CommunityError) {
                    return _buildError(state.message);
                  }
                  if (state is CommunityLoaded) {
                    if (state.posts.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildPostsList(state);
                  }
                  return const CommunitySkeleton();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.pets,
      title: AppStrings.noPostsYet,
      subtitle: AppStrings.beTheFirstToPost,
      actionText: AppStrings.createPost,
      onAction: () async {
        await context.push('/community/create');
        if (mounted) {
          _loadPosts();
        }
      },
      hints: const [
        EmptyStateHint(
          icon: Icons.location_on_outlined,
          text: AppStrings.helpReunitePets,
        ),
        EmptyStateHint(
          icon: Icons.people_outline,
          text: AppStrings.alertNearbyParents,
        ),
      ],
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
              onPressed: _loadPosts,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(CommunityLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        _loadPosts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppConstants.space8,
          bottom: AppConstants.navigationHeight,
        ),
        itemCount: state.posts.length,
        itemBuilder: (context, index) {
          final post = state.posts[index];
          return PostCard(
            post: post,
            onTap: () async {
              await context.push('/community/${post.id}');
              if (mounted) {
                _loadPosts();
              }
            },
          );
        },
      ),
    );
  }
}
