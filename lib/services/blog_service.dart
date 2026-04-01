import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/blog_summary.dart';
import '../models/blog_post.dart';

class BlogService {
  final String _baseUrl;

  BlogService({
    String baseUrl = 'https://json.revochamp.site/blog',
  }) : _baseUrl = baseUrl;

  /// ✅ Pagination (MAIN)
  Future<BlogResponse> fetchPage(int page) async {
    final url = Uri.parse('$_baseUrl/page/page-$page.json');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load page $page');
    }

    final decoded = json.decode(response.body);

    // Expected: { page, totalPages, data }
    if (decoded is Map<String, dynamic>) {
      return BlogResponse.fromJson(decoded);
    }

    // Fallback: pure list
    if (decoded is List) {
      return BlogResponse(
        page: 1,
        totalPages: 1,
        data: decoded
            .map((e) => BlogSummary.fromJson(e))
            .toList(),
      );
    }

    throw Exception('Invalid JSON format');
  }

  /// ✅ Category (STATIC JSON)
  Future<BlogResponse> fetchByCategory(String category,
      {int page = 1}) async {
    print("decoded ONE  VALUE IS KK");
  
    final url = Uri.parse(
        '$_baseUrl/category/$category/page-$page.json');

    final response = await http.get(url);

    print("decoded TWO  VALUE IS KK$response ");
  
    if (response.statusCode != 200) {
      throw Exception('Failed to load category: $category');
    }

    final decoded = json.decode(response.body);
    print("decoded ONE  VALUE IS $decoded");
  
    if (decoded is Map<String, dynamic>) {
      print("decoded VALUE IS $decoded");
      return BlogResponse.fromJson(decoded);
    }

    throw Exception('Invalid category JSON');
  }

  /// ✅ Search (STATIC JSON - pre-generated)
  Future<BlogResponse> search(String query, {int page = 1}) async {
    final url = Uri.parse(
        '$_baseUrl/search/$query/page-$page.json');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Search failed');
    }

    final decoded = json.decode(response.body);

    if (decoded is Map<String, dynamic>) {
      return BlogResponse.fromJson(decoded);
    }

    throw Exception('Invalid search JSON');
  }

  /// ✅ Categories list (STATIC JSON)
  Future<List<String>> getCategories() async {
    final url = Uri.parse('$_baseUrl/category/index.json');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories');
    }

    final decoded = json.decode(response.body);

    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }

    if (decoded is Map && decoded['data'] is List) {
      return (decoded['data'] as List)
          .map((e) => e.toString())
          .toList();
    }

    throw Exception('Invalid categories JSON');
  }

  /// ✅ Blog Detail (STATIC JSON)
  Future<BlogPost> fetchBySlug(String slug) async {
    final url = Uri.parse('$_baseUrl/$slug.json');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load blog: $slug');
    }

    final decoded = json.decode(response.body);

    if (decoded is Map<String, dynamic>) {
      return BlogPost.fromJson(decoded);
    }

    throw Exception('Invalid blog JSON');
  }
}
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:revochampblog/models/blog_post.dart';
// import '../models/blog_summary.dart';

// class BlogService {
//   final String _baseUrl;

//   BlogService({
//     String baseUrl = 'https://json.revochamp.site/blog',
//   }) : _baseUrl = baseUrl;

//   /// Fetch blog posts (STATIC JSON)
//   Future<List<BlogSummary>> fetchPage(int page) async {
//     try {
//       final url = Uri.parse('$_baseUrl/page/page-$page.json');

//       final response = await http.get(url, headers: {
//         'Accept': 'application/json',
//       });

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data is List) {
//           return data
//               .map((json) => BlogSummary.fromJson(json))
//               .toList();
//         } else if (data is Map && data['data'] is List) {
//           return (data['data'] as List)
//               .map((json) => BlogSummary.fromJson(json))
//               .toList();
//         }
//       }

//       throw Exception('Failed to load posts: ${response.statusCode}');
//     } catch (e) {
//       throw Exception('Error fetching posts: $e');
//     }
//   }

//   /// Fetch by category
//   Future<List<BlogSummary>> fetchByCategory(String category,
//       {int page = 1}) async {
//     try {
//       final url = Uri.parse(
//           '$_baseUrl/api/v1/blogs/category/$category?page=$page');

//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List list = data['data'] ?? [];

//         return list.map((json) => BlogSummary.fromJson(json)).toList();
//       }

//       throw Exception('Failed to load category posts');
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }

//   /// Search
//   Future<List<BlogSummary>> search(String query, {int page = 1}) async {
//     try {
//       final url = Uri.parse(
//           '$_baseUrl/api/v1/blogs/search?q=$query&page=$page');

//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List list = data['data'] ?? [];

//         return list.map((json) => BlogSummary.fromJson(json)).toList();
//       }

//       throw Exception('Search failed');
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }

//   /// Categories
//   Future<List<String>> getCategories() async {
//     try {
//       final url =
//           Uri.parse('$_baseUrl/api/v1/blogs/categories');

//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List list = data['data'] ?? [];

//         return list.map((e) => e.toString()).toList();
//       }

//       throw Exception('Failed to load categories');
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }

//   /// Blog detail
//   Future<BlogPost> fetchBySlug(String slug) async {
//     try {
//       final url =
//           Uri.parse('$_baseUrl/api/v1/blogs/$slug');

//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return BlogPost.fromJson(data['data']);
//       }

//       throw Exception('Failed to load blog');
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }
// }
