// // lib/Frontend/pages/create_post_page.dart
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:l_f/newCode/Backend/firestore_service.dart';
// import 'package:l_f/newCode/Frontend/components/custom_dropdown_field.dart';
// import 'package:l_f/newCode/Frontend/components/custom_text_field.dart';
// import 'package:l_f/newCode/Frontend/components/status_selector.dart';
// import 'package:l_f/newCode/constants/lists.dart';

// class CreatePostPage extends StatefulWidget {
//   const CreatePostPage({super.key});

//   @override
//   _CreatePostPageState createState() => _CreatePostPageState();
// }

// class _CreatePostPageState extends State<CreatePostPage> {
//   final _formKey = GlobalKey<FormState>();
//   final FirestoreService _firestoreService = FirestoreService();

//   String _status = 'Lost';
//   String? _title;
//   String? _location;
//   String? _hostel;
//   String? _description;
//   String? _question;
//   List<Uint8List>? _imageBytes;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreService.fetchUserData(); // Fetch user data on page load
//   }

//   Future<void> _submitData() async {
//     if (_formKey.currentState?.validate() == false) {
//       return;
//     }
//     _formKey.currentState?.save();

//     if (_imageBytes == null || _imageBytes!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.deepOrange,
//           content: Text('Please select at least one image'),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _firestoreService.createPost(
//         status: _status,
//         title: _title!,
//         location: _location!,
//         description: _description!,
//         imageBytes: _imageBytes!,
//         hostel: _hostel,
//         question: _question,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.green,
//           content: Text('Item uploaded successfully!'),
//         ),
//       );
//       Navigator.of(context).pop();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.red,
//           content: Text('Error uploading item: $e'),
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _removeImage(int index) {
//     setState(() {
//       _imageBytes!.removeAt(index);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepOrange,
//         foregroundColor: Colors.white,
//         title: const Text('Create New Post'),
//       ),
//       body: Center(
//         child: SizedBox(
//           width: 500,
//           child: Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           StatusSelector(
//                             status: 'Lost',
//                             selectedStatus: _status,
//                             onSelected: (status) =>
//                                 setState(() => _status = status),
//                           ),
//                           StatusSelector(
//                             status: 'Found',
//                             selectedStatus: _status,
//                             onSelected: (status) =>
//                                 setState(() => _status = status),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       CustomDropdownField<String>(
//                         label: 'Item Title',
//                         value: _title,
//                         items: itemsList,
//                         onChanged: (value) => setState(() => _title = value),
//                         validator: (value) =>
//                             value == null ? 'Please select a title' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       CustomDropdownField<String>(
//                         label: 'Location',
//                         value: _location,
//                         items: locationsList,
//                         onChanged: (value) {
//                           setState(() {
//                             _location = value;
//                             if (value != 'Boys Hostel' &&
//                                 value != 'Girls Hostel') {
//                               _hostel = null;
//                             }
//                           });
//                         },
//                         validator: (value) =>
//                             value == null ? 'Please select a location' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       if (_location == 'Boys Hostel' ||
//                           _location == 'Girls Hostel')
//                         CustomDropdownField<String>(
//                           label: 'Hostel Name',
//                           value: _hostel,
//                           items: _location == 'Boys Hostel'
//                               ? boyshostelsList
//                               : girlshostelsList,
//                           onChanged: (value) => setState(() => _hostel = value),
//                           validator: (value) =>
//                               value == null ? 'Please select a hostel' : null,
//                         ),
//                       const SizedBox(height: 16),
//                       CustomTextField(
//                         label: 'Description',
//                         controller: TextEditingController(text: _description),
//                         icon: Icons.description,
//                         validator: (value) => value!.isEmpty
//                             ? 'Please enter a description'
//                             : null,
//                         onSaved: (value) => _description = value,
//                       ),
//                       const SizedBox(height: 16),
//                       if (_status == 'Found')
//                         CustomTextField(
//                           label: 'Verification Question',
//                           controller: TextEditingController(text: _question),
//                           icon: Icons.help_outline,
//                           validator: (value) => value!.isEmpty
//                               ? 'Please provide a verification question'
//                               : null,
//                           onSaved: (value) => _question = value,
//                         ),
//                       const SizedBox(height: 16),
//                       ElevatedButton.icon(
//                         onPressed: () async {
//                           _imageBytes = await _firestoreService.pickImages();
//                           setState(() {});
//                         },
//                         icon: const Icon(Icons.photo_library,
//                             color: Colors.white),
//                         label: const Text('Select Images',
//                             style: TextStyle(color: Colors.white)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepOrange,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       if (_imageBytes != null && _imageBytes!.isNotEmpty)
//                         SizedBox(
//                           height: 110,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: _imageBytes!.length,
//                             itemBuilder: (context, index) {
//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: Stack(
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.circular(12),
//                                       child: Image.memory(
//                                         _imageBytes![index],
//                                         width: 90,
//                                         height: 100,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                     Positioned(
//                                       top: 0,
//                                       right: 0,
//                                       child: IconButton(
//                                         icon: const Icon(Icons.cancel,
//                                             color: Colors.red),
//                                         onPressed: () => _removeImage(index),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       const SizedBox(height: 20),
//                       Center(
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _submitData,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.deepOrange,
//                           ),
//                           child: Text(
//                             _isLoading ? 'Uploading...' : 'Submit',
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
