// lib/newCode/Frontend/pages/create_post/ai_create_post_page.dart
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:l_f/Backend/firestore_service.dart';
import 'package:l_f/Frontend/Contants/lists.dart'
    show itemsList, locationsList, boyshostelsList, girlshostelsList;
import 'package:l_f/newCode/Backend/ai_service.dart';

class AICreatePostPage extends StatefulWidget {
  final String geminiApiKey;

  const AICreatePostPage({super.key, required this.geminiApiKey});

  @override
  _AICreatePostPageState createState() => _AICreatePostPageState();
}

class _AICreatePostPageState extends State<AICreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  late final FirestoreService _firestoreService;
  final AIService _aiService = AIService();

  List<Uint8List>? _imageBytes;
  bool _isLoading = false;
  bool _isProcessingAI = false;

  // Controllers for form fields
  final TextEditingController _userDescriptionController =
      TextEditingController();
  final TextEditingController _detailedDescriptionController =
      TextEditingController();

  // Post fields
  String _status = 'Lost';
  String _title =
      'Other'; // Initialize with a default value that exists in the list
  String _location =
      'Campus, NITH'; // Initialize with a default value that exists in the list
  String?
      _aiGeneratedDescription; // Store AI-generated description for the post
  String? _question;
  String? _hostel;

  @override
  void initState() {
    super.initState();
    _aiService.initialize(widget.geminiApiKey);
    _firestoreService = FirestoreService();
    _firestoreService.fetchUserData();
  }

  @override
  void dispose() {
    _userDescriptionController.dispose();
    _detailedDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
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
    } catch (e) {
      print('Error picking files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting images'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to normalize item title to match our predefined list
  String _normalizeItemTitle(String title) {
    // Convert to lowercase for comparison
    final lowerTitle = title.toLowerCase();

    // Check if any item in our list matches (case insensitive)
    for (final item in itemsList) {
      if (item.toLowerCase() == lowerTitle) {
        return item; // Return the exact case from our list
      }
    }

    // If no match found, return "Other"
    return 'Other';
  }

  // Helper method to normalize location to match our predefined list
  String _normalizeLocation(String location) {
    // Convert to lowercase for comparison
    final lowerLocation = location.toLowerCase();

    // Check if any location in our list matches (case insensitive)
    for (final loc in locationsList) {
      if (loc.toLowerCase() == lowerLocation) {
        return loc; // Return the exact case from our list
      }
    }

    // If no match found, return default
    return 'Campus, NITH';
  }

  Future<void> _processWithAI() async {
    if (_userDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingAI = true;
    });

    try {
      print('Processing with AI: ${_userDescriptionController.text}');
      final extractedData =
          await _aiService.extractPostDetails(_userDescriptionController.text);
      print('Extracted data: $extractedData');

      setState(() {
        _status = extractedData['type'] ?? 'Lost';
        // Normalize the item title to match our predefined list
        _title = _normalizeItemTitle(extractedData['item'] ?? 'Other');
        // Normalize the location to match our predefined list
        _location =
            _normalizeLocation(extractedData['location'] ?? 'Campus, NITH');
        // Keep the user's original description in the input field
        // But store the AI-generated description for submission
        _aiGeneratedDescription =
            extractedData['description'] ?? _userDescriptionController.text;
        // We won't use the date from AI as our app doesn't have a date field

        // If the location is a hostel, don't set a default hostel value
        // Let the user select it manually
        if (_location == 'Boys Hostel' || _location == 'Girls Hostel') {
          _hostel = null; // No default value, user must select
        } else {
          _hostel = null; // Reset hostel for non-hostel locations
        }

        // Update the detailed description controller with AI-generated description
        _detailedDescriptionController.text = _aiGeneratedDescription!;
      });

      print(
          'Updated state - Title: $_title, Location: $_location, Status: $_status');
      print('User description: ${_userDescriptionController.text}');
      print('AI-generated description for post: $_aiGeneratedDescription');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post details extracted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error processing with AI: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Error processing with AI. Please fill details manually.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessingAI = false;
      });
    }
  }

  Future<void> _submitData() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }
    _formKey.currentState?.save();

    if (_imageBytes == null || _imageBytes!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.deepOrange,
          content: Text('Please select at least one image'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.createPost(
        status: _status,
        title: _title,
        location: _location,
        description: _detailedDescriptionController.text.isNotEmpty
            ? _detailedDescriptionController.text
            : _aiGeneratedDescription ??
                _userDescriptionController
                    .text, // Use AI-generated description if available
        imageBytes: _imageBytes!,
        hostel: _hostel,
        question: _question,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Item uploaded successfully!'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error uploading item: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        title: const Text('AI-Powered Post Creation'),
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
                      // Description input for AI processing
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Describe your lost/found item',
                          border: OutlineInputBorder(),
                          helperText:
                              'Example: I lost my black iPhone near the library yesterday',
                        ),
                        maxLines: 3,
                        controller: _userDescriptionController,
                        validator: (value) =>
                            value!.isEmpty ? 'Please describe your item' : null,
                      ),
                      const SizedBox(height: 16),

                      // AI Process Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _isProcessingAI ? null : _processWithAI,
                          icon: _isProcessingAI
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.auto_fix_high,
                                  color: Colors.white),
                          label: Text(
                            _isProcessingAI
                                ? 'Processing...'
                                : 'Extract Details with AI',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Divider(),
                      const SizedBox(height: 16),

                      // Manual form fields (will be populated by AI)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ChoiceChip(
                            label: const Text('Lost'),
                            selected: _status == 'Lost',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _status = 'Lost';
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Found'),
                            selected: _status == 'Found',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _status = 'Found';
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Item Title',
                          border: OutlineInputBorder(),
                        ),
                        value: _title,
                        items: itemsList
                            .map((itemTitle) => DropdownMenuItem<String>(
                                  value: itemTitle,
                                  child: Text(itemTitle),
                                ))
                            .toList(),
                        validator: (value) =>
                            value == null ? 'Please select a title' : null,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _title = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        value: _location,
                        items: locationsList
                            .map((location) => DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(location),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _location = value;
                              _hostel =
                                  null; // Reset hostel selection when location changes
                            });
                          }
                        },
                        validator: (value) =>
                            value == null ? 'Please select a location' : null,
                      ),
                      const SizedBox(height: 16),

                      // Hostel dropdown (conditional)
                      if (_location == 'Boys Hostel' ||
                          _location == 'Girls Hostel')
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Hostel Name',
                            border: OutlineInputBorder(),
                          ),
                          value: _hostel,
                          items: [
                            // Add a hint option
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Select a hostel'),
                            ),
                            // Add the actual hostel options
                            ...(_location == 'Boys Hostel'
                                    ? boyshostelsList
                                    : girlshostelsList)
                                .map((hostel) => DropdownMenuItem<String>(
                                      value: hostel,
                                      child: Text(hostel),
                                    ))
                                
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _hostel = value;
                              });
                            }
                          },
                          validator: (value) {
                            if ((_location == 'Boys Hostel' ||
                                    _location == 'Girls Hostel') &&
                                value == null) {
                              return 'Please select a hostel';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 16),

                      // Description field (can be edited after AI processing)
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Detailed Description',
                          border: OutlineInputBorder(),
                          helperText:
                              'This description was generated by AI and can be edited',
                        ),
                        maxLines: 4,
                        controller: _detailedDescriptionController,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a description'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Question field (only for 'Found' items)
                      if (_status == 'Found')
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

                      // Image selection
                      SizedBox(
                        width: 200,
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.photo_library,
                                color: Colors.white),
                            label: const Text(
                              'Select Images',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Preview selected images
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
                          onPressed: _isLoading ? null : _submitData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                          ),
                          child: Text(
                            _isLoading ? 'Uploading...' : 'Submit Post',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
}
