import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/utils/date_utils.dart';
import 'package:paw_around/utils/share_utils.dart';
import 'package:paw_around/utils/url_utils.dart';
import 'package:paw_around/utils/utils.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  LostFoundPost? _post;
  bool _isLoading = true;
  bool _isDeleting = false;

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
  }

  void _unresolvePost() {
    context.read<CommunityBloc>().add(UnresolvePost(widget.postId));
  }

  void _deletePost() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  size: 32,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.deletePost,
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 18,
                  fontColor: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.deletePostConfirmation,
                style: AppTextStyles.regularStyle400(
                    fontSize: 14, fontColor: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: AppStrings.cancel,
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.small,
                      onPressed: _isDeleting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonButton(
                      text: AppStrings.delete,
                      variant: ButtonVariant.danger,
                      size: ButtonSize.small,
                      isLoading: _isDeleting,
                      onPressed: _isDeleting
                          ? null
                          : () async {
                              setDialogState(() => _isDeleting = true);
                              setState(() => _isDeleting = true);
                              context
                                  .read<CommunityBloc>()
                                  .add(DeletePost(widget.postId));
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is PostDeleted) {
          // Close dialog first (if it's open)
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
                content: Text('Post marked as resolved'),
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
                ? const Center(child: Text('Post not found'))
                : SafeArea(
                    child: CustomScrollView(
                      slivers: [
                        _buildAppBar(),
                        SliverToBoxAdapter(child: _buildContent()),
                      ],
                    ),
                  ),
        bottomNavigationBar:
            _post != null && !_isOwner ? _buildBottomBar() : null,
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
          color: AppColors.shadowOverlay.withValues(alpha: 0.3),
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
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.shadowOverlay.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Image.asset(
              AppIcons.shareIcon,
              width: 20,
              height: 20,
              color: Colors.white,
              colorBlendMode: BlendMode.srcIn,
            ),
            onPressed:
                _post != null ? () => ShareUtils.sharePost(_post!) : null,
            tooltip: AppStrings.sharePost,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero animation for smooth transition from list
            Hero(
              tag: 'post-image-${widget.postId}',
              child: _buildPostImage(),
            ),
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.shadowOverlay.withValues(alpha: 0.3),
                    Colors.transparent,
                    AppColors.shadowOverlay.withValues(alpha: 0.5),
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
      decoration: smoothDecoration(
        cornerRadius: 20,
        color: isLost ? AppColors.error : AppColors.success,
        shadows: [
          BoxShadow(
            color: (isLost ? AppColors.error : AppColors.success)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLost ? Icons.search : Icons.favorite,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            isLost ? AppStrings.lost : AppStrings.found,
            style: AppTextStyles.boldStyle700(fontColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet name and basic info
          Text(_post?.petName ?? '',
              style: AppTextStyles.boldStyle700(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            '${_post?.breed ?? ''} • ${_post?.color ?? ''}',
            style: AppTextStyles.regularStyle400(
                fontSize: 14, fontColor: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Description
          if (_post!.petDescription.isNotEmpty) ...[
            Text(
              _post!.petDescription,
              style: AppTextStyles.regularStyle400(fontSize: 15),
            ),
            const SizedBox(height: 20),
          ],

          // Details Card
          _buildSectionHeader(AppStrings.details, icon: Icons.info_outline),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: smoothDecoration(
              cornerRadius: 16,
              color: AppColors.white,
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                    Icons.person_outline,
                    AppStrings.postedBy,
                    _isOwner
                        ? AppStrings.yourPost
                        : _post?.userName.orDefault(AppStrings.anonymous) ??
                            ''),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  _post!.isLost ? AppStrings.lastSeenAt : AppStrings.foundAt,
                  _post!.locationName,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                _buildInfoRow(Icons.phone_outlined, AppStrings.contactPhone,
                    _post!.contactPhone),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                _buildInfoRow(Icons.access_time, AppStrings.posted,
                    AppDateUtils.getRelativeTime(_post!.createdAt)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Location Section
          _buildSectionHeader(AppStrings.location, icon: Icons.map_outlined),
          _buildMap(),
          const SizedBox(height: 24),

          if (_isOwner) _buildOwnerActions(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: AppTextStyles.semiBoldStyle600(
              fontSize: 13,
              fontColor: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerActions() {
    final isResolved = _post?.isResolved ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isResolved)
          CommonButton(
            text: AppStrings.markAsResolved,
            onPressed: _markAsResolved,
            variant: ButtonVariant.outline,
            icon: Icons.check_circle,
            customColor: Colors.green,
            customTextColor: Colors.green,
          )
        else
          CommonButton(
            text: AppStrings.reopenPost,
            onPressed: _unresolvePost,
            variant: ButtonVariant.outline,
            icon: Icons.refresh,
            customColor: Colors.orange,
            customTextColor: Colors.orange,
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: smoothDecoration(
            cornerRadius: 8,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.regularStyle400(
                    fontSize: 12, fontColor: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.semiBoldStyle600(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return Container(
      decoration: smoothDecoration(
        cornerRadius: 16,
        side: const BorderSide(color: AppColors.border),
        shadows: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipSmoothRect(
        radius: AppSmoothRadius.custom(15),
        child: SizedBox(
          height: 180,
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
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
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
            const SizedBox(width: 8),
            Expanded(
              child: CommonButton(
                text: AppStrings.getDirections,
                onPressed: () => UrlUtils.openDirections(
                    latitude: _post!.latitude, longitude: _post!.longitude),
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
