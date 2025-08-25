import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Frontend/Home/Post/create_post.dart';
import 'package:l_f/Frontend/Home/Post/new.dart';
import 'package:l_f/Frontend/Home/admin/block/block_user_page.dart';
import 'package:l_f/Frontend/Home/admin/report/admin_reports_page.dart';
import 'package:l_f/Frontend/Home/home.dart';
import 'package:l_f/Frontend/Profile/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        return FadeTransition(
          opacity: animation,
          child:
              SlideTransition(position: animation.drive(tween), child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  // Method to check user status before navigating to the create post page
  Future<void> _navigateToCreatePost(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        messenger.showSnackBar(
            const SnackBar(content: Text("Could not find user data.")));
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final warningCount = userData['warningCount'] ?? 0;

      if (warningCount >= 2) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text(
                "You are blocked from creating new posts due to multiple warnings."),
            backgroundColor: Colors.red.shade700,
          ),
        );
      } else {
        navigator.push(_createSmoothRoute(const CreatePostPage()));
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("Error checking user status: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    const adminEmail = '22bcs007@nith.ac.in';

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 700;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            title: isMobile
                ? Row(children: [
                    Image.asset('assets/lg.png', height: 75, width: 75)
                  ])
                : Row(children: [
                    const SizedBox(width: 16),
                    Image.asset('assets/lg.png', height: 75, width: 75),
                    const SizedBox(width: 16),
                    const Text("CampusTracker"),
                  ]),
            actions: isMobile
                ? [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _navigateToCreatePost(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.messenger_outline_rounded),
                      onPressed: () => Navigator.push(
                          context, _createSmoothRoute(MessagesPage())),
                    ),
                  ]
                : [
                    ResponsiveButton(label: "Home", onPressed: () {}),
                    ResponsiveButton(
                      label: "New Post",
                      onPressed: () => _navigateToCreatePost(context),
                    ),
                    ResponsiveButton(
                      label: "My Chats",
                      onPressed: () => Navigator.push(
                          context, _createSmoothRoute(MessagesPage())),
                    ),
                    ResponsiveButton(
                      label: "Profile",
                      onPressed: () => Navigator.push(
                          context, _createSmoothRoute(const ProfilePage())),
                    ),
                    if (currentUser?.email == adminEmail)
                      ResponsiveButton(
                        label: "Admin",
                        onPressed: () => Navigator.push(context,
                            _createSmoothRoute(const AdminReportsPage())),
                      ),
                    if (currentUser?.email == adminEmail)
                      ResponsiveButton(
                        label: "User Management",
                        onPressed: () => Navigator.push(context,
                            _createSmoothRoute(const BlockedUsersPage())),
                      ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => _showLogoutDialog(context),
                    ),
                  ],
          ),
          drawer: isMobile ? _buildDrawer(context, currentUser) : null,
          body: const LostFoundPage(),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, User? currentUser) {
    const adminEmail = '22bcs007@nith.ac.in';
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            color: Colors.deepOrange,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 16.0),
              child: Row(
                children: [
                  Image.asset('assets/logo2.png', height: 60.0, width: 60.0),
                  const SizedBox(width: 16),
                  const Text(
                    'CampusTracker',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: const Text("Home"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text("New Post"),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCreatePost(context);
                  },
                ),
                ListTile(
                  title: const Text("My List"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, _createSmoothRoute(MessagesPage()));
                  },
                ),
                ListTile(
                  title: const Text("Profile"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context, _createSmoothRoute(const ProfilePage()));
                  },
                ),
                if (currentUser?.email == adminEmail)
                  ListTile(
                    title: const Text("Admin Reports"),
                    leading: const Icon(Icons.security),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          _createSmoothRoute(const AdminReportsPage()));
                    },
                  ),
                if (currentUser?.email == adminEmail)
                  ListTile(
                    title: const Text("User Management"),
                    leading: const Icon(Icons.block_sharp),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          _createSmoothRoute(const BlockedUsersPage()));
                    },
                  ),
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              color: Colors.deepOrange,
              padding: const EdgeInsets.all(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Logout",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.logout, color: Colors.white),
                ],
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.grey,
            content: Text('Error signing out: $e')),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?",
              style: TextStyle(fontWeight: FontWeight.w700)),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Logout",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class ResponsiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ResponsiveButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
