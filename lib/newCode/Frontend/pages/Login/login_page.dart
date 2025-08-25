// // lib/Frontend/pages/login_page.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:l_f/newCode/Backend/auth_service.dart';
// import 'package:l_f/newCode/Backend/validator.dart';
// import 'package:l_f/newCode/Frontend/components/custom_text_field.dart';
// import 'package:l_f/newCode/Frontend/pages/HomeScreen/home_screen.dart';
// import 'package:l_f/newCode/Frontend/pages/resetPassword/reset_password_page.dart';
// import 'package:l_f/newCode/Frontend/pages/signup/signup_page.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();

//   bool _isLoading = false;
//   String? _errorMessage;
//   final String _expectedDomain = '@nith.ac.in';

//   Future<void> _login() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     if (!Validator.isValidCollegeEmail(
//         _emailController.text, _expectedDomain)) {
//       setState(() {
//         _errorMessage = 'Please log in with your college email address.';
//         _isLoading = false;
//       });
//       return;
//     }

//     try {
//       User? user = await _authService.signInWithEmailAndPassword(
//         _emailController.text,
//         _passwordController.text,
//       );

//       if (user != null) {
//         if (!user.emailVerified) {
//           _authService.sendEmailVerification();
//           await _authService.signOut();
//           setState(() {
//             _errorMessage =
//                 'Email not verified. A new verification link has been sent.';
//           });
//         } else {
//           bool userExists = await _authService.doesUserExist(user.uid);
//           if (userExists) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const HomePage()),
//             );
//           } else {
//             await _authService.signOut();
//             setState(() {
//               _errorMessage = 'User data not found. Please contact support.';
//             });
//           }
//         }
//       }
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         _errorMessage = _mapFirebaseAuthException(e.code);
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'An unexpected error occurred. Please try again.';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   String _mapFirebaseAuthException(String code) {
//     switch (code) {
//       case 'user-not-found':
//         return 'No user found for that email.';
//       case 'wrong-password':
//         return 'Wrong password provided.';
//       default:
//         return 'Failed to log in. Please try again.';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = MediaQuery.of(context).size.width < 630;
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 16),
//               const Text(
//                 'Welcome Back!',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Container(
//                 width: isMobile ? size.width * 0.8 : size.width * 0.5,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     CustomTextField(
//                       controller: _emailController,
//                       label: 'Email',
//                       icon: Icons.email,
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (value) =>
//                           value!.isEmpty ? 'Please enter your email' : null,
//                     ),
//                     const SizedBox(height: 16),
//                     CustomTextField(
//                       controller: _passwordController,
//                       label: 'Password',
//                       icon: Icons.lock,
//                       obscureText: true,
//                       validator: (value) => value!.isEmpty || value.length < 6
//                           ? 'Password must be at least 6 characters'
//                           : null,
//                     ),
//                     const SizedBox(height: 16),
//                     if (_errorMessage != null)
//                       Text(
//                         _errorMessage!,
//                         style: const TextStyle(color: Colors.red, fontSize: 16),
//                         textAlign: TextAlign.center,
//                       ),
//                     const SizedBox(height: 16),
//                     _isLoading
//                         ? const CircularProgressIndicator()
//                         : ElevatedButton(
//                             onPressed: _login,
//                             child: const Text('Login'),
//                           ),
//                     const SizedBox(height: 16),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => const ResetPasswordPage()),
//                         );
//                       },
//                       child: const Text(
//                         'Forgot Password?',
//                         style: TextStyle(
//                           decoration: TextDecoration.underline,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => const SignUpPage()),
//                         );
//                       },
//                       child: const Text(
//                         'Don\'t have an account? Sign Up',
//                         style: TextStyle(
//                           decoration: TextDecoration.underline,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
