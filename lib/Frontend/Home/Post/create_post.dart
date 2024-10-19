import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:l_f/Frontend/Contants/lists.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  List<Uint8List>? _imageBytes;
  final _formKey = GlobalKey<FormState>();
  String _status = 'Lost';
  String? _title;
  String? _location;
  String? _hostel;
  String? _description;
  String? _question;
  String? postClaimer;
  bool _isLoading = false;
  bool _isSuccess = false;
  final bool _isClaimed = false;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final List<String> _boysHostels = boyshostelsList;
  final List<String> _girlsHostels = girlshostelsList;
  final List<String> _itemLists = itemsList;
  final List<String> _locations = locationsList;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _pickImages() async {
    try {
      if (kIsWeb) {
        // Use FilePicker for web
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );

        if (result != null) {
          setState(() {
            _imageBytes = result.files.map((file) => file.bytes!).toList();
          });
        }
      } else {
        // Use ImagePicker for mobile
        final ImagePicker picker = ImagePicker();
        final List<XFile> pickedFiles = await picker.pickMultiImage();

        if (pickedFiles.isNotEmpty) {
          List<Uint8List> imageBytes = [];
          for (var pickedFile in pickedFiles) {
            final Uint8List fileBytes = await pickedFile.readAsBytes();
            imageBytes.add(fileBytes);
          }

          setState(() {
            _imageBytes = imageBytes;
          });
        }
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      User user = auth.currentUser!;
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          print("USER DATAAAA  ::::  $userDoc");
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _submitData() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    _formKey.currentState?.save();

    if (!mounted) return;

    if (_imageBytes == null || _imageBytes!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.deepOrange,
            content: Text('Please select at least one image')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _isSuccess = false;
    });

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final FirebaseStorage storage = FirebaseStorage.instance;
      User? user = FirebaseAuth.instance.currentUser;
      List<String> imageUrls = [];

      final uploadFutures = _imageBytes!.asMap().entries.map((entry) async {
        final index = entry.key;
        final imageByteData = entry.value;
        final fileName =
            'images/${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
        final ref = storage.ref().child(fileName);
        await ref.putData(imageByteData);
        return ref.getDownloadURL();
      });

      imageUrls = await Future.wait(uploadFutures);

      print("Images :  ::::###### $imageUrls");

      final data = {
        'location': _location,
        'item': _title,
        'description': _description,
        'imageUrls': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'postmakerId': user!.uid,
        'isClaimed': _isClaimed,
        'postClaimer': postClaimer,
        'claimStatus': "",
        'question': _question,
        'status': _status,
      };

      print('Submitting data: $data');

      DocumentReference postRef = await firestore.collection('posts').add(data);

      await postRef.update({'postId': postRef.id});

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Item uploaded successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
      });
      print('Error submitting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red, content: Text('Error uploading item')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageBytes!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        title: const Text('Create New Post'),
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statusSelector('Lost'),
                          _statusSelector('Found'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title input
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Item Title',
                          border: OutlineInputBorder(),
                        ),
                        value: _title,
                        items: _itemLists
                            .map((itemTitle) => DropdownMenuItem<String>(
                                  value: itemTitle,
                                  child: Text(itemTitle),
                                ))
                            .toList(),
                        validator: (value) =>
                            value == null ? 'Please select a title' : null,
                        onChanged: (value) {
                          setState(() {
                            _title = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Location dropdown menu
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        value: _location,
                        items: _locations
                            .map((location) => DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(location),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _location = value;
                            _hostel =
                                null; // Reset hostel selection when location changes
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a location' : null,
                        onSaved: (value) => _location = value,
                      ),

                      const SizedBox(height: 16),

                      // Hostel dropdown for 'Boys Hostel' or 'Girls Hostel'
                      if (_location == 'Boys Hostel' ||
                          _location == 'Girls Hostel')
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Hostel Name',
                            border: OutlineInputBorder(),
                          ),
                          value: _hostel,
                          items: (_location == 'Boys Hostel'
                                  ? _boysHostels
                                  : _girlsHostels)
                              .map((hostel) => DropdownMenuItem<String>(
                                    value: hostel,
                                    child: Text(hostel),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _hostel = value;
                            });
                          },
                          validator: (value) {
                            if ((_location == 'Boys Hostel' ||
                                    _location == 'Girls Hostel') &&
                                value == null) {
                              return 'Please select a hostel';
                            }
                            return null;
                          },
                          onSaved: (value) => _hostel = value,
                        ),
                      const SizedBox(height: 16),

                      // Description input
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        onSaved: (value) => _description = value,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a description'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Question input (only for 'Found' items)
                      if (_status == 'Found')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText:
                                    'Verification Question (to ask the Claimer)',
                                border: OutlineInputBorder(),
                              ),
                              onSaved: (value) => _question = value,
                              validator: (value) {
                                if (_status == 'Found' &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please provide a verification question for found items';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Select Images Button
                      SizedBox(
                        width: 200,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: _pickImages,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.photo_library_outlined,
                                    color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Select Images',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_imageBytes != null && _imageBytes!.isNotEmpty)
                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imageBytes!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        _imageBytes![index],
                                        width: 90,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () => _removeImage(index),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      // Submit button
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    _submitData();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _isLoading ? 'Uploading...' : 'Submit',
                            // 'Post',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget to select Lost/Found status
  Widget _statusSelector(String status) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            child: CircleAvatar(
              radius: 10,
              backgroundColor:
                  _status == status ? Colors.deepOrange : Colors.transparent,
              child: _status == status
                  ? null
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Text(status,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      showCheckmark: false,
      selectedColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      selected: _status == status,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _status = status;
          });
        }
      },
    );
  }
}
