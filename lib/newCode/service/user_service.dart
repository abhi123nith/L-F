// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

/// A service to handle user data fetching, caching, and updates.
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Map<String, Map<String, dynamic>> _userCache = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches and caches a user's name and profile picture from Firestore.
  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    if (_userCache.containsKey(uid)) {
      return _userCache[uid]!; // Return cached data if available
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return null;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      // Cache the user data
      _userCache[uid] = userData;
      return _userCache[uid];
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  /// Uploads a profile image to Firebase Storage and returns the download URL.
  Future<String?> uploadProfileImage(Uint8List imageBytes) async {
    try {
      final storageRef = _storage.ref().child(
          'profileImages/${DateTime.now().toIso8601String()}');
      final uploadTask = storageRef.putData(imageBytes);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Handles the process of picking a single image, with platform-specific logic.
  Future<Uint8List?> pickSingleImage() async {
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.image,
        );
        return result?.files.first.bytes;
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
        return pickedFile != null ? await pickedFile.readAsBytes() : null;
      }
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  /// Updates user details in Firestore.
  Future<void> updateUserDetails(String uid, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(uid).update(updatedData);
      // Update cache
      if (_userCache.containsKey(uid)) {
        _userCache[uid]!.addAll(updatedData);
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile.');
    }
  }
}
