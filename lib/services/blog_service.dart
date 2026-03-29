import 'dart:convert';
import 'package:revochampblog/models/blog_summary.dart';

import '../models/blog_post.dart';



import 'package:http/http.dart' as http;


class BlogService {
  final String baseUrl = 'https://json.revochamp.site/blog'; // adjust as needed

  Future<List<BlogSummary>> fetchPage(int page) async {
    // Your list endpoint – maybe something like /posts?page=$page
    final response = await http.get(Uri.parse('$baseUrl/page/page-$page.json'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BlogSummary.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts (status ${response.statusCode})');
    }
  }

  Future<BlogPost> fetchBySlug(String slug) async {
    // Endpoint that returns full post details – adjust to your API
    final response = await http.get(Uri.parse('$baseUrl/$slug.json'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return BlogPost.fromJson(data);
    } else {
      throw Exception('Failed to load post');
    }
  }
}
