// widgets/blog_designs.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:revochampblog/core/theme.dart';
import 'package:revochampblog/models/blog_post.dart';
import 'package:revochampblog/models/content_item.dart';
import 'package:revochampblog/widgets/content_widget.dart';
import 'package:revochampblog/widgets/blog_meta_widget.dart';
import 'package:revochampblog/widgets/tag_chips.dart';
import 'package:revochampblog/widgets/share_buttons.dart';

// ========== HELPER MIXIN ==========

/// Mixin to build content items consistently across designs.
mixin ContentBuilder {
  List<Widget> buildContentItems(
    BuildContext context,
    List<ContentItem> content, {
    required Function(String) onCopyCode,
    List<GlobalKey>? headingKeys,
    int? headingIndex,
  }) {
    final widgets = <Widget>[];
    int idx = headingIndex ?? 0;
    for (var i = 0; i < content.length; i++) {
      final item = content[i];
      if (item.type == ContentType.heading) {
        widgets.add(
          Container(
            key: headingKeys != null && idx < headingKeys.length ? headingKeys[idx] : null,
            margin: const EdgeInsets.only(top: 24, bottom: 12),
            child: ContentItemWidget(item: item, onCopy: onCopyCode),
          ),
        );
        idx++;
      } else {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ContentItemWidget(item: item, onCopy: onCopyCode),
          ),
        );
      }
    }
    return widgets;
  }
}

// ========== COMMON HELPER WIDGETS ==========

class TocSidebar extends StatelessWidget {
  final List<ContentItem> headings;
  final List<GlobalKey> headingKeys;
  final Function(int) onHeadingTap;

  const TocSidebar({
    Key? key,
    required this.headings,
    required this.headingKeys,
    required this.onHeadingTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📑 Contents',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(),
            ...headings.asMap().entries.map((entry) {
              final idx = entry.key;
              final heading = entry.value;
              final isValid = idx < headingKeys.length && headingKeys[idx].currentContext != null;
              return InkWell(
                onTap: isValid ? () => onHeadingTap(idx) : null,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    heading.value,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class TocChips extends StatefulWidget {
  final List<ContentItem> headings;
  final List<GlobalKey> headingKeys;
  final Function(int) onHeadingTap;

  const TocChips({
    Key? key,
    required this.headings,
    required this.headingKeys,
    required this.onHeadingTap,
  }) : super(key: key);

  @override
  State<TocChips> createState() => _TocChipsState();
}

class _TocChipsState extends State<TocChips> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 HEADER
        Row(
          children: [
            const Icon(Icons.menu_book, size: 20),
            const SizedBox(width: 6),
            Text(
              "Contents",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 🔥 SCROLLABLE CHIPS
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.headings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final heading = widget.headings[index];

              final isValid = index < widget.headingKeys.length &&
                  widget.headingKeys[index].currentContext != null;

              final isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: isValid
                    ? () {
                        setState(() => selectedIndex = index);
                        widget.onHeadingTap(index);
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.2),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    heading.value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

class FaqSection extends StatefulWidget {
  final List<Map<String, String>> faq;

  const FaqSection({Key? key, required this.faq}) : super(key: key);

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),

        // 🔥 HEADER
        Row(
          children: [
            const Icon(Icons.help_outline),
            const SizedBox(width: 8),
            Text(
              "Frequently Asked Questions",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 🔥 FAQ LIST
        ...widget.faq.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          final isOpen = expandedIndex == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isOpen
                  ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOpen
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.2),
              ),
              boxShadow: isOpen
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 10,
                      )
                    ]
                  : [],
            ),
            child: Column(
              children: [
                // 🔹 QUESTION
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      expandedIndex = isOpen ? null : index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Number
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              theme.colorScheme.primaryContainer,
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Question
                        Expanded(
                          child: Text(
                            item['question'] ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Icon
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: isOpen ? 0.5 : 0,
                          child: const Icon(Icons.expand_more),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 ANSWER
                AnimatedCrossFade(
                  firstChild: const SizedBox(),
                  secondChild: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      item['answer'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  crossFadeState: isOpen
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class RelatedPostsSection extends StatelessWidget {
  final List<String> relatedSlugs;
  final Function(String) onTap;

  const RelatedPostsSection({
    Key? key,
    required this.relatedSlugs,
    required this.onTap,
  }) : super(key: key);

  String _formatTitle(String slug) {
    return slug
        .replaceFirst('blog-', '')
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (relatedSlugs.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 1),
        const SizedBox(height: 16),

        // 📰 Header (newspaper style)
        const Text(
          "RELATED ARTICLES",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontFamily: 'Times New Roman',
          ),
        ),
        const SizedBox(height: 12),

        // 📋 List
        ...relatedSlugs.map((slug) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => onTap(slug),
              child: Text(
                _formatTitle(slug),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}



enum AdType { banner, inline, rectangle }

class AdPlaceholder extends StatelessWidget {
  final AdType type;

  const AdPlaceholder({
    Key? key,
    this.type = AdType.inline,
  }) : super(key: key);

  double _getHeight() {
    switch (type) {
      case AdType.banner:
        return 60;
      case AdType.rectangle:
        return 250;
      case AdType.inline:
      default:
        return 120;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: _getHeight(),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Stack(
        children: [
          // 🔹 CENTER TEXT
          Center(
            child: Text(
              'Advertisement',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),

          // 🔹 LABEL (TOP RIGHT)
          Positioned(
            top: 6,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Ad",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== DESIGN 1: CLASSIC ==========

class ClassicBlogDesign extends StatelessWidget with ContentBuilder {
  final BlogPost post;
  final List<GlobalKey> headingKeys;
  final ScrollController scrollController;
  final Function(int) onHeadingTap;
  final Function(String) onCopyCode;
  final String slug;

  const ClassicBlogDesign({
    Key? key,
    required this.post,
    required this.headingKeys,
    required this.scrollController,
    required this.onHeadingTap,
    required this.onCopyCode,
    required this.slug,
  }) : super(key: key);

  List<ContentItem> get _headings =>
      post.content.where((item) => item.type == ContentType.heading).toList();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1000;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: isDesktop && _headings.isNotEmpty
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 TOC SIDEBAR (IMPROVED LOOK)
                Container(
                  width: 280,
                  margin: const EdgeInsets.all(12),
                  child: TocSidebar(
                    headings: _headings,
                    headingKeys: headingKeys,
                    onHeadingTap: onHeadingTap,
                  ),
                ),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: _buildMainContent(context),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: _buildMainContent(context),
              ),
            ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      children: [
        // 🔥 HERO CARD (UPGRADED)
        Container(
          decoration: BoxDecoration(
            gradient: primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  post.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              if (post.subtitle.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  post.subtitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              BlogMetaWidget(post: post),
              const SizedBox(height: 10),
              if (post.categories.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: post.categories.map((cat) {
                    return Chip(
                      label: Text(cat),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      labelStyle: const TextStyle(color: Colors.white),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 📑 TOC (Mobile)
        if (!isDesktop && _headings.isNotEmpty)
          TocChips(
            headings: _headings,
            headingKeys: headingKeys,
            onHeadingTap: onHeadingTap,
          ),

        // 🔥 CONTENT CARD (NEW)
        Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ...buildContentItems(
        context,
        post.content,
        onCopyCode: onCopyCode,
        headingKeys: headingKeys,
      ),
    ],
  ),
),

        const SizedBox(height: 30),

        // 🔥 AD (BETTER SPACING)
        const AdPlaceholder(),

        const SizedBox(height: 30),

        // 🏷 TAGS
        if (post.tags.isNotEmpty) ...[
          TagChips(tags: post.tags),
          const SizedBox(height: 20),
        ],

        // 🔗 SHARE
        ShareButtons(
          url: 'https://yourdomain.com/blog/$slug',
          title: post.title,
        ),

        const SizedBox(height: 30),

        // ❓ FAQ
        if (post.faq != null && post.faq!.isNotEmpty)
          FaqSection(faq: post.faq!),

        // 🔗 RELATED POSTS
        if (post.related.isNotEmpty)
          RelatedPostsSection(
            relatedSlugs: post.related,
            onTap: (slug) =>
                Navigator.pushReplacementNamed(context, '/blog/$slug'),
          ),

        const SizedBox(height: 30),

        // 🔥 BOTTOM AD
        const AdPlaceholder(),
      ],
    );
  }
}

// // ========== DESIGN 2: MINIMAL ==========
// class MinimalBlogDesign extends StatelessWidget with ContentBuilder {
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
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDesktop = MediaQuery.of(context).size.width > 900;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: Center(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxWidth: isDesktop ? 820 : double.infinity),
//           child: ListView(
//             controller: scrollController,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//             children: [
//               // 🔥 FEATURED IMAGE
//               if (post.featuredImage != null)
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: CachedNetworkImage(
//                     imageUrl: post.featuredImage!,
//                     height: 280,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Container(
//                       height: 280,
//                       color: Colors.grey[200],
//                       child: const Center(child: CircularProgressIndicator()),
//                     ),
//                     errorWidget: (context, url, error) => Container(
//                       height: 280,
//                       color: Colors.grey[200],
//                       child: const Icon(Icons.broken_image, size: 48),
//                     ),
//                   ),
//                 ),

//               const SizedBox(height: 28),

//               // 🧠 TITLE (SEO H1)
//               Semantics(
//                 header: true,
//                 child: Text(
//                   post.title,
//                   style: theme.textTheme.displaySmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     height: 1.3,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),

//               const SizedBox(height: 14),

//               // ✨ SUBTITLE
//               if (post.subtitle.isNotEmpty)
//                 Text(
//                   post.subtitle,
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     height: 1.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//               const SizedBox(height: 20),

//               // 👤 META INFO (IMPROVED)
//               Center(
//                 child: Wrap(
//                   alignment: WrapAlignment.center,
//                   spacing: 16,
//                   runSpacing: 6,
//                   children: [
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.person, size: 14),
//                         const SizedBox(width: 6),
//                         Text(post.author, style: theme.textTheme.bodySmall),
//                       ],
//                     ),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.calendar_today, size: 14),
//                         const SizedBox(width: 6),
//                         Text(
//                           DateFormat.yMMMd().format(
//                             DateTime(post.date.year, post.date.month, post.date.day),
//                           ),
//                           style: theme.textTheme.bodySmall,
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.access_time, size: 14),
//                         const SizedBox(width: 6),
//                         Text(post.readTime, style: theme.textTheme.bodySmall),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // 🔥 TOP AD
//               const AdPlaceholder(),
//               const SizedBox(height: 30),

//               // 📝 CONTENT (READABILITY IMPROVED)
//               ...buildContentItems(
//                 context,
//                 post.content,
//                 onCopyCode: onCopyCode,
//               ),

//               const SizedBox(height: 40),

//               // 🔥 MID AD
//               const AdPlaceholder(),
//               const SizedBox(height: 24),

//               // 🏷 TAGS
//               if (post.tags.isNotEmpty) ...[
//                 TagChips(tags: post.tags),
//                 const SizedBox(height: 20),
//               ],

//               // 🔗 SHARE BUTTONS
//               ShareButtons(
//                 url: 'https://yourdomain.com/blog/$slug',
//                 title: post.title,
//               ),

//               const SizedBox(height: 30),

//               // ❓ FAQ
//               if (post.faq != null && post.faq!.isNotEmpty)
//                 FaqSection(faq: post.faq!),

//               // 🔗 RELATED POSTS
//               if (post.related.isNotEmpty)
//                 RelatedPostsSection(
//                   relatedSlugs: post.related,
//                   onTap: (slug) =>
//                       Navigator.pushReplacementNamed(context, '/blog/$slug'),
//                 ),

//               const SizedBox(height: 40),

//               // 🔥 BOTTOM AD
//               const AdPlaceholder(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ========== DESIGN 3: MAGAZINE ==========

class MagazineBlogDesign extends StatelessWidget with ContentBuilder {
  final BlogPost post;
  final ScrollController scrollController;
  final Function(String) onCopyCode;
  final String slug;

  const MagazineBlogDesign({
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
      body: Stack(
        children: [
          CustomScrollView(
            controller: scrollController,
            slivers: [
              // 🔥 HERO SECTION
              SliverAppBar(
                expandedHeight: 420,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      post.featuredImage != null
                          ? CachedNetworkImage(
                              imageUrl: post.featuredImage!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[300]),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 48),
                              ),
                            )
                          : Container(color: Colors.grey[300]),

                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                              Colors.black.withOpacity(0.9),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // Bottom Info
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Categories
                            if (post.categories.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                children: post.categories.map((cat) {
                                  return Chip(
                                    label: Text(cat),
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    labelStyle: const TextStyle(color: Colors.white),
                                  );
                                }).toList(),
                              ),

                            const SizedBox(height: 10),

                            // H1 Title (SEO)
                            Semantics(
                              header: true,
                              child: Text(
                                post.title,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Meta Info
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Text(post.author,
                                    style: const TextStyle(color: Colors.white70)),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Text(post.readTime,
                                    style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 📄 CONTENT SECTION
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 900 : double.infinity,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Subtitle
                          if (post.subtitle.isNotEmpty) ...[
                            Text(
                              post.subtitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Author Section
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundImage: post.authorAvatar != null
                                    ? NetworkImage(post.authorAvatar!)
                                    : null,
                                child: post.authorAvatar == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.author,
                                      style: theme.textTheme.titleMedium),
                                  Text(
                                    DateFormat.yMMMd().format(DateTime(
                                        post.date.year,
                                        post.date.month,
                                        post.date.day)),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // 🔥 Top Ad
                          const AdPlaceholder(),
                          const SizedBox(height: 30),

                          // 📝 Content
                          ...buildContentItems(
                            context,
                            post.content,
                            onCopyCode: onCopyCode,
                          ),

                          const SizedBox(height: 40),

                          // 🔥 Mid Ad
                          const AdPlaceholder(),
                          const SizedBox(height: 30),

                          // Tags
                          if (post.tags.isNotEmpty) ...[
                            TagChips(tags: post.tags),
                            const SizedBox(height: 20),
                          ],

                          // FAQ
                          if (post.faq != null && post.faq!.isNotEmpty)
                            FaqSection(faq: post.faq!),

                          // Related Posts
                          if (post.related.isNotEmpty)
                            RelatedPostsSection(
                              relatedSlugs: post.related,
                              onTap: (slug) => Navigator.pushReplacementNamed(
                                  context, '/blog/$slug'),
                            ),

                          const SizedBox(height: 40),

                          // 🔥 Bottom Ad
                          const AdPlaceholder(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 🔗 Floating Share Button (Improved)
          Positioned(
            right: 20,
            bottom: 100,
            child: FloatingActionButton.extended(
              backgroundColor: theme.colorScheme.primary,
              onPressed: () => Share.share(
                '${post.title}\n\nhttps://yourdomain.com/blog/$slug',
              ),
              icon: const Icon(Icons.share),
              label: const Text("Share"),
            ),
          ),
        ],
      ),
    );
  }
}// ========== DESIGN 4: DARK (Theme Variation) ==========



class DarkBlogDesign extends StatelessWidget with ContentBuilder {
  final BlogPost post;
  final ScrollController scrollController;
  final Function(String) onCopyCode;
  final String slug;

  const DarkBlogDesign({
    Key? key,
    required this.post,
    required this.scrollController,
    required this.onCopyCode,
    required this.slug,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a dark theme variant – this can be replaced with a global dark mode toggle
    final darkTheme = ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Colors.cyanAccent,
        secondary: Colors.cyanAccent,
        surface: Color(0xFF1E1E1E),
      ),
      cardColor: const Color(0xFF2C2C2C),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
    );

    return Theme(
      data: darkTheme,
      child: Scaffold(
        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              title: Text(post.title),
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [darkTheme.colorScheme.primary, darkTheme.colorScheme.surface],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (post.featuredImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: post.featuredImage!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 250,
                            color: Colors.grey[800],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 250,
                            color: Colors.grey[800],
                            child: const Icon(Icons.broken_image, size: 48),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    ...buildContentItems(context, post.content, onCopyCode: onCopyCode),
                    const SizedBox(height: 32),
                    ShareButtons(
                      url: 'https://yourdomain.com/blog/$slug',
                      title: post.title,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== DESIGN 5: VIDEO ==========
class VideoBlogDesign extends StatelessWidget with ContentBuilder {
  final BlogPost post;
  final ScrollController scrollController;
  final Function(String) onCopyCode;
  final String slug;

  const VideoBlogDesign({
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
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          // 🔥 HERO SECTION (IMPROVED)
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                post.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 🎬 Video or Image
                  post.videoUrl != null
                      ? VideoPlayerWidget(videoUrl: post.videoUrl!)
                      : (post.featuredImage != null
                          ? CachedNetworkImage(
                              imageUrl: post.featuredImage!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.grey[300])),

                  // 🌑 Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // ▶ Play Button Overlay (only if video)
                  if (post.videoUrl != null)
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // 📌 Bottom Info
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categories
                        if (post.categories.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: post.categories.map((cat) {
                              return Chip(
                                label: Text(cat),
                                backgroundColor: Colors.white.withOpacity(0.2),
                                labelStyle: const TextStyle(color: Colors.white),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 10),

                        // Title (Big)
                        Text(
                          post.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Meta Info
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Text(post.author, style: const TextStyle(color: Colors.white70)),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Text(post.readTime, style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 📄 CONTENT SECTION
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 900 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      if (post.subtitle.isNotEmpty) ...[
                        Text(
                          post.subtitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 🔥 Ad Placeholder (Top)
                      const AdPlaceholder(),
                      const SizedBox(height: 30),

                      // 📝 Content
                      ...buildContentItems(
                        context,
                        post.content,
                        onCopyCode: onCopyCode,
                      ),

                      const SizedBox(height: 40),

                      // 🔥 Ad Middle
                      const AdPlaceholder(),
                      const SizedBox(height: 30),

                      // 🏷 Tags
                      if (post.tags.isNotEmpty) ...[
                        TagChips(tags: post.tags),
                        const SizedBox(height: 20),
                      ],

                      // 🔗 Share
                      ShareButtons(
                        url: 'https://yourdomain.com/blog/$slug',
                        title: post.title,
                      ),

                      const SizedBox(height: 30),

                      // ❓ FAQ
                      if (post.faq != null && post.faq!.isNotEmpty)
                        FaqSection(faq: post.faq!),

                      // 🔗 Related Posts
                      if (post.related.isNotEmpty)
                        RelatedPostsSection(
                          relatedSlugs: post.related,
                          onTap: (slug) =>
                              Navigator.pushReplacementNamed(context, '/blog/$slug'),
                        ),

                      const SizedBox(height: 40),

                      // 🔥 Bottom Ad
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

// Placeholder for a video player – replace with actual implementation (e.g., video_player + chewie)
class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;
  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
      ),
    );
  }
}




class StackedCardBlogDesign extends StatelessWidget with ContentBuilder {
  final BlogPost post;
  final ScrollController scrollController;
  final Function(String) onCopyCode;
  final String slug;

  const StackedCardBlogDesign({
    Key? key,
    required this.post,
    required this.scrollController,
    required this.onCopyCode,
    required this.slug,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          // 🔥 HERO SECTION
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: post.featuredImage != null
                        ? DecorationImage(
                            image: NetworkImage(post.featuredImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),

                // 🌑 Gradient Overlay
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // 👤 AVATAR
                Positioned(
                  bottom: -50,
                  left: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundImage: post.authorAvatar != null
                          ? NetworkImage(post.authorAvatar!)
                          : null,
                      child: post.authorAvatar == null
                          ? const Icon(Icons.person, size: 46)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📄 CONTENT CARD
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 👤 AUTHOR
                      Row(
                        children: [
                          const SizedBox(width: 70),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.author,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat.yMMMd().format(post.date),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 🧠 TITLE
                      Semantics(
                        header: true,
                        child: Text(
                          post.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ✨ SUBTITLE
                      if (post.subtitle.isNotEmpty)
                        Text(
                          post.subtitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // 🔥 TOP AD
                      const AdPlaceholder(),
                      const SizedBox(height: 24),

                      // 📝 CONTENT
                      ...buildContentItems(
                        context,
                        post.content,
                        onCopyCode: onCopyCode,
                      ),

                      const SizedBox(height: 30),

                      // 🔥 MID AD
                      const AdPlaceholder(),
                      const SizedBox(height: 24),

                      // 🏷 TAGS
                      if (post.tags.isNotEmpty) ...[
                        TagChips(tags: post.tags),
                        const SizedBox(height: 20),
                      ],

                      // 🔗 SHARE
                      ShareButtons(
                        url: 'https://yourdomain.com/blog/$slug',
                        title: post.title,
                      ),

                      const SizedBox(height: 30),

                      // ❓ FAQ
                      if (post.faq != null && post.faq!.isNotEmpty)
                        FaqSection(faq: post.faq!),

                      // 🔗 RELATED
                      if (post.related.isNotEmpty)
                        RelatedPostsSection(
                          relatedSlugs: post.related,
                          onTap: (slug) =>
                              Navigator.pushReplacementNamed(context, '/blog/$slug'),
                        ),

                      const SizedBox(height: 30),

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



class CoverStoryBlogDesign extends StatelessWidget with ContentBuilder {
  final BlogPost post;
  final ScrollController scrollController;
  final Function(String) onCopyCode;
  final String slug;

  const CoverStoryBlogDesign({
    Key? key,
    required this.post,
    required this.scrollController,
    required this.onCopyCode,
    required this.slug,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          // 🎬 CINEMATIC HERO
          SliverAppBar(
            expandedHeight: screenHeight * 0.75,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 🖼 HERO IMAGE
                  if (post.featuredImage != null)
                    CachedNetworkImage(
                      imageUrl: post.featuredImage!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: theme.colorScheme.primary),

                  // 🌑 DARK OVERLAY
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // 🧠 HERO CONTENT
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // TITLE
                            Semantics(
                              header: true,
                              child: Text(
                                post.title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // SUBTITLE
                            if (post.subtitle.isNotEmpty)
                              Text(
                                post.subtitle,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),

                            const SizedBox(height: 20),

                            // AUTHOR INFO
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: post.authorAvatar != null
                                      ? NetworkImage(post.authorAvatar!)
                                      : null,
                                  child: post.authorAvatar == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  post.author,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  post.readTime,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 📄 CONTENT SECTION
          SliverToBoxAdapter(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔥 TOP AD
                        const AdPlaceholder(),
                        const SizedBox(height: 30),

                        // 📝 CONTENT (CARD STYLE)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              ...buildContentItems(
                                context,
                                post.content,
                                onCopyCode: onCopyCode,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🔥 MID AD
                        const AdPlaceholder(),
                        const SizedBox(height: 30),

                        // 🏷 TAGS
                        if (post.tags.isNotEmpty) ...[
                          TagChips(tags: post.tags),
                          const SizedBox(height: 20),
                        ],

                        // 🔗 SHARE
                        ShareButtons(
                          url: 'https://yourdomain.com/blog/$slug',
                          title: post.title,
                        ),

                        const SizedBox(height: 30),

                        // ❓ FAQ
                        if (post.faq != null && post.faq!.isNotEmpty)
                          FaqSection(faq: post.faq!),

                        // 🔗 RELATED
                        if (post.related.isNotEmpty)
                          RelatedPostsSection(
                            relatedSlugs: post.related,
                            onTap: (slug) => Navigator.pushReplacementNamed(
                                context, '/blog/$slug'),
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
          ),
        ],
      ),
    );
  }
}