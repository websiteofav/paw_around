import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/services/location_service.dart';
import 'package:paw_around/services/storage_service.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore;
  final LocationService _locationService;
  static const String _collection = 'lost_found_posts';

  CommunityRepository({
    FirebaseFirestore? firestore,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _locationService = locationService ?? LocationService();

  CollectionReference<Map<String, dynamic>> get _postsRef =>
      _firestore.collection(_collection);

  /// Fetch all posts ordered by date (newest first)
  Future<List<LostFoundPost>> getPosts({bool includeResolved = false}) async {
    Query<Map<String, dynamic>> query =
        _postsRef.orderBy('createdAt', descending: true);
    if (!includeResolved) {
      query = query.where('isResolved', isEqualTo: false);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => LostFoundPost.fromFirestore(doc))
        .toList();
  }

  /// Fetch posts within a specified radius from user location
  /// Filters posts client-side by distance
  /// Maximum radius is capped at 50km for performance
  Future<List<LostFoundPost>> getPostsWithinRadius({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    bool includeResolved = false,
  }) async {
    // Cap radius at 50km for performance
    const maxRadiusMeters = 50000;
    final effectiveRadius =
        radiusMeters > maxRadiusMeters ? maxRadiusMeters : radiusMeters;
    // Fetch all posts from Firestore
    Query<Map<String, dynamic>> query =
        _postsRef.orderBy('createdAt', descending: true);
    if (!includeResolved) {
      query = query.where('isResolved', isEqualTo: false);
    }
    final snapshot = await query.get();
    final allPosts =
        snapshot.docs.map((doc) => LostFoundPost.fromFirestore(doc)).toList();

    // Filter posts by distance
    final filteredPosts = <LostFoundPost>[];
    for (final post in allPosts) {
      // Validate coordinates
      if (post.latitude == 0.0 && post.longitude == 0.0) {
        continue; // Skip posts with invalid coordinates
      }

      final distance = _locationService.calculateDistance(
        startLatitude: latitude,
        startLongitude: longitude,
        endLatitude: post.latitude,
        endLongitude: post.longitude,
      );

      if (distance <= effectiveRadius) {
        filteredPosts.add(post);
      }
    }

    // Sort by distance (nearest first), then by date (newest first)
    filteredPosts.sort((a, b) {
      final distanceA = _locationService.calculateDistance(
        startLatitude: latitude,
        startLongitude: longitude,
        endLatitude: a.latitude,
        endLongitude: a.longitude,
      );
      final distanceB = _locationService.calculateDistance(
        startLatitude: latitude,
        startLongitude: longitude,
        endLatitude: b.latitude,
        endLongitude: b.longitude,
      );

      // First sort by distance
      final distanceComparison = distanceA.compareTo(distanceB);
      if (distanceComparison != 0) {
        return distanceComparison;
      }

      // If distances are equal, sort by date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return filteredPosts;
  }

  /// Stream of posts for real-time updates
  Stream<List<LostFoundPost>> getPostsStream({
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) {
    return _postsRef
        .where('isResolved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) {
      final posts = s.docs.map((d) => LostFoundPost.fromFirestore(d)).toList();

      // Apply radius filtering if location is provided
      if (latitude != null && longitude != null && radiusMeters != null) {
        final filteredPosts = <LostFoundPost>[];
        for (final post in posts) {
          // Validate coordinates
          if (post.latitude == 0.0 && post.longitude == 0.0) {
            continue; // Skip posts with invalid coordinates
          }

          final distance = _locationService.calculateDistance(
            startLatitude: latitude,
            startLongitude: longitude,
            endLatitude: post.latitude,
            endLongitude: post.longitude,
          );

          // Cap radius at 50km for performance
          const maxRadiusMeters = 50000;
          final effectiveRadius =
              radiusMeters > maxRadiusMeters ? maxRadiusMeters : radiusMeters;

          if (distance <= effectiveRadius) {
            filteredPosts.add(post);
          }
        }

        // Sort by distance (nearest first), then by date (newest first)
        filteredPosts.sort((a, b) {
          final distanceA = _locationService.calculateDistance(
            startLatitude: latitude,
            startLongitude: longitude,
            endLatitude: a.latitude,
            endLongitude: a.longitude,
          );
          final distanceB = _locationService.calculateDistance(
            startLatitude: latitude,
            startLongitude: longitude,
            endLatitude: b.latitude,
            endLongitude: b.longitude,
          );

          // First sort by distance
          final distanceComparison = distanceA.compareTo(distanceB);
          if (distanceComparison != 0) {
            return distanceComparison;
          }

          // If distances are equal, sort by date (newest first)
          return b.createdAt.compareTo(a.createdAt);
        });

        return filteredPosts;
      }

      return posts;
    });
  }

  /// Create a new post
  Future<LostFoundPost> createPost(LostFoundPost post) async {
    final docRef = await _postsRef.add(post.toFirestore());
    return post.copyWith(id: docRef.id);
  }

  /// Get a single post by ID
  Future<LostFoundPost?> getPostById(String id) async {
    final doc = await _postsRef.doc(id).get();
    if (!doc.exists) return null;
    return LostFoundPost.fromFirestore(doc);
  }

  /// Fetch all posts by a specific user (includes resolved posts)
  Future<List<LostFoundPost>> getPostsByUser(String userId) async {
    final snapshot = await _postsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => LostFoundPost.fromFirestore(doc))
        .toList();
  }

  /// Mark a post as resolved
  Future<void> markAsResolved(String postId) async {
    await _postsRef.doc(postId).update({'isResolved': true});
  }

  /// Unresolve a post (reopen it)
  Future<void> unresolvePost(String postId) async {
    await _postsRef.doc(postId).update({'isResolved': false});
  }

  /// Delete a post
  Future<void> deletePost(String postId,
      {StorageService? storageService}) async {
    // Get post to check for image
    final post = await getPostById(postId);
    if (post?.imagePath != null && post!.imagePath!.startsWith('http')) {
      final storage = storageService ?? StorageService();
      await storage.deleteImage(post.imagePath!);
    }

    await _postsRef.doc(postId).delete();
  }

  /// Delete all posts for a specific user (used for account deletion)
  Future<void> deleteAllPostsForUser(String userId,
      {StorageService? storageService}) async {
    final snapshot = await _postsRef.where('userId', isEqualTo: userId).get();

    final storage = storageService ?? StorageService();

    // Delete images from storage
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final imagePath = data['imagePath'] as String?;
      if (imagePath != null && imagePath.startsWith('http')) {
        await storage.deleteImage(imagePath);
      }
    }

    // Delete all posts in a batch
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
