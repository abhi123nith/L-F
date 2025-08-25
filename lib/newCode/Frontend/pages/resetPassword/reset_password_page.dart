// // lib/Frontend/pages/reset_password_page.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:l_f/newCode/Backend/auth_service.dart';
// import 'package:l_f/newCode/Frontend/components/custom_text_field.dart';

// class ResetPasswordPage extends StatefulWidget {
//   const ResetPasswordPage({super.key});

//   @override
//   _ResetPasswordPageState createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final _emailController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   final AuthService _authService = AuthService();
//   bool _isLoading = false;
//   String? _errorMessage;

//   Future<void> _resetPassword() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       try {
//         await _authService.sendPasswordResetEmail(_emailController.text);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Password reset email sent. Check your inbox.'),
//             backgroundColor: Colors.deepOrange,
//           ),
//         );
//       } on FirebaseAuthException catch (e) {
//         setState(() {
//           _errorMessage = e.message;
//         });
//       } catch (e) {
//         setState(() {
//           _errorMessage = 'An unexpected error occurred.';
//         });
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = MediaQuery.of(context).size.width < 830;
//     Size size = MediaQuery.of(context).size;
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reset Password'),
//         backgroundColor: Colors.deepOrange,
//         foregroundColor: Colors.white,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Reset Password',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: isMobile ? 10 : 20),
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: isMobile ? size.width * 0.1 : size.width * 0.3),
//                       child: Center(
//                         child: CustomTextField(
//                           controller: _emailController,
//                           label: 'Email',
//                           icon: Icons.email,
//                           keyboardType: TextInputType.emailAddress,
//                           validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _resetPassword,
//                       child: const Text('Send Reset Link'),
//                     ),
//                     if (_errorMessage != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 16.0),
//                         child: Text(
//                           _errorMessage!,
//                           style: const TextStyle(color: Colors.red),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }
