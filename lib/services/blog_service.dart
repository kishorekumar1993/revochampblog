import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/blog_post.dart';



import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/blog_post.dart';

class BlogService {
  // Base URL for all blog-related endpoints
  static const String _baseUrl = 'https://json.revochamp.site/blog/';

  // In-memory cache
  static final Map<String, BlogPost> _cache = {};

  /// Fetches all blog posts by first loading the manifest and then each post.
  Future<List<BlogPost>> fetchAllBlogPosts() async {
    try {
      // Fetch manifest.json which contains a list of slugs
      final manifestResponse = await http.get(Uri.parse('${_baseUrl}manifest.json'));

      if (manifestResponse.statusCode != 200) {
        throw Exception('Failed to load manifest: ${manifestResponse.statusCode}');
      }

      final List<dynamic> manifests = jsonDecode(manifestResponse.body);

      // Each item in manifest is a map with a 'slug' field
      final futures = manifests.map((item) {
        final slug = item['slug'] as String;
        return fetchBlogPost(slug);
      }).toList();

      return await Future.wait(futures);
    } catch (e) {
      print('Error loading all blog posts: $e');
      return [];
    }
  }

  /// Fetches a single blog post by its slug.
  /// Uses caching to avoid redundant network requests.
  Future<BlogPost> fetchBlogPost(String slug) async {
    if (_cache.containsKey(slug)) {
      return _cache[slug]!;
    }

    try {
      // Individual posts are stored as {slug}.json
      final response = await http.get(Uri.parse('${_baseUrl}$slug.json'));

      if (response.statusCode != 200) {
        throw Exception('Failed to load blog post $slug: ${response.statusCode}');
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      final post = BlogPost.fromJson(json);
      _cache[slug] = post;
      return post;
    } catch (e) {
      throw Exception('Failed to load blog post $slug: $e');
    }
  }
}


// class BlogService {
//   // Cache in memory
//   static final Map<String, BlogPost> _cache = {};

// Future<List<BlogPost>> fetchAllBlogPosts() async {
//   try {
//     final manifestString =
//         await rootBundle.loadString('assets/blogs/manifest.json');

//     final List manifests = jsonDecode(manifestString);

//     print("MANIFEST: $manifests");

//     final futures = manifests.map((item) {
//       final slug = item is String ? item : item['slug'];
//       return fetchBlogPost(slug);
//     }).toList();

//     return await Future.wait(futures);
//   } catch (e) {
//     print('Error loading all blog posts: $e');
//     return [];
//   }
// }



//   Future<BlogPost> fetchBlogPost(String slug) async {
//     if (_cache.containsKey(slug)) {
//       return _cache[slug]!;
//     }

//     try {
//       final jsonString = await rootBundle.loadString('assets/blogs/$slug.json');
//       final json = jsonDecode(jsonString);
//       final post = BlogPost.fromJson(json);
//       _cache[slug] = post;
//       return post;
//     } catch (e) {
//       throw Exception('Failed to load blog post $slug: $e');
//     }
//   }
// }


// // import 'dart:convert';
// // import 'package:flutter/services.dart';
// // import 'package:http/http.dart' as http;
// // import '../models/blog_post.dart';

// // class BlogService {
// //   static const String baseUrl = 'https://json.revochamp.site/blog/'; // adjust to your API

// //   // In-memory cache
// //   static final Map<String, BlogPost> _cache = {};

// //   Future<BlogPost> fetchBlogPost(String slug) async {
// //     if (_cache.containsKey(slug)) {
// //       return _cache[slug]!;
// //     }

// //     try {
// //       // Option 1: From API
// //       final response = await http.get(Uri.parse('$baseUrl$slug.json'));
// //       if (response.statusCode == 200) {
// //         final json = jsonDecode(response.body);
// //         final post = BlogPost.fromJson(json);
// //         _cache[slug] = post;
// //         return post;
// //       } else {
// //         // Option 2: Fallback to assets
// //         final jsonString = await rootBundle.loadString('assets/blogs/$slug.json');
// //         final json = jsonDecode(jsonString);
// //         final post = BlogPost.fromJson(json);
// //         _cache[slug] = post;
// //         return post;
// //       }
// //     } catch (e) {
// //       throw Exception('Failed to load blog post: $e');
// //     }
// //   }

// //   // Optional: fetch list of all blog posts (for index page)
// //   Future<List<BlogPost>> fetchAllBlogPosts() async {
// //     // You could fetch from API or load from a manifest file
// //     final manifestString = await rootBundle.loadString('assets/blogs/manifest.json');
// //     final List manifests = jsonDecode(manifestString);
// //     return Future.wait(manifests.map((m) => fetchBlogPost(m['slug'])));
// //   }
// // }