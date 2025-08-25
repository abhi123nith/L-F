// // lib/Frontend/pages/user_see_page.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:l_f/newCode/Frontend/components/user_profile_view.dart';
// import 'package:l_f/newCode/service/profile_service.dart';

// class UserSeePage extends StatefulWidget {
//   final String uid;
//   const UserSeePage({super.key, required this.uid});

//   @override
//   _UserSeePageState createState() => _UserSeePageState();
// }

// class _UserSeePageState extends State<UserSeePage> {
//   final ProfileService _profileService = ProfileService();
//   final User? currentUser = FirebaseAuth.instance.currentUser;

//   bool _isLoading = true;
//   bool _showPhoneNumber = false;
//   Map<String, dynamic>? _userData;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserDetails();
//   }

//   Future<void> _fetchUserDetails() async {
//     try {
//       _userData = await _profileService.fetchUserDetails(widget.uid);
//     } catch (e) {
//       print('Error fetching user details: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _togglePhoneNumber() async {
//     if (currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('You must be logged in to view contact details.')));
//       return;
//     }

//     if (await _profileService.canShowPhoneNumber(
//         widget.uid, currentUser!.uid)) {
//       setState(() => _showPhoneNumber = !_showPhoneNumber);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('You cannot view this phone number.')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Profile')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_userData == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Profile')),
//         body: const Center(child: Text('User not found')),
//       );
//     }

//     final TextEditingController nameController =
//         TextEditingController(text: _userData!['name'] ?? '');
//     final TextEditingController emailController =
//         TextEditingController(text: _userData!['email'] ?? '');
//     final TextEditingController phoneController = TextEditingController(
//         text: _showPhoneNumber
//             ? _userData!['phonenumber'] ?? ''
//             : '****-***-***');
//     final TextEditingController departmentController =
//         TextEditingController(text: _userData!['department'] ?? '');
//     final TextEditingController degreeController =
//         TextEditingController(text: _userData!['degree'] ?? '');
//     final TextEditingController genderController =
//         TextEditingController(text: _userData!['gender'] ?? '');
//     final TextEditingController hostelController =
//         TextEditingController(text: _userData!['hostel'] ?? '');
//     final TextEditingController yearController =
//         TextEditingController(text: _userData!['year'] ?? '');
//     final TextEditingController joinedDateController = TextEditingController(
//         text: (_userData!['joinedDate'] as Timestamp?)?.toDate().toString() ??
//             '');

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${_userData!['name'] ?? 'User'}\'s Profile'),
//         backgroundColor: Colors.deepOrange,
//         foregroundColor: Colors.white,
//         elevation: 4.0,
//       ),
//       body: UserProfileView(
//         profileImageUrl: _userData!['profileImage'],
//         nameController: nameController,
//         emailController: emailController,
//         phoneController: phoneController,
//         departmentController: departmentController,
//         degreeController: degreeController,
//         genderController: genderController,
//         hostelController: hostelController,
//         yearController: yearController,
//         joinedDateController: joinedDateController,
//         isEditable:
//             false, // This is the key difference from the user's own profile
//         showPhoneNumber: _showPhoneNumber,
//         onTogglePhoneNumber: _togglePhoneNumber,
//         onEditProfileImage: () {},
//         onSaveProfile: () {},
//         onEditPressed: () {},
//       ),
//     );
//   }
// }
