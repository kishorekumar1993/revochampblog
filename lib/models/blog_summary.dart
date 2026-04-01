class BlogResponse {
  final int page;
  final int totalPages;
  final List<BlogSummary> data;

  const BlogResponse({
    required this.page,
    required this.totalPages,
    required this.data,
  });

  factory BlogResponse.fromJson(Map<String, dynamic> json) {
    return BlogResponse(
      page: json['page'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      data: (json['data'] as List?)
              ?.map((e) => BlogSummary.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'totalPages': totalPages,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  // 🔥 Helpers
  bool get hasNextPage => page < totalPages;

  bool get isFirstPage => page == 1;
}

// lib/models/blog_summary.dart
class BlogSummary {
  final String id;
  final String title;
  final String summary;
  final String slug;
  final String? image;
  final DateTime date;
  final String? category;
  final String? author;
  final int? readTime;

  BlogSummary({
    required this.id,
    required this.title,
    required this.summary,
    required this.slug,
    this.image,
    required this.date,
    this.category,
    this.author,
    this.readTime,
  });

  factory BlogSummary.fromJson(Map<String, dynamic> json) {
    return BlogSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      image: json['image'] as String?,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      category: json['category'] as String?,
      author: json['author'] as String?,
      readTime: json['readTime'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'slug': slug,
      'image': image,
      'date': date.toIso8601String(),
      'category': category,
      'author': author,
      'readTime': readTime,
    };
  }
}