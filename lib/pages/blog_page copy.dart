// // pages/blog_page.dart

// import 'dart:collection';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:revochampblog/core/meta_service.dart';
// import 'package:revochampblog/models/blog_post.dart';
// import 'package:revochampblog/models/content_item.dart';
// import 'package:revochampblog/services/blog_service.dart';
// import 'package:revochampblog/widgets/blogdesign/news_paper_blog.dart';
// import 'package:share_plus/share_plus.dart';

// import '../widgets/error_widget.dart';

// const String _baseBlogUrl = 'https://tech.revochamp.site/blog';
// const int _maxCacheSize = 20;

// class BlogPage extends StatefulWidget {
//   final String slug;
//   const BlogPage({Key? key, required this.slug}) : super(key: key);

//   @override
//   State<BlogPage> createState() => _BlogPageState();
// }

// class _BlogPageState extends State<BlogPage> {
//   static final LinkedHashMap<String, BlogPost> _cache = LinkedHashMap();

//   final ScrollController _scrollController = ScrollController();
//   final ValueNotifier<double> _scrollProgress = ValueNotifier(0.0);

//   final List<GlobalKey> _headingKeys = [];
//   Future<BlogPost>? _futurePost;

//   @override
//   void initState() {
//     super.initState();
//     _futurePost = _loadBlogPost();
//     _scrollController.addListener(_updateScrollProgress);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_updateScrollProgress);
//     _scrollController.dispose();
//     _scrollProgress.dispose();
//     super.dispose();
//   }

//   void _updateScrollProgress() {
//     if (!_scrollController.hasClients) return;
//     final max = _scrollController.position.maxScrollExtent;
//     if (max <= 0) return;
//     _scrollProgress.value = _scrollController.offset / max;
//   }

//   Future<BlogPost> _loadBlogPost() async {
//     final slug = widget.slug;

//     if (_cache.containsKey(slug)) {
//       final post = _cache.remove(slug)!;
//       _cache[slug] = post;
//       _initialize(post);
//       return post;
//     }

//     final post = await BlogService().fetchBySlug(slug);

//     _cache[slug] = post;
//     if (_cache.length > _maxCacheSize) {
//       _cache.remove(_cache.keys.first);
//     }

//     _initialize(post);
//     return post;
//   }

//   void _initialize(BlogPost post) {
//     _headingKeys.clear();

//     for (var item in post.content) {
//       if (item.type == ContentType.heading) {
//         _headingKeys.add(GlobalKey());
//       }
//     }

//     if (kIsWeb) {
//       MetaService.setBreadcrumbData(
//         title: post.title,
//         slug: widget.slug,
//         parents: [
//           {'name': 'Blog', 'url': _baseBlogUrl},
//         ],
//       );
//     }
//   }



//   void _scrollToHeading(int index) {
//     if (index < _headingKeys.length &&
//         _headingKeys[index].currentContext != null) {
//       Scrollable.ensureVisible(
//         _headingKeys[index].currentContext!,
//         duration: const Duration(milliseconds: 300),
//       );
//     }
//   }

//   void _copyCode(String code) {
//     Clipboard.setData(ClipboardData(text: code));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Copied')),
//     );
//   }

//   /// ✅ ONLY SHARE SOURCE
//   Future<void> _sharePost(BlogPost post) async {
//     final text =
//         '${post.title}\n\nRead more:\n$_baseBlogUrl/${widget.slug}';
//     await Share.share(text);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<BlogPost>(
//       future: _futurePost,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//       // In build(), inside FutureBuilder:
// if (snapshot.hasError) {
//   return Scaffold(
//     body: BlogErrorWidget(
//       onRetry: () => setState(() => _futurePost = _loadBlogPost()),
//       message: 'Could not load this article.',
//     ),
//   );
// }

//         final post = snapshot.data!;

//         return Scaffold(
//           // appBar: _ModernAppBar(
//           //   post: post,
//           //   scrollProgress: _scrollProgress,
//           //   onBack: () => Navigator.pop(context),
//           //   onShare: () => _sharePost(post), // ✅ ONLY HERE
//           //   onBookmark: () {},
//           // ),
//           body: _getDesign(post),
//         );
//       },
//     );
//   }

//   Widget _getDesign(BlogPost post) {
//     switch (post.design) {
//       // case BlogDesign.minimal:
//       //   return MinimalBlogDesign(
//       //     post: post,
//       //     scrollController: _scrollController,
//       //     onCopyCode: _copyCode,
//       //     slug: widget.slug,
//       //   );

//       // case BlogDesign.magazine:
//       //   return MagazineBlogDesign(
//       //     post: post,
//       //     scrollController: _scrollController,
//       //     onCopyCode: _copyCode,
//       //     slug: widget.slug,
//       //   );

//       case BlogDesign.newspaper:
//         return NewspaperBlogDesign1(
//           post: post,
//           scrollController: _scrollController,
//           onCopyCode: _copyCode,
//           slug: widget.slug,
//         );

//       // case BlogDesign.stackedCardBlogDesign:
//       //   return StackedCardBlogDesign(
//       //     post: post,
//       //     scrollController: _scrollController,
//       //     onCopyCode: _copyCode,
//       //     slug: widget.slug,
//       //   );

//       // case BlogDesign.coverstory:
//       //   return CoverStoryBlogDesign(
//       //     post: post,
//       //     scrollController: _scrollController,
//       //     onCopyCode: _copyCode,
//       //     slug: widget.slug,
//       //   );

//       default:
//         return NewspaperBlogDesign1(
//           post: post,
//        scrollController: _scrollController,
//           onCopyCode: _copyCode,
//           slug: widget.slug,
//         );
//     }
//   }
// }

// // ================= APPBAR =================
// class _ModernAppBar extends StatelessWidget
//     implements PreferredSizeWidget {
//   final BlogPost post;
//   final ValueNotifier<double> scrollProgress;
//   final VoidCallback onBack;
//   final VoidCallback onShare;
//   final VoidCallback onBookmark;

//   const _ModernAppBar({
//     required this.post,
//     required this.scrollProgress,
//     required this.onBack,
//     required this.onShare,
//     required this.onBookmark,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return ValueListenableBuilder<double>(
//       valueListenable: scrollProgress,
//       builder: (context, progress, _) {
//         final isScrolled = progress > 0.02;

//         return AppBar(
//           elevation: isScrolled ? 4 : 0,
//           backgroundColor:
//               isScrolled ? Colors.white : Colors.white.withValues(alpha: 0.85),
//           automaticallyImplyLeading: false,

//           title: Row(
//             children: [
//               _icon(Icons.arrow_back, onBack),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   post.title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: theme.textTheme.titleMedium!
//                       .copyWith(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),

//           actions: [
//             _icon(Icons.share, onShare), // ✅ ONLY SHARE
//             _icon(Icons.bookmark_border, onBookmark),
//           ],
//         );
//       },
//     );
//   }

//   Widget _icon(IconData icon, VoidCallback onTap) {
//     return IconButton(icon: Icon(icon), onPressed: onTap);
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
