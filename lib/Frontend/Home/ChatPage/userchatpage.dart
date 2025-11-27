import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:l_f/Frontend/Profile/user_see_page.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSkeleton extends StatelessWidget {
  const ShimmerSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.all(15),
        height: 80,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final String otherUserId;

  const ChatDetailPage({required this.otherUserId, super.key});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();

  // --- WEB-COMPATIBLE IMAGE PICKER & UPLOADER ---
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    // Read file bytes - this works on web
    final Uint8List fileBytes = await image.readAsBytes();
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef =
        FirebaseStorage.instance.ref().child('chats/$fileName');

    try {
      // Upload bytes to Firebase Storage
      UploadTask uploadTask = storageRef.putData(fileBytes);
      TaskSnapshot taskSnapshot = await uploadTask;
      String fileUrl = await taskSnapshot.ref.getDownloadURL();

      // Send the message with the new image URL
      _sendMessageWithMedia(fileUrl, 'image');
    } catch (e) {
      print("Error uploading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
    }
  }

  void _sendMessage(String message) async {
    if (message.isEmpty) return;

    await FirebaseFirestore.instance.collection('chats').add({
      'senderId': currentUser!.uid,
      'receiverId': widget.otherUserId,
      'participants': [currentUser!.uid, widget.otherUserId],
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'mediaUrl': '',
      'mediaType': '',
    });
    _messageController.clear();
    _scrollToBottom();
  }

  void _sendMessageWithMedia(String fileUrl, String mediaType) async {
    await FirebaseFirestore.instance.collection('chats').add({
      'senderId': currentUser!.uid,
      'receiverId': widget.otherUserId,
      'participants': [currentUser!.uid, widget.otherUserId],
      'message': _messageController.text.trim(), // Send text with image
      'timestamp': FieldValue.serverTimestamp(),
      'mediaUrl': fileUrl,
      'mediaType': mediaType,
    });
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(child: _buildChatMessages()),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text("Chat");
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String name = userData['name'] ?? 'User';
        String profileImage = userData['profileImage'] ?? '';
        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProfilePage2(uid: widget.otherUserId))),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                child: profileImage.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Text(name),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatMessages() {
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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Say hello!"));
        }

        var messages = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data['participants'].contains(widget.otherUserId);
        }).toList();

        if (messages.isEmpty) {
          return const Center(child: Text("No messages yet."));
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(8.0),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index].data() as Map<String, dynamic>;
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData) {
    final bool isMe = messageData['senderId'] == currentUser!.uid;
    final String messageText = messageData['message'] ?? '';
    final String mediaUrl = messageData['mediaUrl'] ?? '';
    final Timestamp? timestamp = messageData['timestamp'];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.deepOrange : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight:
                isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mediaUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(mediaUrl, width: 200),
              ),
            if (messageText.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: mediaUrl.isNotEmpty ? 8.0 : 0),
                child: Text(
                  messageText,
                  style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                ),
              ),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                DateFormat('hh:mm a').format(timestamp.toDate()),
                style: TextStyle(
                  fontSize: 10,
                  color: isMe ? Colors.white70 : Colors.black54,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.photo_camera, color: Colors.deepOrange),
              onPressed: _pickAndUploadImage,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: () => _sendMessage(_messageController.text.trim()),
              backgroundColor: Colors.deepOrange,
              elevation: 0,
              mini: true,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
