// // lib/Frontend/components/full_screen_image_viewer.dart
// import 'package:flutter/material.dart';

// class FullScreenImageViewer extends StatefulWidget {
//   final List<String> images;
//   final bool isMobile;

//   const FullScreenImageViewer(this.images, this.isMobile, {super.key});

//   @override
//   _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
// }

// class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black.withOpacity(0.8),
//       body: Stack(
//         children: [
//           PageView.builder(
//             itemCount: widget.images.length,
//             controller: PageController(initialPage: _currentIndex),
//             onPageChanged: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//             itemBuilder: (context, index) {
//               return Center(
//                 child: Image.network(
//                   widget.images[index],
//                   width: widget.isMobile
//                       ? MediaQuery.of(context).size.width
//                       : MediaQuery.of(context).size.width * 0.5,
//                   fit: BoxFit.contain,
//                 ),
//               );
//             },
//           ),
//           Positioned(
//             top: 40,
//             right: 20,
//             child: IconButton(
//               icon: const Icon(Icons.close, color: Colors.white, size: 30),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
