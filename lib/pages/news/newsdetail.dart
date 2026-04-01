import 'package:flutter/material.dart';
import 'package:revochampblog/models/blog_post.dart';
import 'package:revochampblog/pages/news/news_detail.dart';
import 'package:revochampblog/services/blog_service.dart';

class NewsDetailPageWrapper extends StatefulWidget {
  final String slug;

  const NewsDetailPageWrapper({super.key, required this.slug});

  @override
  State<NewsDetailPageWrapper> createState() =>
      _NewsDetailPageWrapperState();
}

class _NewsDetailPageWrapperState extends State<NewsDetailPageWrapper> {
  BlogPost? post;
  bool loading = true;
  String? error;

  final service = BlogService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant NewsDetailPageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.slug != widget.slug) {
      _reload(); // ✅ CRITICAL FIX
    }
  }

  Future<void> _reload() async {
    setState(() {
      loading = true;
      error = null;
      post = null;
    });

    await _load();
  }

  Future<void> _load() async {
    try {
      final data = await service.fetchBySlug(widget.slug);

      setState(() {
        post = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load article';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || post == null) {
      return const Scaffold(
        body: Center(child: Text('Error loading article')),
      );
    }

    return NewsDetailPage(
      post: post!,
      slug: widget.slug,
    );
  }
}
// class NewsDetailPageWrapper extends StatefulWidget {
//   final String slug;

//   const NewsDetailPageWrapper({super.key, required this.slug});

//   @override
//   State<NewsDetailPageWrapper> createState() =>
//       _NewsDetailPageWrapperState();
// }

// class _NewsDetailPageWrapperState extends State<NewsDetailPageWrapper> {
//   BlogPost? post;
//   bool loading = true;
//   String? error;

//   final service = BlogService();

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     try {
//       final data = await service.fetchBySlug(widget.slug);

//       setState(() {
//         post = data;
//         loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = 'Failed to load article';
//         loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (error != null || post == null) {
//       return const Scaffold(
//         body: Center(child: Text('Error loading article')),
//       );
//     }

//     return NewsDetailPage(
//       post: post!,
//       slug: widget.slug,
//     );
//   }
// }