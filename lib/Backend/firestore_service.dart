// lib/Backend/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A service class to handle all Firestore and Firebase Storage operations
/// related to lost and found posts.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches the current user's data from Firestore.
  Future<Map<String, dynamic>?> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return null;
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
    return null;
  }

  /// Handles the process of picking images, with platform-specific logic.
  Future<List<Uint8List>?> pickImages() async {
    try {
      if (kIsWeb) {
        // Use FilePicker for web
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );
        return result?.files.map((file) => file.bytes!).toList();
      } else {
        // Use ImagePicker for mobile
        final ImagePicker picker = ImagePicker();
        final List<XFile> pickedFiles = await picker.pickMultiImage();
        List<Uint8List> imageBytes = [];
        for (var pickedFile in pickedFiles) {
          final Uint8List fileBytes = await pickedFile.readAsBytes();
          imageBytes.add(fileBytes);
        }
        return imageBytes;
      }
    } catch (e) {
      print('Error picking files: $e');
      return null;
    }
  }

  /// Uploads images to Firebase Storage and returns their download URLs.
  Future<List<String>> uploadImages(List<Uint8List> imageBytes) async {
    final uploadFutures = imageBytes.asMap().entries.map((entry) async {
      final index = entry.key;
      final imageByteData = entry.value;
      final fileName =
          'images/${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
      final ref = _storage.ref().child(fileName);
      await ref.putData(imageByteData);
      return ref.getDownloadURL();
    });
    return Future.wait(uploadFutures);
  }

  /// Creates a new post in Firestore with the given data.
  Future<void> createPost({
    required String status,
    required String title,
    required String location,
    required String description,
    required List<Uint8List> imageBytes,
    String? hostel,
    String? question,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated.');
    }

    List<String> imageUrls = await uploadImages(imageBytes);

    final data = {
      'location': location,
      'item': title,
      'description': description,
      'imageUrls': imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
      'postmakerId': user.uid,
      'isClaimed': false,
      'postClaimer': null,
      'claimStatus': "",
      'question': question,
      'status': status,
      'hostel': hostel,
    };

    DocumentReference postRef = await _firestore.collection('posts').add(data);
    await postRef.update({'postId': postRef.id});
  }

  /// Deletes a post from Firestore.
  Future<void> deletePost(BuildContext context, String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Post deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to delete post: $e'),
        ),
      );
    }
  }

  /// Sends a message to the postmaker (e.g., for general inquiries).
  Future<void> replyToPostmaker(BuildContext context, String postmakerId,
      String message, String postId) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated.');

      await _firestore.collection('chats').add({
        'senderId': user.uid,
        'receiverId': postmakerId,
        'participants': [user.uid, postmakerId],
        'message': message,
        'postId': postId,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Sends a claim request to the post owner.
  Future<void> claimPost(BuildContext context, String postId,
      String postmakerId, String answer) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated.');

      final claimsRef =
          _firestore.collection('posts').doc(postId).collection('claims');

      await claimsRef.add({
        'senderId': user.uid,
        'answer': answer,
        'claimStatusC': 'requested',
        'timestamp': Timestamp.now(),
        'receiverId': postmakerId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your claim request has been sent.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send claim request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
