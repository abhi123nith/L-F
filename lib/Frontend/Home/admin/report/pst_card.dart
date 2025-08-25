import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Frontend/Home/Post/post_model.dart'; // Adjust these imports to your project structure
import 'package:l_f/Frontend/Profile/user_see_page.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool isOwner;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  // You can add more callbacks here for Reply, Claim, etc.

  const PostCard({
    super.key,
    required this.post,
    required this.isOwner,
    required this.onDelete,
    required this.onReport,
  });

  final String _placeholderImage =
      'https://placehold.co/600x400/EEE/31343C?text=No+Image';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- USER HEADER ---
            ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage2(uid: post.postmakerId)),
              ),
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  post.profileImageUrl.isNotEmpty ? post.profileImageUrl : _placeholderImage,
                ),
                onBackgroundImageError: (_, __) {},
              ),
              title: Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("at ${post.location}"),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Delete') {
                    onDelete();
                  } else if (value == 'Report') {
                    onReport();
                  }
                },
                itemBuilder: (BuildContext context) {
                  List<PopupMenuEntry<String>> menuItems = [];
                  if (isOwner) {
                    menuItems.add(const PopupMenuItem<String>(value: 'Delete', child: Text('Delete')));
                  }
                  if (!isOwner) {
                    menuItems.add(const PopupMenuItem<String>(value: 'Report', child: Text('Report')));
                  }
                  return menuItems;
                },
              ),
            ),
            // --- IMAGE CAROUSEL & STATUS BADGE ---
            Stack(
              children: [
                if (post.itemImages.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 16 / 10,
                      viewportFraction: 1.0,
                      autoPlay: post.itemImages.length > 1,
                    ),
                    items: post.itemImages.map((imageUrl) {
                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) =>
                            progress == null ? child : const Center(child: CircularProgressIndicator()),
                        errorBuilder: (context, error, stackTrace) =>
                            Image.network(_placeholderImage, fit: BoxFit.cover),
                      );
                    }).toList(),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: post.status == 'Lost' ? Colors.red.shade600 : Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(post.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            // --- POST DETAILS ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Posted on: ${post.postTime}", style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Text(post.description, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // --- ACTION BUTTONS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined), label: const Text('Share')),
                  if (!isOwner)
                    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.reply_outlined), label: const Text('Reply')),
                  if (!isOwner && post.status == 'Found' && !(post.isClaimed ?? false))
                    ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.check_circle_outline), label: const Text('Claim')),
                  if (post.isClaimed ?? false)
                    const Chip(label: Text('Claimed'), avatar: Icon(Icons.verified_user_outlined)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
