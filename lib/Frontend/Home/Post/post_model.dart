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
    return PostModel(
      question: json['status'] == 'Found' ? json['question'] : null,
      isClaimed: json['status'] == 'Found' ? json['isClaimed'] : null,
      claimStatus: json['status'] == 'Found' ? json['claimStatus'] : null,
      postClaimer: json['status'] == 'Found' ? json['postClaimer'] : null,
       postclaimerId: json['status'] == 'Found' ? json['postClaimer'] : null,
      postClaimerPic: json['status'] == 'Found' ? json['postClaimerPic'] : null,
      userName: json['userName'],
      profileImageUrl: json['profileImageUrl'],
      postTime: json['postTime'],
      itemImages: List<String>.from(json['itemImages']),
      status: json['status'],
      title: json['title'],
      location: json['location'],
      description: json['description'],
      postmakerId: json['postmakerId'],
      postId: json['postId'],
    );
  }
}
