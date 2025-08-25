import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Backend/Reset_Password/reset_password.dart';
import 'package:l_f/Backend/SignUp/signup.dart';
import 'package:l_f/Frontend/Top/home_screen.dart';

// Login Page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationMessage;
  String? _domainErrorMessage;

  final String _expectedDomain = '@nith.ac.in';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _verificationMessage = null;
      _domainErrorMessage = null;
    });

    try {
      // Check if the email domain is correct
      if (!_emailController.text.trim().endsWith(_expectedDomain)) {
        setState(() {
          _domainErrorMessage =
              'Please log in with your college email address.';
        });
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Sign in user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Check if the email is verified
        if (!user.emailVerified) {
          setState(() {
            _verificationMessage =
                'Email is not verified. Please check your inbox.';
          });

          await user.sendEmailVerification();

          // Optionally log out the user if email is not verified
          await _auth.signOut();
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Check if user document exists in Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Show a message to the user if their data does not exist in Firestore
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User data not found'),
              backgroundColor: Colors.red,
            ),
          );

          // Optionally log out the user if document doesn't exist
          await _auth.signOut();
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.code == 'user-not-found'
            ? 'No user found for that email.'
            : e.code == 'wrong-password'
                ? 'Wrong password provided for that user.'
                : 'Failed to log in. Please try again.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> _login() async {
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //     _verificationMessage = null;
  //     _domainErrorMessage = null;
  //   });

  //   try {
  //     // Check if the email domain is correct
  //     if (!_emailController.text.trim().endsWith(_expectedDomain)) {
  //       setState(() {
  //         _domainErrorMessage =
  //             'Please log in with your college email address.';
  //       });
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       return;
  //     }

  //     // Sign in user
  //     UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );

  //     User? user = userCredential.user;

  //     if (user != null) {
  //       // Check if user document exists in Firestore
  //       DocumentSnapshot userDoc =
  //           await _firestore.collection('users').doc(user.uid).get();

  //       if (!userDoc.exists) {
  //         // Show a message to the user if their data does not exist in Firestore
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('User data not found'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );

  //         // Optionally log out the user if document doesn't exist
  //         await _auth.signOut();
  //         setState(() {
  //           _isLoading = false;
  //         });
  //         return;
  //       }

  //       // Navigate to HomePage (even if email is not verified)
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const HomePage()),
  //       );
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     setState(() {
  //       _errorMessage = e.code == 'user-not-found'
  //           ? 'No user found for that email.'
  //           : e.code == 'wrong-password'
  //               ? 'Wrong password provided for that user.'
  //               : 'Failed to log in. Please try again.';
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'An error occurred. Please try again.';
  //     });
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 630;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: isMobile ? size.width * 0.8 : size.width * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    if (_verificationMessage != null)
                      Text(
                        _verificationMessage!,
                        style:
                            const TextStyle(color: Colors.orange, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    if (_domainErrorMessage != null)
                      Text(
                        _domainErrorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: isMobile ? 0 : 16),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                    SizedBox(height: isMobile ? 0 : 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder: (_, __, ___) => const ResetPasswordPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) =>
                                const SignUpPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Don\'t have an account? Sign Up',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        filled: true,
        fillColor: Colors.white.withOpacity(1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
    );
  }
}
