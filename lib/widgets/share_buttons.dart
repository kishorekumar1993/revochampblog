import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareButtons extends StatelessWidget {
  final String url;
  final String title;

  const ShareButtons({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _share(context),
          tooltip: 'Share',
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: () {},
          tooltip: 'Bookmark',
        ),
      ],
    );
  }

  void _share(BuildContext context) async {
    // You can use share_plus package or custom share via URL
    // For now, just copy URL to clipboard
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard!')),
    );
  }
}