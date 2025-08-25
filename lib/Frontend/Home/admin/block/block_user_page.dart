import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Frontend/Profile/user_see_page.dart'; // Import the profile page

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  Future<void> _unblockUser(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'warningCount': 1, // Reset warning count to 1 instead of 0
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User has been unblocked."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error unblocking user: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- NEW: Method to navigate to the user's profile ---
  void _viewUserProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage2(uid: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Blocked Users"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('warningCount', isGreaterThanOrEqualTo: 2)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No users are currently blocked. ✅",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final blockedUsers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final userDoc = blockedUsers[index];
              final userData = userDoc.data() as Map<String, dynamic>;
              final profileImageUrl = userData['profileImage'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                // --- CHANGE IS HERE: The ListTile is now tappable ---
                child: ListTile(
                  onTap: () => _viewUserProfile(context, userDoc.id),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  title: Text(userData['name'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(userData['email'] ?? 'No Email'),
                  trailing: ElevatedButton(
                    onPressed: () => _unblockUser(context, userDoc.id),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Unblock'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
