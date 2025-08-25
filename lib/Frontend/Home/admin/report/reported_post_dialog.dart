import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Frontend/Home/Post/post_model.dart'; // Adjust this import
import 'package:l_f/Frontend/Home/admin/report/pst_card.dart';

class ReportedPostDialog extends StatefulWidget {
  final String reportId;
  final String postId;
  final String postOwnerId;
  final String reporterId; // Added reporterId

  const ReportedPostDialog({
    super.key,
    required this.reportId,
    required this.postId,
    required this.postOwnerId,
    required this.reporterId, // Added reporterId
  });

  @override
  State<ReportedPostDialog> createState() => _ReportedPostDialogState();
}

class _ReportedPostDialogState extends State<ReportedPostDialog> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ADMIN ACTION 1: Approve report and delete the post ---
  Future<void> _approveAndDelelePost() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Use a batch write to perform multiple operations atomically
      WriteBatch batch = _db.batch();

      // 1. Delete the post
      batch.delete(_db.collection('posts').doc(widget.postId));

      // 2. Update the report status to "approved"
      batch.update(_db.collection('reports').doc(widget.reportId),
          {'status': 'approved'});

      await batch.commit();

      navigator.pop(); // Close the dialog
      messenger.showSnackBar(const SnackBar(
        content: Text("Report approved and post deleted."),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text("Error deleting post: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  // --- ADMIN ACTION 2: Send a warning to the post owner ---
  Future<void> _sendWarningToPostOwner() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      WriteBatch batch = _db.batch();

      // 1. Create a warning document
      batch.set(_db.collection('warnings').doc(), {
        'userId': widget.postOwnerId,
        'postId': widget.postId,
        'reportId': widget.reportId,
        'timestamp': FieldValue.serverTimestamp(),
        'message':
            'Your post (ID: ${widget.postId}) was reported and found to violate community guidelines. This serves as a formal warning.',
      });

      // 2. Update the user's warning count
      batch.update(_db.collection('users').doc(widget.postOwnerId),
          {'warningCount': FieldValue.increment(1)});

      // 3. Update the report status
      batch.update(_db.collection('reports').doc(widget.reportId),
          {'status': 'warning_sent'});

      await batch.commit();

      navigator.pop();
      messenger.showSnackBar(const SnackBar(
        content: Text("Warning sent to the post owner."),
        backgroundColor: Colors.orange,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text("Error sending warning: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  // --- ADMIN ACTION 3: Dismiss the report and warn the reporter ---
  Future<void> _dismissReportAndWarnReporter() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      WriteBatch batch = _db.batch();

      // 1. Update the report status to "dismissed"
      batch.update(_db.collection('reports').doc(widget.reportId),
          {'status': 'dismissed'});

      // 2. Create a warning for the reporter about false reporting
      batch.set(_db.collection('warnings').doc(), {
        'userId': widget.reporterId,
        'postId': widget.postId,
        'reportId': widget.reportId,
        'timestamp': FieldValue.serverTimestamp(),
        'message':
            'Your report on post (ID: ${widget.postId}) was reviewed and found to be invalid. Please only report content that violates guidelines. This serves as a warning against false reporting.',
      });

      // 3. Update the reporter's false report count
      batch.update(_db.collection('users').doc(widget.reporterId),
          {'falseReportCount': FieldValue.increment(1)});

      await batch.commit();

      navigator.pop();
      messenger.showSnackBar(const SnackBar(
        content: Text("Report dismissed and reporter has been warned."),
        backgroundColor: Colors.grey,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text("Error dismissing report: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Review Reported Post"),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<DocumentSnapshot>(
          future: _db.collection('posts').doc(widget.postId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text("This post may have already been deleted."),
              );
            }

            final postData = snapshot.data!.data() as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future:
                  _db.collection('users').doc(postData['postmakerId']).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData =
                    userSnapshot.data?.data() as Map<String, dynamic>? ?? {};

                final postModel = PostModel.fromJson({
                  ...postData,
                  'userName': userData['name'] ?? 'Unknown User',
                  'profileImageUrl': userData['profileImageUrl'] ?? '',
                  'postTime': 'N/A',
                });

                return SingleChildScrollView(
                  child: PostCard(
                    post: postModel,
                    isOwner: false,
                    onDelete: () {},
                    onReport: () {},
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: _dismissReportAndWarnReporter,
          child: const Text('Dismiss Report',
              style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: _sendWarningToPostOwner,
          child: const Text('Send Warning'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _approveAndDelelePost,
          child: const Text('Delete Post'),
        ),
      ],
    );
  }
}
