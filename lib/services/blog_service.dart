import 'dart:convert';
import 'package:revochampblog/models/blog_summary.dart';

import '../models/blog_post.dart';



import 'package:http/http.dart' as http;

import 'package:http/http.dart' as http;
import 'dart:convert';

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




// class BlogService {
//   // ✅ Use CDN (IMPORTANT)
//   static const String _baseUrl =
//       'https://json.revochamp.site/blog/';

//   // ✅ Cache for blog details
//   static final Map<String, BlogPost> _detailCache = {};

//   // ✅ Cache for pages
//   static final Map<int, List<BlogPost>> _pageCache = {};

//   /// ✅ Fetch paginated blogs (page-1.json, page-2.json)
//   Future<List<BlogPost>> fetchPage(int page) async {
//     // Return from cache if available
//     if (_pageCache.containsKey(page)) {
//       return _pageCache[page]!;
//     }

//     try {
//       final response =
//           await http.get(Uri.parse('${_baseUrl}page/page-$page.json'));

//       if (response.statusCode != 200) {
//         throw Exception('Failed to load page-$page');
//       }

//       final List data = jsonDecode(response.body);

//       final blogs =
//           data.map((e) => BlogPost.fromJson(e)).toList();

//       // Save in cache
//       _pageCache[page] = blogs;

//       return blogs;
//     } catch (e) {
//       throw Exception('Error loading page-$page: $e');
//     }
//   }

//   /// ✅ Fetch single blog detail
//   Future<BlogPost> fetchBlogPost(String slug) async {
//     // Return from cache if available
//     if (_detailCache.containsKey(slug)) {
//       return _detailCache[slug]!;
//     }

//     try {
//       final response =
//           await http.get(Uri.parse('${_baseUrl}$slug.json'));

//       if (response.statusCode != 200) {
//         throw Exception('Failed to load blog: $slug');
//       }

//       final Map<String, dynamic> json = jsonDecode(response.body);
//       final post = BlogPost.fromJson(json);

//       // Save in cache
//       _detailCache[slug] = post;

//       return post;
//     } catch (e) {
//       throw Exception('Error loading blog $slug: $e');
//     }
//   }

//   /// ❌ REMOVE THIS (DO NOT USE)
//   /// Future<List<BlogPost>> fetchAllBlogPosts()
// }


// // class BlogService {
// //   // Base URL for all blog-related endpoints
// //   static const String _baseUrl = 'https://json.revochamp.site/blog/';

// //   // In-memory cache
// //   static final Map<String, BlogPost> _cache = {};

// //   /// Fetches all blog posts by first loading the manifest and then each post.
// //   Future<List<BlogPost>> fetchAllBlogPosts() async {
// //     try {
// //       // Fetch manifest.json which contains a list of slugs
// //       final manifestResponse = await http.get(Uri.parse('${_baseUrl}manifest.json'));

// //       if (manifestResponse.statusCode != 200) {
// //         throw Exception('Failed to load manifest: ${manifestResponse.statusCode}');
// //       }

// //       final List<dynamic> manifests = jsonDecode(manifestResponse.body);

// //       // Each item in manifest is a map with a 'slug' field
// //       final futures = manifests.map((item) {
// //         final slug = item['slug'] as String;
// //         return fetchBlogPost(slug);
// //       }).toList();

// //       return await Future.wait(futures);
// //     } catch (e) {
// //       print('Error loading all blog posts: $e');
// //       return [];
// //     }
// //   }

// //   /// Fetches a single blog post by its slug.
// //   /// Uses caching to avoid redundant network requests.
// //   Future<BlogPost> fetchBlogPost(String slug) async {
// //     if (_cache.containsKey(slug)) {
// //       return _cache[slug]!;
// //     }

// //     try {
// //       // Individual posts are stored as {slug}.json
// //       final response = await http.get(Uri.parse('${_baseUrl}$slug.json'));

// //       if (response.statusCode != 200) {
// //         throw Exception('Failed to load blog post $slug: ${response.statusCode}');
// //       }

// //       final Map<String, dynamic> json = jsonDecode(response.body);
// //       final post = BlogPost.fromJson(json);
// //       _cache[slug] = post;
// //       return post;
// //     } catch (e) {
// //       throw Exception('Failed to load blog post $slug: $e');
// //     }
// //   }
// // }


