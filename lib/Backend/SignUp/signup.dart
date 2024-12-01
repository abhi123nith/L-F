import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Backend/Login/login.dart';
import 'package:l_f/Frontend/Contants/lists.dart';

//Sign Up PAGE
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  // Text controllers to retrieve input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedDegree;
  String? _selectedGender;
  String? _selectYear;
  String? _selectedHostel;
  String? _selectedDepartment;

  bool _isLoading = false;

  Future<void> _signUpUser() async {
    if (_formKey.currentState!.validate()) {
      // Check if the email domain is @nith.ac.in
      if (!_emailController.text.trim().endsWith('@nith.ac.in')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please use your college email id'),
            backgroundColor: Colors.deepOrange,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
      if (_phoneController.text.trim().length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Mobile Number'),
            backgroundColor: Colors.deepOrange,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with email and password
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        const userProfilePicUrl = 'https://avatar.iran.liara.run/public/24';

        // Send verification email
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
        }

        // Save user information to Firestore
        await _firestore.collection('users').doc(user!.uid).set({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': user.email,
          'joinedDate': DateTime.now(),
          'profileImage': userProfilePicUrl,
          'phonenumber': _phoneController.text.trim(),
          'gender': _selectedGender,
          'degree': _selectedDegree,
          'hostel': _selectedHostel,
          'year': _selectYear,
          'department': _selectedDepartment,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email has been sent.'),
            backgroundColor: Colors.deepOrange,
            duration: Duration(seconds: 5),
          ),
        );

        // Redirect to login page
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginPage()));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 830;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isMobile ? 30 : 0),
                      const Text(
                        'Create an Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: isMobile ? 17 : 32),
                      Container(
                        width: isMobile ? size.width * 0.8 : size.width * 0.6,
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
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                labelText: 'Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            _buildTextFormField(
                                emailController: _emailController),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),
                            DropdownButtonFormField<String>(
                              value: _selectedDegree,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                labelText: 'Degree',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                              ),
                              items: degreesList.map((String degree) {
                                return DropdownMenuItem<String>(
                                  value: degree,
                                  child: Text(degree),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedDegree = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select your degree';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedDepartment,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                labelText: 'Department',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                              ),
                              items: departmentList.map((String deptartment) {
                                return DropdownMenuItem<String>(
                                  value: deptartment,
                                  child: Text(deptartment),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedDepartment = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select your department';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_selectedDegree != 'PhD')
                              DropdownButtonFormField<String>(
                                value: _selectYear,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.2),
                                  labelText: 'Year',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                ),
                                items: _selectedDegree == 'MSc' ||
                                        _selectedDegree == 'MTech'
                                    ? mscMtechList.map((String year) {
                                        return DropdownMenuItem<String>(
                                          value: year,
                                          child: Text(year),
                                        );
                                      }).toList()
                                    : btechyearsList.map((String year) {
                                        return DropdownMenuItem<String>(
                                          value: year,
                                          child: Text(year),
                                        );
                                      }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectYear = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select your year';
                                  }
                                  return null;
                                },
                              ),
                            const SizedBox(height: 16),

                            // Gender Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                labelText: 'Gender',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                              ),
                              items: ['Male', 'Female'].map((String gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(gender),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                  _selectedHostel =
                                      null; // Reset hostel selection when gender changes
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select your gender';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Hostel Dropdown (conditional based on gender)
                            DropdownButtonFormField<String>(
                              value: _selectedHostel,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                labelText: 'Hostel',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                              ),
                              items: (_selectedGender == 'Female'
                                      ? girlshostelsList
                                      : boyshostelsList)
                                  .map((String hostel) {
                                return DropdownMenuItem<String>(
                                  value: hostel,
                                  child: Text(hostel),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedHostel = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select your hostel';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Sign-Up Button
                            Center(
                              child: ElevatedButton(
                                onPressed: _signUpUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginPage()));
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Sign In ',
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _buildTextFormField extends StatelessWidget {
  const _buildTextFormField({
    super.key,
    required TextEditingController emailController,
  }) : _emailController = emailController;

  final TextEditingController _emailController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        labelText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: const TextStyle(color: Colors.black),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }
}
