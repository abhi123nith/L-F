import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage2 extends StatefulWidget {
  final String uid;
  const ProfilePage2({super.key, required this.uid});

  @override
  _ProfilePage2State createState() => _ProfilePage2State();
}

class _ProfilePage2State extends State<ProfilePage2> {
  String? _nameController;
  String? _emailController;
  String? _phoneController;
  String? _rollController;
  String? _branchController;
  String? _degreeController;
  String? _gendercontroller;

  String? year;
  String? hostel;
  String? degree;
  String? rollNumber;
  String? gender;
  String? department;
  String? profileImageUrl;

  bool _showPhoneNumber = false;
  late Future<Map<String, dynamic>?> _userDetails;

  @override
  void initState() {
    super.initState();
    _userDetails = getUserDetails(widget.uid).then((data) {
      if (data != null) {
        _nameController = data['name'] ?? '';
        _emailController = data['email'] ?? '';
        _phoneController = data['phonenumber'] ?? '';
        _rollController = data['rollNumber'] ?? '12345678';
        _branchController = data['department'] + ' Department' ?? 'NITH';
        profileImageUrl = data['profileImage'];
        year = data['year'] ?? 'NITH';
        hostel = data['hostel'] ?? 'NITH';
        gender = data['gender'];
        department = data['department'];
        degree = data['degree'];
        _degreeController = data['degree'];
        _gendercontroller = data['gender'];
      }
      return data;
    });
  }

  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<bool> _canShowPhoneNumber() async {
    // Replace 'claimCollection' with the actual name of your collection
    QuerySnapshot claims = await FirebaseFirestore.instance
        .collection('posts')
        .where('postClaimer', isEqualTo: widget.uid)
        .where('isClaimed', isEqualTo: true)
        .get();

    return claims.docs.isNotEmpty;
  }

  void _togglePhoneNumber() async {
    if (await _canShowPhoneNumber()) {
      setState(() {
        _showPhoneNumber = !_showPhoneNumber;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot view this phone number.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 830;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 4.0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User not found'));
          }

          // When data is fetched successfully
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: SizedBox(
                width: isMobile ? size.width : 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCard(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (profileImageUrl != null) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Stack(
                                            children: [
                                              Image.network(profileImageUrl!),
                                              Positioned(
                                                right: 10,
                                                top: 10,
                                                child: IconButton(
                                                  icon: const Icon(Icons.cancel,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 80.0,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(profileImageUrl!)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          _buildNonEditableEmailField(
                              "Name", _nameController!, false),
                          _buildNonEditableEmailField(
                              "Email", _emailController!, false),
                          _buildNonEditableEmailField("Phone Number",
                              _phoneController!, !_showPhoneNumber),
                          ElevatedButton(
                            onPressed: _togglePhoneNumber,
                            child: Text(_showPhoneNumber
                                ? 'Hide Number'
                                : 'Show Number'),
                          ),
                          _buildNonEditableEmailField(
                              "Department", _branchController!, false),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                elevation: 3,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      child: Text(
                                        hostel!,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 3,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      child: Text(
                                        year!,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 3,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      child: Text(
                                        degree!,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 8.0,
      shadowColor: Colors.grey[400],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildNonEditableEmailField(
      String label, String value, bool isVisible) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          enabled: false,
          obscureText: isVisible,
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
