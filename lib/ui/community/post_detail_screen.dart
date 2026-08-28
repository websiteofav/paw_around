import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/ui/community/widgets/post_detail/delete_post_dialog.dart';
import 'package:paw_around/ui/community/widgets/post_detail/post_detail_back_button.dart';
import 'package:paw_around/ui/community/widgets/post_detail/post_detail_bottom_bar.dart';
import 'package:paw_around/ui/community/widgets/post_detail/post_detail_details_card.dart';
import 'package:paw_around/ui/community/widgets/post_detail/post_detail_hero_section.dart';
import 'package:paw_around/ui/community/widgets/post_detail/post_detail_identity_card.dart';
import 'package:paw_around/ui/community/widgets/post_detail/post_detail_location_section.dart';
import 'package:paw_around/ui/community/widgets/post_detail/post_detail_owner_actions.dart';
import 'package:paw_around/utils/share_utils.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  LostFoundPost? _post;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    final repository = sl<CommunityRepository>();
    final post = await repository.getPostById(widget.postId);
    setState(() {
      _post = post;
      _isLoading = false;
    });
  }

  bool get _isOwner {
    final currentUserId = sl<AuthRepository>().currentUser?.uid;
    return currentUserId != null && currentUserId == _post?.userId;
  }

  void _markAsResolved() {
    context
        .read<CommunityBloc>()
        .add(MarkPostResolved(widget.postId, petId: _post?.petId));
  }

  void _unresolvePost() {
    context.read<CommunityBloc>().add(UnresolvePost(
          widget.postId,
          petId: _post?.petId,
          lastSeenAt: _post?.lastSeenAt,
          lastSeenLocation: _post?.locationName,
        ));
  }

  void _confirmDelete() {
    DeletePostDialog.show(
      context: context,
      onConfirm: () =>
          context.read<CommunityBloc>().add(DeletePost(widget.postId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is PostDeleted) {
          Navigator.of(context, rootNavigator: true).pop();
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.postDeletedSuccessfully)),
          );
          context.go(AppRoutes.home);
        } else if (state is PostResolved) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(AppStrings.postMarkedAsResolved),
                backgroundColor: AppColors.success),
          );
          context.pop();
        } else if (state is PostUnresolved) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(AppStrings.postReopenedSuccessfully),
                backgroundColor: AppColors.success),
          );
          context.pop();
        } else if (state is CommunityError) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _post == null
                ? const Center(child: Text(AppStrings.postNotFound))
                : _buildBody(),
        bottomNavigationBar: _post != null && !_isOwner
            ? PostDetailBottomBar(post: _post!)
            : null,
      ),
    );
  }

  Widget _buildBody() {
    final post = _post!;
    final topPad = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PostDetailHeroSection(
                  post: post, heroTag: 'post-image-${widget.postId}'),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.petDescription.isNotEmpty) ...[
                      Text(post.petDescription,
                          style: AppTextStyles.interRegularStyle400(
                              fontSize: 15, fontColor: AppColors.grey800)),
                      const SizedBox(height: 20),
                    ],
                    PostDetailDetailsCard(post: post, isOwner: _isOwner),
                    const SizedBox(height: 20),
                    PostDetailLocationSection(post: post),
                    const SizedBox(height: 24),
                    if (_isOwner)
                      PostDetailOwnerActions(
                        isResolved: post.isResolved,
                        onMarkResolved: _markAsResolved,
                        onReopen: _unresolvePost,
                        onDelete: _confirmDelete,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: topPad + 2,
          left: 14,
          child: PostDetailBackButton(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.pushNamed(AppRoutes.home);
              }
            },
          ),
        ),
        Positioned(
          top: PostDetailHeroSection.height - 40,
          left: 16,
          right: 16,
          child: PostDetailIdentityCard(
            post: post,
            onShare: () => ShareUtils.sharePost(post),
          ),
        ),
      ],
    );
  }
}
