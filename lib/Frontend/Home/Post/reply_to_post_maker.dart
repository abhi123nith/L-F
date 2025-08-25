import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Frontend/Profile/user_see_page.dart';

class ReplyToPostMaker {
  Future<void> sendAnswerToPostmaker(
      BuildContext context,
      String answer,
      String postId,
      String postmakerId,
      String statusofRequest,
      User? user) async {
    try {
      // Reference to the specific post's claims subcollection
      CollectionReference claimsRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId) // Get the post document using its ID
          .collection('claims'); // Access the subcollection

      // Add a new claim document
      await claimsRef.add({
        'senderId': user!.uid,
        'answer': answer,
        'claimStatusC': statusofRequest,
        'timestamp': Timestamp.now(),
        'isClaimed': false,
        'receiverId': postmakerId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your answer has been sent to the post maker'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.0),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send answer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void claimedPost(BuildContext context, String postclaimerId, String postTitle,
      String claimername, String postId, User? user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Claimed Item : $postTitle',
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Already claimed by :',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) =>
                                ProfilePage2(uid: postclaimerId),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Text(
                          user!.uid == postclaimerId ? 'You' : claimername,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void replyToPostmaker(BuildContext context, String postmakerId,
      String postmaker, String postId, User? user) {
    TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send a Reply'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Reply to'),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) =>
                                ProfilePage2(uid: postmakerId),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Text(postmaker))
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Your message',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without sending
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String message = messageController.text.trim();
                if (message.isNotEmpty) {
                  ReplyToPostMaker().sendMessageToPostmaker(
                      context, postmakerId, message, postId, user!);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message sent successfully'),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.0),
                  ),
                );
                Navigator.of(context).pop(); // Close the dialog after sending
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void claimPost(BuildContext context, String postmakerId, String postTitle,
      String postQuestion, String postdescription, String postId, User? user) {
    TextEditingController answerController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Claim Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Question from the post owner:'),
              const SizedBox(height: 10),
              Text(postQuestion,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: 'Your answer',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String answer = answerController.text.trim();
                if (answer.isNotEmpty) {
                  ReplyToPostMaker().sendAnswerToPostmaker(
                      context, answer, postId, postmakerId, 'requested', user);
                  print(
                      'SENT DATATATAT : $answer, " ", $postId, "__" , $postmakerId');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request sent successfully'),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.0),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendMessageToPostmaker(BuildContext context, String postmakerId,
      String message, String postId, User user) async {
    try {
      // Add a chat message to Firestore
      await FirebaseFirestore.instance.collection('chats').add({
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
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.0),
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
}
