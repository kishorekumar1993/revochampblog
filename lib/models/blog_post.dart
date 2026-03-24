import 'content_item.dart';
enum BlogDesign {
  classic,    // default: sidebar TOC, card backgrounds
  minimal,    // clean, centered, no cards
  magazine,   // floating share bar, author bio, hero image
  dark,       // dark theme with accent colors
  video,      // hero video, minimal distractions
  newspaper,
 stackedCardBlogDesign,
 coverstory
}

class BlogPost {
  final String slug;
  final String title;
  final String subtitle;
  final String author;
  final DateTime date;
  final List<String> categories;
  final List<String> tags;
  final String readTime;
  final String? featuredImage;
  final List<ContentItem> content;
  final Map<String, String>? meta; // for custom meta title/description
  final List<Map<String, String>>? faq;
  final List<String> related;
    final String? authorAvatar;

  final String? videoUrl;          // for video design
  final BlogDesign design;      
  BlogPost({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.date,
    required this.categories,
    required this.tags,
    required this.readTime,
    this.featuredImage,
    required this.content,
    this.meta,
this.authorAvatar,
    this.videoUrl,
    this.faq,
    this.related = const [],
 this.design = BlogDesign.newspaper,
   });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      slug: json['slug'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      author: json['author'] as String? ?? 'Admin',
      date: DateTime.parse(json['date'] as String),
      categories: List<String>.from(json['categories'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      readTime: json['readTime'] as String? ?? '5 min read',
      featuredImage: json['featuredImage'] as String?,
      content: (json['content'] as List)
          .map((item) => ContentItem.fromJson(item))
          .toList(),
      meta: json['meta'] != null
          ? Map<String, String>.from(json['meta'])
          : null,
      faq: json['faq'] != null
          ? List<Map<String, String>>.from(json['faq'].map((f) => Map<String, String>.from(f)))
          : null,
      related: List<String>.from(json['related'] ?? []),
    );
  }
}