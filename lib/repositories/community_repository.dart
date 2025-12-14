import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paw_around/models/community/lost_found_post.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'lost_found_posts';

  CommunityRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _postsRef => _firestore.collection(_collection);

  /// Fetch all posts ordered by date (newest first)
  Future<List<LostFoundPost>> getPosts({bool includeResolved = false}) async {
    Query<Map<String, dynamic>> query = _postsRef.orderBy('createdAt', descending: true);
    if (!includeResolved) {
      query = query.where('isResolved', isEqualTo: false);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => LostFoundPost.fromFirestore(doc)).toList();
  }

  /// Stream of posts for real-time updates
  Stream<List<LostFoundPost>> getPostsStream() {
    return _postsRef
        .where('isResolved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => LostFoundPost.fromFirestore(d)).toList());
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

  /// Mark a post as resolved
  Future<void> markAsResolved(String postId) async {
    await _postsRef.doc(postId).update({'isResolved': true});
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    await _postsRef.doc(postId).delete();
  }
}
