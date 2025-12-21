import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/utils/date_utils.dart';
import 'package:paw_around/utils/url_utils.dart';

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
    context.read<CommunityBloc>().add(MarkPostResolved(widget.postId));
    context.pop();
  }

  void _deletePost() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deletePost),
        content: const Text(AppStrings.deletePostConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<CommunityBloc>().add(DeletePost(widget.postId));
            },
            child: const Text(AppStrings.deletePost, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is PostDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.postDeletedSuccessfully)),
          );
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _post == null
                ? const Center(child: Text('Post not found'))
                : SafeArea(
                    child: CustomScrollView(
                      slivers: [
                        _buildAppBar(),
                        SliverToBoxAdapter(child: _buildContent()),
                      ],
                    ),
                  ),
        bottomNavigationBar: _post != null ? _buildBottomBar() : null,
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.navigationBackground,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.pushNamed(AppRoutes.home);
            }
          },
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildPostImage(),
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 16,
              child: _buildTypeBadge(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostImage() {
    if (_post!.imagePath == null || _post!.imagePath!.isEmpty) {
      return _buildImagePlaceholder();
    }

    // Check if it's a network URL
    if (_post!.imagePath!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: _post!.imagePath!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => _buildImagePlaceholder(),
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Icon(Icons.pets, size: 80, color: AppColors.textLight),
    );
  }

  Widget _buildTypeBadge() {
    final isLost = _post!.type == PostType.lost;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isLost ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isLost ? AppStrings.lost : AppStrings.found,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_post?.petName ?? '', style: AppTextStyles.appTitle()),
          const SizedBox(height: 8),
          Text('${_post?.breed ?? ''} • ${_post?.color ?? ''}', style: AppTextStyles.cardSubtitle()),
          const SizedBox(height: 16),
          Text(_post?.petDescription ?? '', style: AppTextStyles.bodyText()),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.person_outline, AppStrings.postedBy, _post?.userName ?? ''),
          const SizedBox(height: 12),
          _buildInfoRow(
              Icons.location_on, _post!.isLost ? AppStrings.lastSeenAt : AppStrings.foundAt, _post!.locationName),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, AppStrings.contactPhone, _post!.contactPhone),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, AppStrings.posted, AppDateUtils.getRelativeTime(_post!.createdAt)),
          const SizedBox(height: 24),
          _buildMap(),
          const SizedBox(height: 24),
          if (_isOwner) _buildOwnerActions(),
        ],
      ),
    );
  }

  Widget _buildOwnerActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommonButton(
          text: AppStrings.markAsResolved,
          onPressed: _markAsResolved,
          variant: ButtonVariant.outline,
          icon: Icons.check_circle,
          customColor: Colors.green,
          customTextColor: Colors.green,
        ),
        const SizedBox(height: 12),
        CommonButton(
          text: AppStrings.deletePost,
          onPressed: _deletePost,
          variant: ButtonVariant.danger,
          icon: Icons.delete_outline,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.cardSubtitle(fontSize: 12)),
            Text(value, style: AppTextStyles.bodyText()),
          ],
        ),
      ],
    );
  }

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(_post!.latitude, _post!.longitude),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('post_location'),
              position: LatLng(_post!.latitude, _post!.longitude),
            ),
          },
          zoomControlsEnabled: false,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CommonButton(
                text: AppStrings.callOwner,
                onPressed: () => UrlUtils.openPhone(_post!.contactPhone),
                variant: ButtonVariant.outline,
                icon: Icons.phone,
                size: ButtonSize.small,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CommonButton(
                text: AppStrings.getDirections,
                onPressed: () => UrlUtils.openDirections(latitude: _post!.latitude, longitude: _post!.longitude),
                variant: ButtonVariant.primary,
                icon: Icons.directions,
                size: ButtonSize.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
