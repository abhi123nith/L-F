import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:l_f/Frontend/Contants/lists.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Uint8List>? _imageBytes;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _gendercontroller = TextEditingController();

  String? year;
  String? hostel;
  String? degree;
  String? rollNumber;
  String? gender;
  String? department;
  String? joinedDate;

  final List<String> btechyears = btechyearsList;
  final List<String> mtecmscyear = mscMtechList;
  final List<String> boyshostels = boyshostelsList;
  final List<String> girlshostels = girlshostelsList;

  String? profileImageUrl;
  late Future<Map<String, dynamic>?> _userDetails;
  bool isEditing = false;
  bool isLoading = true;
  bool isUploadingImage = false;
  bool isUpdatingProfile = false;

  @override
  void initState() {
    super.initState();
    _userDetails = getUserDetails().then((data) {
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phonenumber'] ?? '';
        _rollController.text = data['rollNumber'] ?? '12345678';
        _branchController.text = (data['department'] ?? 'NITH') + ' Department';
        profileImageUrl = data['profileImage'];
        year = data['year'] ?? 'NITH';
        hostel = data['hostel'] ?? 'NITH';
        joinedDate = _formatDate(data['joinedDate']);
        gender = data['gender'];
        department = data['department'];
        degree = data['degree'];
        _degreeController.text = data['degree'] ?? '';
        _gendercontroller.text = data['gender'] ?? '';
      }
      setState(() {
        isLoading = false;
      });
      return data;
    });
  }

  Future<void> _uploadProfileImage(Uint8List data) async {
    setState(() {
      isUploadingImage = true;
    });
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'profileImages/${DateTime.now().toIso8601String()}'); // Use ISO format for better readability
      final uploadTask = storageRef.putData(data);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        profileImageUrl = downloadUrl; // Save the URL instead of the raw bytes
        isUploadingImage = false;
      });
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        isUploadingImage = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        // Use FilePicker for web
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.image,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          if (file.bytes != null) {
            await _uploadProfileImage(file.bytes!);
          }
        }
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery, // Use gallery to select an image
        );

        if (pickedFile != null) {
          final Uint8List fileBytes = await pickedFile.readAsBytes();
          await _uploadProfileImage(fileBytes); // Upload the selected image
        }
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _updateUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        isUpdatingProfile = true;
      });
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'phonenumber': _phoneController.text,
          'profileImage': profileImageUrl, // Use the URL of the uploaded image
          'hostel': hostel,
        });

        setState(() {
          isEditing = false;
          isUpdatingProfile = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        print('Error updating profile: $e');
        setState(() {
          isUpdatingProfile = false;
        });
      }
    } else {
      // Handle case where user is not logged in
      print('No user logged in.');
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMMM yyyy').format(date);
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 830;
    Size widthSc = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 4.0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : widthSc.width * 0.3,
                  vertical: isMobile ? 12 : 20),
              child: Center(
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
                              if (isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4.0,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.deepOrange),
                                      onPressed: () {
                                        _pickImage();
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          _buildEditableField("Name", _nameController),
                          _buildNonEditableEmailField(
                              "Email", _emailController),
                          _buildEditableField("Phone Number", _phoneController),
                          _buildNonEditableEmailField(
                              "Department", _branchController),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isEditing == false)
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
                                    )),
                                  )),
                                ),
                              if (_degreeController.text != 'PhD')
                                isEditing
                                    ? DropdownButton<String>(
                                        value: year,
                                        hint: const Text('Select Year'),
                                        items: (_degreeController.text ==
                                                        'MTech' ||
                                                    _degreeController.text ==
                                                        'MSc'
                                                ? mtecmscyear
                                                : btechyears)
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            year = newValue!;
                                          });
                                        },
                                      )
                                    : Card(
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
                                          )),
                                        )),
                                      ),
                              isEditing
                                  ? DropdownButton<String>(
                                      value: hostel,
                                      hint: const Text('Select Hostel'),
                                      items: (_gendercontroller.text == 'Male'
                                              ? boyshostels
                                              : girlshostels)
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          hostel = newValue!;
                                        });
                                      },
                                    )
                                  : Card(
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
                                        )),
                                      )),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    isUpdatingProfile || isUploadingImage
                        ? const CircularProgressIndicator()
                        : isEditing
                            ? ElevatedButton(
                                onPressed: () {
                                  _updateUserDetails();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 15),
                                  backgroundColor: Colors.deepOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  elevation: 6.0,
                                ),
                                child: const Text(
                                  "Save Changes",
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isEditing = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical:
                                          8), // Adjust padding as necessary
                                  backgroundColor: Colors.deepOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  elevation: 6.0,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 4),
                                    Text(
                                      "Edit Profile",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
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

  Widget _buildEditableField(String label, TextEditingController controller) {
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
          controller: controller,
          enabled: isEditing,
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

  Widget _buildNonEditableEmailField(
      String label, TextEditingController controller) {
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
          controller: controller,
          enabled: false,
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
