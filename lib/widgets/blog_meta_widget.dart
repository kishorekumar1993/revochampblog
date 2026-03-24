import 'package:flutter/material.dart';
import '../models/blog_post.dart';

class BlogMetaWidget extends StatelessWidget {
  final BlogPost post;

  const BlogMetaWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (post.author.isNotEmpty) ...[
          const Icon(Icons.person, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(post.author, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 12),
        ],
        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(_formatDate(post.date), style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 12),
        const Icon(Icons.access_time, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(post.readTime, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}