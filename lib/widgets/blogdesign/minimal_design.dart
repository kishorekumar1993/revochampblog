// widgets/blog_designs.dart (MinimalBlogDesign)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:revochampblog/models/blog_post.dart';
import 'package:revochampblog/models/content_item.dart';
import 'package:revochampblog/widgets/blog_designs.dart';
import 'package:revochampblog/widgets/content_widget.dart';      // ContentItemWidget
import 'package:revochampblog/widgets/tag_chips.dart';
import 'package:revochampblog/widgets/share_buttons.dart';

// Your existing ContentBuilder mixin (should be imported)
// import 'package:revochampblog/widgets/content_builder.dart';

// ========== DESIGN 2: MINIMAL ==========
class MinimalBlogDesign extends StatelessWidget with ContentBuilder {
  final BlogPost post;
  final ScrollController scrollController;
  final Function(String) onCopyCode;
  final String slug;

  const MinimalBlogDesign({
    Key? key,
    required this.post,
    required this.scrollController,
    required this.onCopyCode,
    required this.slug,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          // Simple app bar (minimal)
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Minimal Blog',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    children: [
                      // 🔥 FEATURED IMAGE
                      if (post.featuredImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: post.featuredImage!,
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 280,
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 280,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: 48),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),

                      // 🧠 TITLE (SEO H1)
                      Semantics(
                        header: true,
                        child: Text(
                          post.title,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ✨ SUBTITLE
                      if (post.subtitle.isNotEmpty)
                        Text(
                          post.subtitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 20),

                      // 👤 META INFO
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 6,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person, size: 14),
                                const SizedBox(width: 6),
                                Text(post.author, style: theme.textTheme.bodySmall),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat.yMMMd().format(post.date),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time, size: 14),
                                const SizedBox(width: 6),
                                Text(post.readTime, style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 🔥 TOP AD
                      const AdPlaceholder(),
                      const SizedBox(height: 30),

                      // 📝 CONTENT
                      ...buildContentItems(
                        context,
                        post.content,
                        onCopyCode: onCopyCode,
                      ),
                      const SizedBox(height: 40),

                      // 🔥 MID AD
                      const AdPlaceholder(),
                      const SizedBox(height: 24),

                      // 🏷 TAGS
                      if (post.tags.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 12),
                        TagChips(tags: post.tags),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 20),
                      ],

                      // 🔗 SHARE BUTTONS
                      ShareButtons(
                        url: 'https://yourdomain.com/blog/$slug',
                        title: post.title,
                      ),
                      const SizedBox(height: 30),

                      // ❓ FAQ (minimal version)
                      if (post.faq != null && post.faq!.isNotEmpty)
                        FaqSection(faq: post.faq!),

                      // 🔗 RELATED POSTS (horizontal)
                      if (post.related.isNotEmpty)
                        RelatedPostsSection(
                          relatedSlugs: post.related,
                          onTap: (slug) =>
                              Navigator.pushReplacementNamed(context, '/blog/$slug'),
                        ),
                      const SizedBox(height: 40),

                      // 🔥 BOTTOM AD
                      const AdPlaceholder(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// // ========== DESIGN 2: MINIMAL (ENHANCED) ==========
// class MinimalBlogDesign extends StatefulWidget {
//   final BlogPost post;
//   final ScrollController scrollController;
//   final Function(String) onCopyCode;
//   final String slug;

//   const MinimalBlogDesign({
//     Key? key,
//     required this.post,
//     required this.scrollController,
//     required this.onCopyCode,
//     required this.slug,
//   }) : super(key: key);

//   @override
//   State<MinimalBlogDesign> createState() => _MinimalBlogDesignState();
// }

// mixin ContentBuilder {
//   List<Widget> buildContentItems(
//     BuildContext context,
//     List<ContentItem> content, {
//     required Function(String) onCopyCode,
//     List<GlobalKey>? headingKeys,
//   }) {
//     final widgets = <Widget>[];
//     int headingIndex = 0;

//     for (var item in content) {
//       if (item.type == ContentType.heading) {
//         widgets.add(
//           Container(
//             key: headingKeys != null && headingIndex < headingKeys.length
//                 ? headingKeys[headingIndex]
//                 : null,
//             margin: const EdgeInsets.only(top: 32, bottom: 12),
//             child: ContentItemWidget(item: item, onCopy: onCopyCode),
//           ),
//         );
//         headingIndex++; // ✅ Important: increment after each heading
//       } else {
//         widgets.add(
//           Container(
//             margin: const EdgeInsets.only(bottom: 16),
//             child: ContentItemWidget(item: item, onCopy: onCopyCode),
//           ),
//         );
//       }
//     }

//     return widgets;
//   }
// }

// class _MinimalBlogDesignState extends State<MinimalBlogDesign>
//     with ContentBuilder {
//   bool _showBackToTop = false;
//   late List<GlobalKey> _headingKeys;
//   late List<String> _headings;

//   @override
//   void initState() {
//     super.initState();

//     // Extract headings from content
//     _headings = widget.post.content
//         .where((item) => item.type == ContentType.heading)
//         .map((item) => item.value)
//         .toList();

//     // Generate a unique key for each heading
//     _headingKeys = List.generate(_headings.length, (_) => GlobalKey());

//     // Listen to scroll to show/hide back‑to‑top button
//     widget.scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     widget.scrollController.removeListener(_onScroll);
//     super.dispose();
//   }

//   void _onScroll() {
//     final shouldShow = widget.scrollController.hasClients &&
//         widget.scrollController.offset > 200;
//     if (shouldShow != _showBackToTop) {
//       setState(() => _showBackToTop = shouldShow);
//     }
//   }

//   void _scrollToHeading(int index) {
//     final context = _headingKeys[index].currentContext;
//     if (context != null) {
//       Scrollable.ensureVisible(
//         context,
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDesktop = MediaQuery.of(context).size.width > 900;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: Stack(
//         children: [
//           Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: isDesktop ? 820 : double.infinity),
//               child: ListView(
//                 controller: widget.scrollController,
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//                 children: [
//                   // 🔥 FEATURED IMAGE
//                   if (widget.post.featuredImage != null)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: CachedNetworkImage(
//                         imageUrl: widget.post.featuredImage!,
//                         height: 280,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                         placeholder: (context, url) => Container(
//                           height: 280,
//                           color: Colors.grey[200],
//                           child: const Center(child: CircularProgressIndicator()),
//                         ),
//                         errorWidget: (context, url, error) => Container(
//                           height: 280,
//                           color: Colors.grey[200],
//                           child: const Icon(Icons.broken_image, size: 48),
//                         ),
//                       ),
//                     ),

//                   const SizedBox(height: 28),

//                   // 🧠 TITLE (SEO H1)
//                   Semantics(
//                     header: true,
//                     child: Text(
//                       widget.post.title,
//                       style: theme.textTheme.displaySmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         height: 1.3,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),

//                   const SizedBox(height: 14),

//                   // ✨ SUBTITLE
//                   if (widget.post.subtitle.isNotEmpty)
//                     Text(
//                       widget.post.subtitle,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         color: theme.colorScheme.onSurface.withOpacity(0.7),
//                         height: 1.5,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),

//                   const SizedBox(height: 20),

//                   // 👤 META INFO
//                   Center(
//                     child: Wrap(
//                       alignment: WrapAlignment.center,
//                       spacing: 16,
//                       runSpacing: 6,
//                       children: [
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.person, size: 14),
//                             const SizedBox(width: 6),
//                             Text(widget.post.author, style: theme.textTheme.bodySmall),
//                           ],
//                         ),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.calendar_today, size: 14),
//                             const SizedBox(width: 6),
//                             Text(
//                               DateFormat.yMMMd().format(widget.post.date),
//                               style: theme.textTheme.bodySmall,
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.access_time, size: 14),
//                             const SizedBox(width: 6),
//                             Text(widget.post.readTime, style: theme.textTheme.bodySmall),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // 📚 TABLE OF CONTENTS (if any headings)
//                   if (_headings.isNotEmpty) ...[
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       decoration: BoxDecoration(
//                         border: Border(
//                           top: BorderSide(color: Colors.grey[300]!),
//                           bottom: BorderSide(color: Colors.grey[300]!),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "CONTENTS",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           ..._headings.asMap().entries.map((entry) {
//                             final index = entry.key;
//                             final title = entry.value;
//                             return InkWell(
//                               onTap: () => _scrollToHeading(index),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 6),
//                                 child: Text(
//                                   "• $title",
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],

//                   // 🔥 TOP AD
//                   const AdPlaceholder(),
//                   const SizedBox(height: 30),

//                   // 📝 CONTENT (pass heading keys)
//                   ...buildContentItems(
//                     context,
//                     widget.post.content,
//                     onCopyCode: widget.onCopyCode,
//                     headingKeys: _headingKeys,
//                   ),

//                   const SizedBox(height: 40),

//                   // 🔥 MID AD
//                   const AdPlaceholder(),
//                   const SizedBox(height: 24),

//                   // 🏷 TAGS
//                   if (widget.post.tags.isNotEmpty) ...[
//                     const Divider(),
//                     const SizedBox(height: 12),
//                     TagChips(tags: widget.post.tags),
//                     const SizedBox(height: 12),
//                     const Divider(),
//                     const SizedBox(height: 20),
//                   ],

//                   // 🔗 SHARE BUTTONS
//                   ShareButtons(
//                     url: 'https://yourdomain.com/blog/${widget.slug}',
//                     title: widget.post.title,
//                   ),

//                   const SizedBox(height: 30),

//                   // ❓ FAQ
//                   if (widget.post.faq != null && widget.post.faq!.isNotEmpty)
//                     FaqSection(faq: widget.post.faq!),

//                   // 🔗 RELATED POSTS (horizontal)
//                   if (widget.post.related.isNotEmpty)
//                     RelatedPostsSection(
//                       relatedSlugs: widget.post.related,
//                       onTap: (slug) =>
//                           Navigator.pushReplacementNamed(context, '/blog/$slug'),
//                     ),

//                   const SizedBox(height: 40),

//                   // 🔥 BOTTOM AD
//                   const AdPlaceholder(),
//                 ],
//               ),
//             ),
//           ),

//           // ⬆️ "Back to top" button (appears after scrolling)
//           if (_showBackToTop)
//             Positioned(
//               bottom: 20,
//               right: 20,
//               child: FloatingActionButton.small(
//                 onPressed: () {
//                   widget.scrollController.animateTo(
//                     0,
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeOut,
//                   );
//                 },
//                 child: const Icon(Icons.arrow_upward),
//                 backgroundColor: theme.colorScheme.primary,
//                 foregroundColor: theme.colorScheme.onPrimary,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class FaqSection extends StatefulWidget {
//   final List<Map<String, String>> faq;

//   const FaqSection({Key? key, required this.faq}) : super(key: key);

//   @override
//   State<FaqSection> createState() => _FaqSectionState();
// }

// class _FaqSectionState extends State<FaqSection> {
//   int? expandedIndex;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Divider(thickness: 1),
//         const SizedBox(height: 24),
//         Text(
//           "Frequently Asked Questions",
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 20),
//         ...widget.faq.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;
//           final isOpen = expandedIndex == index;

//           return Container(
//             margin: const EdgeInsets.only(bottom: 8),
//             decoration: const BoxDecoration(
//               border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
//             ),
//             child: Column(
//               children: [
//                 InkWell(
//                   onTap: () => setState(() => expandedIndex = isOpen ? null : index),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             item['question'] ?? '',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         Icon(
//                           isOpen ? Icons.expand_less : Icons.expand_more,
//                           color: Colors.grey[600],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 if (isOpen)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: Text(
//                       item['answer'] ?? '',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         height: 1.6,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         }),
//       ],
//     );
//   }
// }