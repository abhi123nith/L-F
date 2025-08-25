// // lib/Frontend/pages/signup_page.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:l_f/newCode/Backend/auth_service.dart';
// import 'package:l_f/newCode/Backend/validator.dart';
// import 'package:l_f/newCode/Frontend/components/custom_dropdown_field.dart';
// import 'package:l_f/newCode/Frontend/components/custom_text_field.dart';
// import 'package:l_f/newCode/Frontend/pages/Login/login_page.dart';

// // Assuming you have a file for these constants.
// const List<String> degreesList = ['B.Tech', 'M.Tech', 'MSc', 'PhD'];
// const List<String> departmentList = ['CS', 'EE', 'ME'];
// const List<String> btechyearsList = [
//   '1st Year',
//   '2nd Year',
//   '3rd Year',
//   '4th Year'
// ];
// const List<String> mscMtechList = ['1st Year', '2nd Year'];
// const List<String> girlshostelsList = ['G-1', 'G-2'];
// const List<String> boyshostelsList = ['B-1', 'B-2', 'B-3'];

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final _formKey = GlobalKey<FormState>();
//   final AuthService _authService = AuthService();

//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();

//   String? _selectedDegree;
//   String? _selectedGender;
//   String? _selectYear;
//   String? _selectedHostel;
//   String? _selectedDepartment;

//   bool _isLoading = false;
//   final String _expectedDomain = '@nith.ac.in';

//   Future<void> _signUpUser() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (!Validator.isValidCollegeEmail(
//         _emailController.text, _expectedDomain)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please use your college email address.'),
//           backgroundColor: Colors.deepOrange,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final userData = {
//         'name': _nameController.text.trim(),
//         'email': _emailController.text.trim(),
//         'joinedDate': DateTime.now().toIso8601String(),
//         'profileImage': 'https://avatar.iran.liara.run/public/24',
//         'phoneNumber': _phoneController.text.trim(),
//         'gender': _selectedGender,
//         'degree': _selectedDegree,
//         'hostel': _selectedHostel,
//         'year': _selectYear,
//         'department': _selectedDepartment,
//       };

//       await _authService.signUpUser(
//         email: _emailController.text,
//         password: _passwordController.text,
//         userData: userData,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//               'Verification email has been sent. Please check your inbox.'),
//           backgroundColor: Colors.deepOrange,
//         ),
//       );

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//       );
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.message}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = MediaQuery.of(context).size.width < 830;
//     Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Create an Account',
//                         style: TextStyle(
//                             fontSize: 32, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 32),
//                       Container(
//                         width: isMobile ? size.width * 0.8 : size.width * 0.6,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           children: [
//                             CustomTextField(
//                               controller: _nameController,
//                               label: 'Name',
//                               icon: Icons.person,
//                               validator: (value) => value!.isEmpty
//                                   ? 'Please enter your name'
//                                   : null,
//                             ),
//                             const SizedBox(height: 16),
//                             CustomTextField(
//                               controller: _emailController,
//                               label: 'Email',
//                               icon: Icons.email,
//                               keyboardType: TextInputType.emailAddress,
//                               validator: (value) => value!.isEmpty
//                                   ? 'Please enter your email'
//                                   : null,
//                             ),
//                             const SizedBox(height: 16),
//                             CustomTextField(
//                               controller: _phoneController,
//                               label: 'Phone Number',
//                               icon: Icons.phone,
//                               keyboardType: TextInputType.phone,
//                               validator: (value) =>
//                                   value!.isEmpty || value.length < 10
//                                       ? 'Invalid phone number'
//                                       : null,
//                             ),
//                             const SizedBox(height: 16),
//                             CustomTextField(
//                               controller: _passwordController,
//                               label: 'Password',
//                               icon: Icons.lock,
//                               obscureText: true,
//                               validator: (value) =>
//                                   value!.isEmpty || value.length < 6
//                                       ? 'Password must be at least 6 characters'
//                                       : null,
//                             ),
//                             const SizedBox(height: 22),
//                             CustomDropdownField<String>(
//                               label: 'Degree',
//                               value: _selectedDegree,
//                               items: degreesList,
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedDegree = newValue;
//                                 });
//                               },
//                               validator: (value) => value == null
//                                   ? 'Please select your degree'
//                                   : null,
//                             ),
//                             const SizedBox(height: 16),
//                             CustomDropdownField<String>(
//                               label: 'Department',
//                               value: _selectedDepartment,
//                               items: departmentList,
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedDepartment = newValue;
//                                 });
//                               },
//                               validator: (value) => value == null
//                                   ? 'Please select your department'
//                                   : null,
//                             ),
//                             const SizedBox(height: 16),
//                             if (_selectedDegree != 'PhD')
//                               CustomDropdownField<String>(
//                                 label: 'Year',
//                                 value: _selectYear,
//                                 items: _selectedDegree == 'MSc' ||
//                                         _selectedDegree == 'MTech'
//                                     ? mscMtechList
//                                     : btechyearsList,
//                                 onChanged: (newValue) {
//                                   setState(() {
//                                     _selectYear = newValue;
//                                   });
//                                 },
//                                 validator: (value) => value == null
//                                     ? 'Please select your year'
//                                     : null,
//                               ),
//                             const SizedBox(height: 16),
//                             CustomDropdownField<String>(
//                               label: 'Gender',
//                               value: _selectedGender,
//                               items: const ['Male', 'Female'],
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedGender = newValue;
//                                   _selectedHostel = null;
//                                 });
//                               },
//                               validator: (value) => value == null
//                                   ? 'Please select your gender'
//                                   : null,
//                             ),
//                             const SizedBox(height: 16),
//                             CustomDropdownField<String>(
//                               label: 'Hostel',
//                               value: _selectedHostel,
//                               items: _selectedGender == 'Female'
//                                   ? girlshostelsList
//                                   : boyshostelsList,
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedHostel = newValue;
//                                 });
//                               },
//                               validator: (value) => value == null
//                                   ? 'Please select your hostel'
//                                   : null,
//                             ),
//                             const SizedBox(height: 32),
//                             ElevatedButton(
//                               onPressed: _signUpUser,
//                               child: const Text('Sign Up'),
//                             ),
//                             const SizedBox(height: 16),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (_) => const LoginPage()),
//                                 );
//                               },
//                               child: const Text(
//                                 'Already have an account? Sign In',
//                                 style: TextStyle(
//                                   decoration: TextDecoration.underline,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }
