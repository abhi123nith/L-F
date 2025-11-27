import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:l_f/Frontend/Home/Post/Utils/full_post.dart';

class DeepLinkService {
  StreamSubscription? _linkSubscription;
  final _appLinks = AppLinks();

  // Initialize deep linking
  void initDeepLinking(BuildContext context) {
    // Handle initial link if app is opened from a deep link
    _handleInitialLink(context);

    // Listen for incoming links while app is running
    _listenForLinks(context);
  }

  // Handle initial link when app is opened from a deep link
  Future<void> _handleInitialLink(BuildContext context) async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(context, initialLink.toString());
      }
    } catch (e) {
      print('Error handling initial link: $e');
    }
  }

  // Listen for incoming links while app is running
  void _listenForLinks(BuildContext context) {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleLink(context, uri.toString());
        }
      },
      onError: (Object err) {
        print('Error listening to links: $err');
      },
    );
  }

  // Handle the deep link
  void _handleLink(BuildContext context, String link) {
    try {
      // Parse the link to extract post ID
      final uri = Uri.parse(link);

      // Check if it's a post link
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'post') {
        final postId = uri.pathSegments[1];

        // Navigate to the post details page
        _navigateToPost(context, postId);
      }
    } catch (e) {
      print('Error parsing link: $e');
    }
  }

  // Navigate to post details page
  void _navigateToPost(BuildContext context, String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailsPage(postId: postId),
      ),
    );
  }

  // Dispose of the subscription
  void dispose() {
    _linkSubscription?.cancel();
  }

  // Generate a deep link for a post
  static String generatePostLink(String postId) {
    // Use your actual Netlify domain
    return 'https://nithlostandfoundweb.netlify.app/post/$postId';
  }
}
