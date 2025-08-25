// lib/models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// A data model for a Lost and Found post.
class PostModel {
  final String postId;
  final String postmakerId;
  final String userName;
  final String profileImageUrl;
  final String status;
  final String title;
  final String location;
  final String description;
  final List<String> itemImages;
  final String postTime;
  final String? question;
  final bool isClaimed;
  final String? postClaimerId;
  final String? postClaimerName;
  final String? postClaimerPic;

  PostModel({
    required this.postId,
    required this.postmakerId,
    required this.userName,
    required this.profileImageUrl,
    required this.status,
    required this.title,
    required this.location,
    required this.description,
    required this.itemImages,
    required this.postTime,
    this.question,
    this.isClaimed = false,
    this.postClaimerId,
    this.postClaimerName,
    this.postClaimerPic,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc, Map<String, String> userDetails) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id,
      postmakerId: data['postmakerId'] as String,
      userName: userDetails['name']!,
      profileImageUrl: userDetails['profileImage']!,
      status: data['status'] ?? '',
      title: data['item'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      itemImages: List<String>.from(data['imageUrls'] ?? []),
      postTime: _formatDate(data['timestamp'] as Timestamp?),
      question: data['question'] as String?,
      isClaimed: data['isClaimed'] ?? false,
      postClaimerId: data['postClaimer'] as String?,
      postClaimerName: data['postClaimerName'] as String?,
      postClaimerPic: data['postClaimerPic'] as String?,
    );
  }
}

String _formatDate(Timestamp? timestamp) {
  if (timestamp == null) return 'Not available';
  DateTime date = timestamp.toDate();
  return DateFormat('dd MMMM yyyy').format(date);
}
