import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/constants/api_constants.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/services/location_service.dart';
import 'package:paw_around/ui/home/widgets/post_card.dart';
import 'package:paw_around/ui/home/widgets/skeleton_card.dart';
import 'package:paw_around/ui/widgets/empty_state_widget.dart';

class LostFoundTab extends StatefulWidget {
  const LostFoundTab({super.key});

  @override
  State<LostFoundTab> createState() => _LostFoundTabState();
}

class _LostFoundTabState extends State<LostFoundTab>
    with AutomaticKeepAliveClientMixin {
  final LocationService _locationService = sl<LocationService>();
  Position? _userPosition;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    if (_hasLoadedOnce) return;
    _hasLoadedOnce = true;

    final communityState = context.read<CommunityBloc>().state;
    final alreadyHasData =
        communityState is CommunityLoaded || communityState is CommunityLoading;

    if (alreadyHasData) {
      // Keep existing feed data and only resolve location for distance labels.
      _loadUserLocationOnly();
      return;
    }

    _loadUserLocationAndPosts();
  }

  Future<void> _loadUserLocationOnly() async {
    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() {
      if (result.isSuccess && result.position != null) {
        _userPosition = result.position;
      } else {
        _userPosition = null;
      }
    });
  }

  Future<void> _loadUserLocationAndPosts() async {
    final result = await _locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        if (result.isSuccess && result.position != null) {
          _userPosition = result.position;
        } else {
          _userPosition = null;
        }
      });
      _loadPosts();
    }
  }

  void _loadPosts() {
    if (_userPosition != null) {
      context.read<CommunityBloc>().add(
            LoadPosts(
              userLocation: _userPosition,
              radiusMeters: ApiConstants.defaultCommunityRadius,
            ),
          );
    } else {
      // Fallback to all posts if location unavailable
      context.read<CommunityBloc>().add(const LoadPosts());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is PostDeleted ||
            state is PostResolved ||
            state is PostUnresolved) {
          _loadPosts();
        }
      },
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
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildEmptyState() {
    // Show different message if location is unavailable
    final hasLocation = _userPosition != null;
    final title =
        hasLocation ? AppStrings.noPostsInYourArea : AppStrings.noPostsYet;
    final subtitle = hasLocation
        ? AppStrings.lostPetsAreOftenFoundWithinTheFirst2448Hours
        : AppStrings.enableLocationToSeeNearbyPosts;

    return EmptyStateWidget(
      icon: Icons.pets,
      title: title,
      subtitle: subtitle,
      actionText: AppStrings.createLostFoundPost,
      onAction: () async {
        await context.push('/community/create');
        if (mounted) {
          _loadPosts();
        }
      },
      hints: [
        if (!hasLocation)
          const EmptyStateHint(
            icon: Icons.location_on_outlined,
            text: AppStrings.enableLocationToSeeNearbyPosts,
          )
        else ...[
          const EmptyStateHint(
            icon: Icons.location_on_outlined,
            text: AppStrings.helpReunitePets,
          ),
          const EmptyStateHint(
            icon: Icons.people_outline,
            text: AppStrings.alertNearbyParents,
          ),
        ],
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
        await _loadUserLocationAndPosts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 120,
        ),
        itemCount: state.posts.length,
        itemBuilder: (context, index) {
          final post = state.posts[index];
          return PostCard(
            post: post,
            onTap: () async {
              await context
                  .push(AppRoutes.postDetail.replaceAll(':id', post.id));
              if (mounted) {
                _loadPosts();
              }
            },
            distanceKm: _userPosition != null
                ? _locationService.calculateDistance(
                    startLatitude: post.latitude,
                    startLongitude: post.longitude,
                    endLatitude: _userPosition!.latitude,
                    endLongitude: _userPosition!.longitude)
                : null,
          );
        },
      ),
    );
  }
}
