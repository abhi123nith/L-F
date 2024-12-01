import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:l_f/Frontend/Home/Post/Utils/full_post.dart';
import 'package:l_f/Frontend/Profile/user_see_page.dart';

class ChatDetailPage extends StatefulWidget {
  final String otherUserId;

  const ChatDetailPage({required this.otherUserId, super.key});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.otherUserId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String name = userData['name'] ?? 'Unknown User';
          String profileImage = userData['profileImage'] ?? '';

          return Column(
            children: [
              _buildUserProfileSection(name, profileImage),
              Expanded(child: _buildChatSection()),
              _buildMessageInputSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserProfileSection(String name, String profileImage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProfilePage2(uid: widget.otherUserId)));
      },
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: profileImage.isNotEmpty
                ? NetworkImage(profileImage)
                : const NetworkImage(
                        'https://firebasestorage.googleapis.com/v0/b/lostfound-fe03f.appspot.com/o/images%2F1728657135536_0.jpg?alt=media&token=179c07c7-bf27-4d65-b762-618f0a4e660e')
                    as ImageProvider,
          ),
          title:
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text(
              'Online'), // You can fetch and display actual online status if available
        ),
      ),
    );
  }

  Widget _buildChatSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }

        var messages = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return (data['senderId'] == currentUser!.uid &&
                  data['receiverId'] == widget.otherUserId) ||
              (data['senderId'] == widget.otherUserId &&
                  data['receiverId'] == currentUser!.uid);
        }).toList();

        if (messages.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            var postId = message['postId'];
            var isSentByUser = message['senderId'] == currentUser!.uid;
            var messageText = message['message'];
            var timestamp = (message['timestamp'] as Timestamp).toDate();

            // Check if postId exists
            if (postId != null && postId.isNotEmpty) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .get(),
                builder: (context, postSnapshot) {
                  if (!postSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var postData = postSnapshot.data!;
                  var itemName = postData['item'] ?? 'Unknown';
                  var description = postData['description'] ?? 'No description';
                  var type = postData['location'] ?? 'Unknown';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailsPage(postId: postId),
                        ),
                      );
                    },
                    child: Card(
                      color: isSentByUser ? Colors.blue[100] : Colors.grey[300],
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item: $itemName',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('Description: $description'),
                            const SizedBox(height: 5),
                            Text('Location: $type'),
                            const SizedBox(height: 10),
                            Align(
                              alignment: isSentByUser
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Text(
                                '${timestamp.hour}:${timestamp.minute}, ${timestamp.day}/${timestamp.month}/${timestamp.year}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Text('Reply: $messageText'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            // If postId is null, show regular message
            return ListTile(
              title: Align(
                alignment:
                    isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSentByUser ? Colors.blue[200] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    messageText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              subtitle: Align(
                alignment:
                    isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '${timestamp.hour}:${timestamp.minute}, ${timestamp.day}/${timestamp.month}/${timestamp.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInputSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Button to pick image or video
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: _pickImageOrVideo,
          ),
          Expanded(
            child: TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _sendMessage(_messageController.toString());
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageOrVideo() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      // for video, you can use picker.pickVideo() or pick from both
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileUrl = await _uploadFile(file);

      // Send the message with media URL
      _sendMessageWithMedia(fileUrl, 'image'); // 'image' or 'video'
    }
  }

  Future<String> _uploadFile(File file) async {
    try {
      // Upload the selected image or video to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef =
          FirebaseStorage.instance.ref().child('chats/$fileName');

      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      String fileUrl = await taskSnapshot.ref.getDownloadURL();
      return fileUrl;
    } catch (e) {
      print("Error uploading file: $e");
      return '';
    }
  }

  void _sendMessage(String message) async {
    message = _messageController.text.trim();
    if (message.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('chats').add({
          'senderId': currentUser!.uid,
          'receiverId': widget.otherUserId,
          'participants': [currentUser!.uid, widget.otherUserId],
          'message': message,
          'timestamp': Timestamp.now(),
          'postId': '',
          'mediaUrl': '', // Add a field for media URL
          'mediaType': '', // 'image' or 'video' to distinguish media type
        });
        _messageController.clear();
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

// Send message with media (image/video URL)
  void _sendMessageWithMedia(String fileUrl, String mediaType) async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty || fileUrl.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('chats').add({
          'senderId': currentUser!.uid,
          'receiverId': widget.otherUserId,
          'participants': [currentUser!.uid, widget.otherUserId],
          'message': message,
          'timestamp': Timestamp.now(),
          'postId': '',
          'mediaUrl': fileUrl, // Store media URL
          'mediaType': mediaType, // 'image' or 'video'
        });
        _messageController.clear();
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
}
