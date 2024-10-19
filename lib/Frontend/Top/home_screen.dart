import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Frontend/Home/Post/create_post.dart';
import 'package:l_f/Frontend/Home/Post/new.dart';
import 'package:l_f/Frontend/Home/home.dart';
import 'package:l_f/Frontend/Profile/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            title: Row(
              children: [
                // NIT Hamirpur logo
                Image.asset(
                  'assets/logo.png',
                  height: 40.0,
                  width: 40.0,
                ),
                const SizedBox(width: 6),
                // Website name "LOST&Found"
                const Text(
                  "LOST&Found",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: isMobile
                ? null
                : [
                    ResponsiveButton(
                      label: "Home",
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomePage()));
                      },
                    ),
                    ResponsiveButton(
                      label: "New Post",
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CreatePostPage()));
                      },
                    ),
                    ResponsiveButton(
                      label: "My List",
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => MessagesPage()));
                      },
                    ),
                    ResponsiveButton(
                      label: "Profile",
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfilePage()));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout,
                          color: Colors.white, size: 21),
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
          ),
          drawer: isMobile ? _buildDrawer(context) : null,
          body: isMobile
              ? const Center(child: LostFoundPage())
              : const Expanded(
                  flex: 5,
                  child: Center(
                    child: LostFoundPage(),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text("Home"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("New Post"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CreatePostPage()));
            },
          ),
          ListTile(
            title: const Text("My List"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => MessagesPage()));
            },
          ),
          ListTile(
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
          ListTile(
            title: const Text("Logout"),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepOrange,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 40.0,
                    width: 40.0,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'LOST&Found',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CreatePostPage()));
              },
            ),
            ListTile(
              title: const Text("My List"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => MessagesPage()));
              },
            ),
            ListTile(
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
            ),
            ListTile(
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
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
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _handleLogout(context);
                Navigator.of(context).pop();
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
