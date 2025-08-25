// // lib/Frontend/components/user_profile_view.dart
// import 'package:flutter/material.dart';
// import 'package:l_f/newCode/Frontend/components/profile_info_field.dart';

// /// A reusable component to display a user's profile information.
// /// It can be set to editable for the current user's profile.
// class UserProfileView extends StatelessWidget {
//   final String? profileImageUrl;
//   final TextEditingController nameController;
//   final TextEditingController emailController;
//   final TextEditingController phoneController;
//   final TextEditingController departmentController;
//   final TextEditingController degreeController;
//   final TextEditingController genderController;
//   final TextEditingController hostelController;
//   final TextEditingController yearController;
//   final TextEditingController joinedDateController;
//   final bool isEditable;
//   final bool isUpdatingProfile;
//   final bool showPhoneNumber;
//   final VoidCallback onEditProfileImage;
//   final VoidCallback onTogglePhoneNumber;
//   final VoidCallback onSaveProfile;
//   final VoidCallback onEditPressed;

//   const UserProfileView({
//     super.key,
//     this.profileImageUrl,
//     required this.nameController,
//     required this.emailController,
//     required this.phoneController,
//     required this.departmentController,
//     required this.degreeController,
//     required this.genderController,
//     required this.hostelController,
//     required this.yearController,
//     required this.joinedDateController,
//     this.isEditable = false,
//     this.isUpdatingProfile = false,
//     this.showPhoneNumber = false,
//     required this.onEditProfileImage,
//     required this.onTogglePhoneNumber,
//     required this.onSaveProfile,
//     required this.onEditPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = MediaQuery.of(context).size.width < 830;
//     Size widthSc = MediaQuery.of(context).size;

//     return SingleChildScrollView(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 6 : widthSc.width * 0.3,
//         vertical: isMobile ? 12 : 20,
//       ),
//       child: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Card(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.0)),
//               elevation: 8.0,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Stack(
//                       children: [
//                         CircleAvatar(
//                           radius: 80.0,
//                           backgroundColor: Colors.grey[200],
//                           backgroundImage: profileImageUrl != null
//                               ? NetworkImage(profileImageUrl!)
//                               : null,
//                         ),
//                         if (isEditable)
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: IconButton(
//                               icon: const Icon(Icons.edit,
//                                   color: Colors.deepOrange),
//                               onPressed: onEditProfileImage,
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 20.0),
//                     ProfileInfoField(
//                         label: "Name",
//                         controller: nameController,
//                         isEditable: isEditable),
//                     ProfileInfoField(
//                         label: "Email", controller: emailController),
//                     ProfileInfoField(
//                       label: "Phone Number",
//                       controller: phoneController,
//                       isEditable: isEditable,
//                     ),
//                     if (!isEditable)
//                       ElevatedButton(
//                         onPressed: onTogglePhoneNumber,
//                         child: Text(
//                             showPhoneNumber ? 'Hide Number' : 'Show Number'),
//                       ),
//                     ProfileInfoField(
//                         label: "Department", controller: departmentController),
//                     ProfileInfoField(
//                         label: "Degree", controller: degreeController),
//                     ProfileInfoField(
//                         label: "Gender", controller: genderController),
//                     ProfileInfoField(
//                         label: "Hostel", controller: hostelController),
//                     ProfileInfoField(label: "Year", controller: yearController),
//                     ProfileInfoField(
//                         label: "Joined Date", controller: joinedDateController),
//                     const SizedBox(height: 20.0),
//                     if (isEditable)
//                       isUpdatingProfile
//                           ? const CircularProgressIndicator()
//                           : ElevatedButton(
//                               onPressed: onSaveProfile,
//                               child: const Text("Save Changes"),
//                             )
//                     else
//                       ElevatedButton(
//                         onPressed: onEditPressed,
//                         child: const Text("Edit Profile"),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
