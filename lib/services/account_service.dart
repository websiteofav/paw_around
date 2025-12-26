import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';

/// Service for account-related operations
class AccountService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Deletes the current user's account and all associated data
  /// Throws FirebaseAuthException if re-authentication is required
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final userId = user.uid;

    // Delete user's pets
    final petRepository = sl<PetRepository>();
    await petRepository.deleteAllPetsForUser(userId);

    // Delete user's posts
    final communityRepository = sl<CommunityRepository>();
    await communityRepository.deleteAllPostsForUser(userId);

    // Delete the Firebase Auth account
    await user.delete();
  }

  /// Re-authenticates user with Google credentials
  Future<void> reAuthWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.currentUser?.reauthenticateWithCredential(credential);
  }

  /// Check if current user has Google provider
  bool get hasGoogleProvider {
    return _auth.currentUser?.providerData.any((p) => p.providerId == 'google.com') ?? false;
  }

  /// Check if current user has phone provider
  bool get hasPhoneProvider {
    return _auth.currentUser?.phoneNumber != null;
  }
}
