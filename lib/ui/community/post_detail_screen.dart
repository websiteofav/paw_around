import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/repositories/community_repository.dart';
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

  void _markAsResolved() {
    context.read<CommunityBloc>().add(MarkPostResolved(widget.postId));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
              ? const Center(child: Text('Post not found'))
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(child: _buildContent()),
                  ],
                ),
      bottomNavigationBar: _post != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.navigationBackground,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _post!.imagePath != null && _post!.imagePath!.isNotEmpty
                ? Image.file(File(_post!.imagePath!), fit: BoxFit.cover)
                : Container(
                    color: AppColors.surface,
                    child: const Icon(Icons.pets, size: 80, color: AppColors.textLight),
                  ),
            Positioned(
              top: 48,
              right: 16,
              child: _buildTypeBadge(),
            ),
          ],
        ),
      ),
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
          Text(_post!.petName, style: AppTextStyles.appTitle),
          const SizedBox(height: 8),
          Text('${_post!.breed} • ${_post!.color}', style: AppTextStyles.cardSubtitle),
          const SizedBox(height: 16),
          Text(_post!.petDescription, style: AppTextStyles.bodyText),
          const SizedBox(height: 24),
          _buildInfoRow(
              Icons.location_on, _post!.isLost ? AppStrings.lastSeenAt : AppStrings.foundAt, _post!.locationName),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, AppStrings.contactPhone, _post!.contactPhone),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, 'Posted', _getTimeAgo()),
          const SizedBox(height: 24),
          _buildMap(),
          const SizedBox(height: 24),
          _buildResolveButton(),
        ],
      ),
    );
  }

  Widget _buildResolveButton() {
    // TODO: Check if current user is the post owner
    return OutlinedButton.icon(
      onPressed: _markAsResolved,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      label: const Text(AppStrings.markAsResolved, style: TextStyle(color: Colors.green)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Colors.green),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
            Text(label, style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12)),
            Text(value, style: AppTextStyles.bodyText),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => UrlUtils.openPhone(_post!.contactPhone),
                icon: const Icon(Icons.phone),
                label: const Text(AppStrings.callOwner),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => UrlUtils.openDirections(latitude: _post!.latitude, longitude: _post!.longitude),
                icon: const Icon(Icons.directions, color: Colors.white),
                label: const Text(AppStrings.getDirections, style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo() {
    final diff = DateTime.now().difference(_post!.createdAt);
    if (diff.inDays > 0) return '${diff.inDays} days ${AppStrings.ago}';
    if (diff.inHours > 0) return '${diff.inHours} hours ${AppStrings.ago}';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ${AppStrings.ago}';
    return 'Just now';
  }
}
