// // lib/Frontend/components/post_card.dart
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:l_f/newCode/models/post_model.dart';
// import 'package:l_f/newCode/Frontend/components/full_screen_image_viewer.dart';
// import 'package:l_f/newCode/Frontend/pages/profile/user_see_page.dart'; // Import for navigation

// class PostCard extends StatelessWidget {
//   final PostModel post;
//   final String currentUserId;
//   final bool isMobile;
//   final bool userHasRequestedClaim;
//   final VoidCallback onDelete;
//   final VoidCallback onReply;
//   final VoidCallback onClaim;
//   final VoidCallback onShare;

//   const PostCard({
//     super.key,
//     required this.post,
//     required this.currentUserId,
//     required this.isMobile,
//     required this.userHasRequestedClaim,
//     required this.onDelete,
//     required this.onReply,
//     required this.onClaim,
//     required this.onShare,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(2.0),
//       child: Center(
//         child: SizedBox(
//           width: isMobile ? MediaQuery.of(context).size.width : 600,
//           child: Card(
//             elevation: 5,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header of the POST (profile, name, location, delete)
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => UserSeePage(uid: post.postmakerId)),
//                     );
//                   },
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       radius: 30,
//                       backgroundImage: NetworkImage(post.profileImageUrl),
//                     ),
//                     title: Text(
//                       post.userName,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text("Location: ${post.location}, NITH"),
//                     trailing: PopupMenuButton<String>(
//                       onSelected: (value) {
//                         if (value == 'Delete' && currentUserId == post.postmakerId) {
//                            onDelete();
//                         }
//                       },
//                       itemBuilder: (BuildContext context) {
//                         return (currentUserId == post.postmakerId)
//                             ? {'Delete'}.map((String choice) {
//                                 return PopupMenuItem<String>(
//                                   value: choice,
//                                   child: Text(choice),
//                                 );
//                               }).toList()
//                             : [];
//                       },
//                     ),
//                   ),
//                 ),

//                 // Carousel of images
//                 Stack(
//                   children: [
//                     CarouselSlider(
//                       options: CarouselOptions(
//                         autoPlay: true,
//                         height: 450.0,
//                         enlargeCenterPage: true,
//                       ),
//                       items: post.itemImages.map<Widget>((imageUrl) {
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => FullScreenImageViewer(post.itemImages, isMobile),
//                               ),
//                             );
//                           },
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Image.network(
//                               imageUrl,
//                               fit: BoxFit.cover,
//                               width: MediaQuery.of(context).size.width,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return const Icon(Icons.error);
//                               },
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                     Positioned(
//                       top: isMobile ? 16 : 6,
//                       left: 50,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: post.status == 'Lost' ? Colors.red : Colors.green,
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         child: Text(
//                           post.status,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Item Title and Date
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             post.title == 'Other' ? '${post.status} Item' : post.title,
//                             overflow: TextOverflow.clip,
//                             softWrap: true,
//                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(width: 5),
//                           Row(
//                             children: [
//                               Text(
//                                 "${post.status} On: ",
//                                 overflow: TextOverflow.clip,
//                                 softWrap: true,
//                                 style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 post.postTime,
//                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 5),

//                       // Description
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Description: ",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               post.description,
//                               overflow: TextOverflow.clip,
//                               softWrap: true,
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),

//                       // Buttons for interactions
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           GestureDetector(
//                             onTap: onShare,
//                             child: const Row(
//                               children: [
//                                 Icon(Icons.share_rounded),
//                                 SizedBox(width: 3),
//                                 Text('Share'),
//                               ],
//                             ),
//                           ),
//                           if (currentUserId != post.postmakerId)
//                             ElevatedButton(
//                               onPressed: onReply,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green.shade600,
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                               ),
//                               child: const Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.reply, color: Colors.white),
//                                   SizedBox(width: 3),
//                                   Text('Reply', style: TextStyle(color: Colors.white)),
//                                 ],
//                               ),
//                             ),
//                           if (post.status == 'Found' && !post.isClaimed && currentUserId != post.postmakerId && !userHasRequestedClaim)
//                             ElevatedButton(
//                               onPressed: onClaim,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.deepOrange.shade600,
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                               ),
//                               child: const Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.back_hand, color: Colors.white),
//                                   SizedBox(width: 6),
//                                   Text('Claim', style: TextStyle(color: Colors.white)),
//                                 ],
//                               ),
//                             ),
//                           if (userHasRequestedClaim)
//                             ElevatedButton(
//                               onPressed: () {},
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blueGrey,
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                               ),
//                               child: const Text('Requested', style: TextStyle(color: Colors.white)),
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
