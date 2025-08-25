import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Frontend/Home/ChatPage/userchatpage.dart';
import 'package:l_f/Frontend/Home/Post/post_model.dart'; // Adjust these imports
import 'package:l_f/Frontend/Home/admin/report/pst_card.dart';

// Placeholder for your actual chat page
class ChatPage extends StatelessWidget {
  final String receiverId;
  final String receiverName;
  const ChatPage(
      {super.key, required this.receiverId, required this.receiverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with $receiverName')),
      body: Center(child: Text('Chatting with user ID: $receiverId')),
    );
  }
}

class ProfilePage2 extends StatefulWidget {
  final String uid;
  const ProfilePage2({super.key, required this.uid});

  @override
  _ProfilePage2State createState() => _ProfilePage2State();
}

class _ProfilePage2State extends State<ProfilePage2> {
  late Future<Map<String, dynamic>> _profileDataFuture;
  bool _showPhoneNumber = false;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData();
  }

  // Reusable method for smooth page transitions
  Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var slideAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  // Fetches all user data and post counts in a single operation
  Future<Map<String, dynamic>> _fetchProfileData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    if (!userDoc.exists) {
      throw Exception('User not found');
    }

    final userData = userDoc.data()!;

    // Fetch post count
    final postQuery = await FirebaseFirestore.instance
        .collection('posts')
        .where('postmakerId', isEqualTo: widget.uid)
        .get();

    userData['postCount'] = postQuery.docs.length;

    return userData;
  }

  // --- Logic for showing/hiding the phone number ---

  Future<bool> _canShowPhoneNumber() async {
    // This is a placeholder for your actual logic.
    // For example, check if the current user has claimed an item from this user.
    // Replace with your actual implementation.
    // For now, it's set to 'false' for demonstration.
    return false;
  }

  void _togglePhoneNumber() async {
    if (await _canShowPhoneNumber()) {
      setState(() {
        _showPhoneNumber = !_showPhoneNumber;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('You do not have permission to view this phone number.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('User not found'));
          }

          final userData = snapshot.data!;
          final profileImageUrl = userData['profileImage'] ?? '';
          final warningCount = userData['warningCount'] ?? 0;
          final bool isBlocked = warningCount >= 2;
          final bool isAdmin = userData['email'] == '22bcs007@nith.ac.in';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Main Profile Header ---
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData['name'] ?? 'No Name',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userData['email'] ?? 'No Email',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),

                  // --- Status Indicators (Admin or Blocked) ---
                  if (isAdmin) ...[
                    const SizedBox(height: 8),
                    const Chip(
                      label: Text('ADMIN'),
                      backgroundColor: Colors.indigo,
                      labelStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      avatar: Icon(Icons.shield, color: Colors.white),
                    ),
                  ] else if (isBlocked) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: const Text('BLOCKED'),
                      backgroundColor: Colors.red.shade700,
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      avatar:
                          const Icon(Icons.block_flipped, color: Colors.white),
                    ),
                  ],

                  // --- NEW: Chat Button ---
                  if (currentUser != null && currentUser.uid != widget.uid) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(_createSmoothRoute(
                            ChatDetailPage(otherUserId: widget.uid)));
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Chat with this User'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    )
                  ],

                  const SizedBox(height: 24),

                  // --- User Statistics ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        icon: Icons.post_add,
                        label: 'Posts Made',
                        value: (userData['postCount'] ?? 0).toString(),
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.warning_amber,
                        label: 'Warnings',
                        value: warningCount.toString(),
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.report_problem_outlined,
                        label: 'False Reports',
                        value: (userData['falseReportCount'] ?? 0).toString(),
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Detailed Information Boxes ---
                  _buildInfoBox(
                    icon: Icons.badge_outlined,
                    title: 'Roll Number',
                    subtitle: userData['rollNumber'] ?? 'Not Provided',
                  ),
                  _buildInfoBox(
                    icon: Icons.school_outlined,
                    title: 'Department',
                    subtitle: userData['department'] ?? 'Not Provided',
                  ),
                  _buildInfoBox(
                    icon: Icons.hotel_outlined,
                    title: 'Hostel',
                    subtitle: userData['hostel'] ?? 'Not Provided',
                  ),
                  _buildInfoBox(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    subtitle: _showPhoneNumber
                        ? (userData['phonenumber'] ?? 'Not Provided')
                        : '**********',
                    trailing: IconButton(
                      icon: Icon(_showPhoneNumber
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: _togglePhoneNumber,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- User's Posts Section ---
                  const Text(
                    "User's Posts",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(thickness: 1.5),
                  _buildUserPostsList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Reusable Widgets ---

  Widget _buildStatCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(
      {required IconData icon,
      required String title,
      required String subtitle,
      Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.deepOrange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
        trailing: trailing,
      ),
    );
  }

  Widget _buildUserPostsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('postmakerId', isEqualTo: widget.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: Text("This user has not made any posts yet.")),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final postDoc = snapshot.data!.docs[index];
            final postModel =
                PostModel.fromJson(postDoc.data() as Map<String, dynamic>);

            return PostCard(
              post: postModel,
              isOwner: false,
              onDelete: () {},
              onReport: () {},
            );
          },
        );
      },
    );
  }
}
