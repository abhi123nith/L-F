// // lib/Frontend/pages/profile_page.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:l_f/newCode/Frontend/components/profile_info_field.dart';
// import 'package:l_f/newCode/service/user_service.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final UserService _userService = UserService();
//   final User? currentUser = FirebaseAuth.instance.currentUser;

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _departmentController = TextEditingController();
//   final TextEditingController _degreeController = TextEditingController();
//   final TextEditingController _genderController = TextEditingController();
//   final TextEditingController _hostelController = TextEditingController();
//   final TextEditingController _yearController = TextEditingController();
//   final TextEditingController _joinedDateController = TextEditingController();

//   String? _profileImageUrl;
//   bool _isEditing = false;
//   bool _isLoading = true;
//   bool _isUpdatingProfile = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserDetails();
//   }

//   Future<void> _fetchUserDetails() async {
//     if (currentUser == null) {
//       setState(() => _isLoading = false);
//       return;
//     }

//     try {
//       final userData = await _userService.fetchUserData(currentUser!.uid);
//       if (userData != null) {
//         _nameController.text = userData['name'] ?? '';
//         _emailController.text = userData['email'] ?? '';
//         _phoneController.text = userData['phonenumber'] ?? '';
//         _departmentController.text = userData['department'] ?? 'NITH';
//         _degreeController.text = userData['degree'] ?? '';
//         _genderController.text = userData['gender'] ?? '';
//         _hostelController.text = userData['hostel'] ?? '';
//         _yearController.text = userData['year'] ?? '';
//         _joinedDateController.text =
//             (userData['joinedDate'] as Timestamp?)?.toDate().toString() ?? '';
//         _profileImageUrl = userData['profileImage'];
//       }
//     } catch (e) {
//       print('Error fetching user details: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _updateProfile() async {
//     setState(() => _isUpdatingProfile = true);

//     try {
//       final Map<String, dynamic> updatedData = {
//         'name': _nameController.text,
//         'phonenumber': _phoneController.text,
//         'profileImage': _profileImageUrl,
//         'hostel': _hostelController.text,
//         // Add other fields you want to update
//       };
//       await _userService.updateUserDetails(currentUser!.uid, updatedData);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.green,
//           content: Text('Profile updated successfully!'),
//         ),
//       );
//       setState(() => _isEditing = false);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.red,
//           content: Text('Failed to update profile: $e'),
//         ),
//       );
//     } finally {
//       setState(() => _isUpdatingProfile = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = MediaQuery.of(context).size.width < 830;
//     Size widthSc = MediaQuery.of(context).size;

//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Profile'),
//           backgroundColor: Colors.deepOrange,
//           foregroundColor: Colors.white,
//         ),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: Colors.deepOrange,
//         foregroundColor: Colors.white,
//         elevation: 4.0,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(
//           horizontal: isMobile ? 6 : widthSc.width * 0.3,
//           vertical: isMobile ? 12 : 20,
//         ),
//         child: Center(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15.0)),
//                 elevation: 8.0,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Stack(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               if (_profileImageUrl != null) {
//                                 // Logic to show full-screen image
//                               }
//                             },
//                             child: CircleAvatar(
//                               radius: 80.0,
//                               backgroundColor: Colors.grey[200],
//                               backgroundImage: _profileImageUrl != null
//                                   ? NetworkImage(_profileImageUrl!)
//                                   : null,
//                             ),
//                           ),
//                           if (_isEditing)
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: IconButton(
//                                 icon: const Icon(Icons.edit,
//                                     color: Colors.deepOrange),
//                                 onPressed: () async {
//                                   final imageBytes =
//                                       await _userService.pickSingleImage();
//                                   if (imageBytes != null) {
//                                     setState(() => _isUpdatingProfile = true);
//                                     final imageUrl = await _userService
//                                         .uploadProfileImage(imageBytes);
//                                     if (imageUrl != null) {
//                                       _profileImageUrl = imageUrl;
//                                       await _userService.updateUserDetails(
//                                           currentUser!.uid,
//                                           {'profileImage': imageUrl});
//                                       setState(() {});
//                                     }
//                                     setState(() => _isUpdatingProfile = false);
//                                   }
//                                 },
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 20.0),
//                       ProfileInfoField(
//                           label: "Name",
//                           controller: _nameController,
//                           isEditable: _isEditing),
//                       ProfileInfoField(
//                           label: "Email",
//                           controller:
//                               _emailController), // Email is non-editable
//                       ProfileInfoField(
//                           label: "Phone Number",
//                           controller: _phoneController,
//                           isEditable: _isEditing),
//                       ProfileInfoField(
//                           label: "Department",
//                           controller: _departmentController),
//                       ProfileInfoField(
//                           label: "Joined Date",
//                           controller: _joinedDateController),

//                       // Handle Dropdowns if needed
//                       // This part needs more custom logic if they are editable
//                       // For now, they are non-editable text fields.
//                       ProfileInfoField(
//                           label: "Degree", controller: _degreeController),
//                       ProfileInfoField(
//                           label: "Gender", controller: _genderController),
//                       ProfileInfoField(
//                           label: "Hostel", controller: _hostelController),
//                       ProfileInfoField(
//                           label: "Year", controller: _yearController),

//                       const SizedBox(height: 20.0),
//                       _isUpdatingProfile
//                           ? const CircularProgressIndicator()
//                           : ElevatedButton(
//                               onPressed: () {
//                                 if (_isEditing) {
//                                   _updateProfile();
//                                 } else {
//                                   setState(() => _isEditing = true);
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 30, vertical: 15),
//                                 backgroundColor: Colors.deepOrange,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(9),
//                                 ),
//                                 elevation: 6.0,
//                               ),
//                               child: Text(
//                                 _isEditing ? "Save Changes" : "Edit Profile",
//                                 style: const TextStyle(fontSize: 18),
//                               ),
//                             ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
