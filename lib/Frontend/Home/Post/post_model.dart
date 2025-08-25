class PostModel {
  final String userName;
  final String profileImageUrl;
  final String postTime;
  final List<String> itemImages;
  final String status;
  final String title;
  final String location;
  final String description;
  final String postmakerId;
  final String postId;
  String? question;
  bool? isClaimed;
  String? postClaimer;
  String? claimStatus;
  String? postClaimerPic;
  String? postclaimerId;

  PostModel({
    this.postclaimerId,
    this.claimStatus,
    this.isClaimed,
    this.postClaimer,
    this.question,
    this.postClaimerPic,
    required this.userName,
    required this.profileImageUrl,
    required this.postTime,
    required this.itemImages,
    required this.status,
    required this.title,
    required this.location,
    required this.description,
    required this.postmakerId,
    required this.postId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // The ?? operator provides a default value if the json field is null, preventing crashes.
    return PostModel(
      // Nullable fields based on logic
      question: json['status'] == 'Found' ? json['question'] : null,
      isClaimed: json['status'] == 'Found' ? json['isClaimed'] : null,
      claimStatus: json['status'] == 'Found' ? json['claimStatus'] : null,
      postClaimer: json['status'] == 'Found' ? json['postClaimer'] : null,
      postclaimerId: json['status'] == 'Found' ? json['postClaimer'] : null,
      postClaimerPic: json['status'] == 'Found' ? json['postClaimerPic'] : null,
      
      // Required fields with safe defaults
      userName: json['userName'] ?? 'Unknown User',
      profileImageUrl: json['profileImageUrl'] ?? '',
      postTime: json['postTime'] ?? 'Unknown Date',
      itemImages: List<String>.from(json['imageUrls'] ?? []), // Corrected field name and added default
      status: json['status'] ?? 'Unknown',
      title: json['item'] ?? 'Untitled', // Corrected from 'title' to match your DB schema
      location: json['location'] ?? 'Unknown Location',
      description: json['description'] ?? 'No description.',
      postmakerId: json['postmakerId'] ?? '',
      postId: json['postId'] ?? '',
    );
  }
}
