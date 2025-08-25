// lib/services/profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:l_f/newCode/service/user_service.dart';

/// A service to handle profile-specific data and business logic.
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  /// Fetches user data for a given UID.
  Future<Map<String, dynamic>?> fetchUserDetails(String uid) {
    return _userService.fetchUserData(uid);
  }

  /// Checks if a phone number can be shown to the current user.
  /// The logic is based on whether the current user has a claimed a post
  /// that was created by the profile owner.
  Future<bool> canShowPhoneNumber(
      String profileOwnerId, String currentUserId) async {
    try {
      if (profileOwnerId == currentUserId) {
        return true; // The user can always see their own number
      }

      final claims = await _firestore
          .collection('posts')
          .where('postClaimer', isEqualTo: profileOwnerId)
          .where('isClaimed', isEqualTo: true)
          .get();

      return claims.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone number visibility: $e');
      return false;
    }
  }
}
