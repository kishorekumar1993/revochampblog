import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:revochampblog/widgets/blog_designs.dart';
import 'package:revochampblog/widgets/content_widget.dart';
import 'package:revochampblog/widgets/share_buttons.dart';
import 'package:revochampblog/models/content_item.dart';

import '../../models/blog_post.dart';

///News Paper
///
class NewspaperBlogDesign extends StatelessWidget {
  final BlogPost post;
  final ScrollController scrollController;
  final Function(String) onCopyCode;
  final String slug;

  const NewspaperBlogDesign({
    Key? key,
    required this.post,
    required this.scrollController,
    required this.onCopyCode,
    required this.slug,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final Map<String, GlobalKey> headingKeys = {};
    double width = MediaQuery.of(context).size.width;

    double titleSize = width > 1200
        ? 40
        : width > 900
        ? 36
        : width > 600
        ? 32
        : 26;

    double bodysize = width > 1200
        ? 16
        : width > 900
        ? 14
        : width > 600
        ? 14
        : 12;

    double lineHeight = width > 600 ? 1.2 : 1.3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          // 📰 NEWSPAPER HEADER
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Column(
              children: const [
                Text(
                  'THE DAILY BLOG',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Divider(thickness: 1),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 940),
                  // constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      // 🧠 HEADLINE
                      Semantics(
                        header: true,
                        child: Text(
                          post.title,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Times New Roman',
                            height: lineHeight,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ✨ SUBTITLE
                      if (post.subtitle.isNotEmpty)
                        Text(
                          post.subtitle,
                          style: TextStyle(
                            fontSize: bodysize,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 16),

                      // // Byline + Categories + Tags
                      // Wrap(
                      //   alignment: WrapAlignment.center,
                      //   children: [
                      //     Text(
                      //       'By ${post.author} • ${DateFormat.yMMMd().format(post.date)} • ${post.readTime}',
                      //       style: TextStyle(
                      //         fontSize: 13,
                      //         color: Colors.grey[600],
                      //       ),
                      //     ),
                      //     const SizedBox(width: 8),

                      //     if (post.categories.isNotEmpty)
                      //       Text(
                      //         post.categories.join(' • '),
                      //         style: TextStyle(
                      //           fontSize: 12,
                      //           color: Colors.grey[700],
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     const SizedBox(width: 8),
                      //     if (post.tags.isNotEmpty)
                      //       Text(
                      //         post.tags.map((t) => '#$t').join(' '),
                      //         style: TextStyle(
                      //           fontSize: 12,
                      //           color: Colors.grey[700],
                      //           fontStyle: FontStyle.italic,
                      //         ),
                      //       ),
                      //   ],
                      // ),
                      const SizedBox(height: 20),

                      const Divider(thickness: 1),

                      const SizedBox(height: 24),

                      // 🧩 LAYOUT
                      isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: _buildMainContent()),
                                const SizedBox(width: 40),
                                Expanded(
                                  flex: 1,
                                  child: DynamicSidebar(
                                    post: post,
                                    scrollController: scrollController,
                                    headingKeys:
                                        headingKeys, // you must build this from the post content
                                    onRelatedTap: (slug) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/blog/$slug',
                                      );
                                    },
                                    onTagTap: (tag) {
                                      // e.g., Navigator.pushNamed(context, '/tag/$tag');
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Tag: $tag')),
                                      );
                                    },
                                    onSearch: (query) {
                                      // e.g., Navigator.pushNamed(context, '/search?q=$query');
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Search for: $query'),
                                        ),
                                      );
                                    },
                                  ),
                                  //  _buildSidebar(context),
                                ),
                              ],
                            )
                          : _buildMainContent(),

                      const SizedBox(height: 30),

                      // ❓ FAQ
                      if (post.faq != null && post.faq!.isNotEmpty)
                        FaqSection(faq: post.faq!),
                      // 🔗 RELATED POSTS
                      if (post.related.isNotEmpty)
                        RelatedPostsSection(
                          related: post.related,
                          onTap: (slug) => Navigator.pushReplacementNamed(
                            context,
                            '/blog/$slug',
                          ),
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

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🖼 IMAGE
        if (post.featuredImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: post.featuredImage!,
              fit: BoxFit.cover,
            ),
          ),

        const SizedBox(height: 24),

        // 🔥 TOP AD
        // const AdPlaceholder(),
        const SizedBox(height: 24),

        // ✍ CONTENT
        ..._buildContentWithDropCap(),

        const SizedBox(height: 30),

        const Divider(),

        const SizedBox(height: 20),

        // 🔗 SHARE
        ShareButtons(
          url: 'https://yourdomain.com/blog/$slug',
          title: post.title,
        ),
      ],
    );
  }

  List<Widget> _buildContentWithDropCap() {
    final widgets = <Widget>[];
    bool first = true;

    for (var item in post.content) {
      if (item.type == ContentType.text && first) {
        // widgets.add(
        //   RichText(
        //     text: TextSpan(
        //       children: [
        //         TextSpan(
        //           text: item.value[0],
        //           style: const TextStyle(
        //             fontSize: 60,
        //             fontWeight: FontWeight.bold,
        //             fontFamily: 'Times New Roman',
        //           ),
        //         ),
        //         TextSpan(
        //           text: item.value.substring(1),
        //           style: const TextStyle(
        //             fontSize: 16,
        //             height: 1.8,
        //             color: Colors.black,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // );
     
     widgets.add(buildParagraphs(item.value));
        first = false;
      } else if (item.type == ContentType.table) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: buildTable(headers: item.headers!, rows: item.rows!),
          ),
        );
      } else if (item.type == ContentType.heading) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: Text(
              item.value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'Times New Roman',
              ),
            ),
          ),
        );
      } else if (item.type == ContentType.list) {
        widgets.add(ListWidget(data: item.value, raw: null,));
      } else if (item.type == ContentType.image) {
        if (item.imageUrl != null) {
          widgets.add(
            CachedNetworkImage(
              imageUrl: item.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image),
            ),
          );
        }
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(item.value, style: const TextStyle(height: 1.8)),
          ),
        );
      }
    }

    return widgets;
  }

Widget buildParagraphs(String text) {
  final paragraphs = text.split('\n\n');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildDropCapParagraph(paragraphs.first),
      ...paragraphs.skip(1).map(buildNormalParagraph),
    ],
  );
}
Widget buildNormalParagraph(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: RichText(
      text: TextSpan(
        children: _parseRichText(text),
        style: const TextStyle(
          fontSize: 16,
          height: 1.8,
          color: Colors.black87,
        ),
      ),
    ),
  );
}
List<InlineSpan> _parseRichText(String text) {
  final List<InlineSpan> spans = [];

  final RegExp exp = RegExp(r'\*\*(.*?)\*\*');
  int start = 0;

  for (final match in exp.allMatches(text)) {
    // Normal text before bold
    if (match.start > start) {
      spans.add(TextSpan(text: text.substring(start, match.start)));
    }

    final boldText = match.group(1) ?? '';

    // 🔥 Special handling for labels (ending with :)
    if (boldText.trim().endsWith(':')) {
      spans.add(
        WidgetSpan(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              boldText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    } else {
      // Normal bold
      spans.add(
        TextSpan(
          text: boldText,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    start = match.end;
  }

  // Remaining text
  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start)));
  }

  return spans;
}

Widget buildDropCapParagraph(String text) {
  if (text.isEmpty) return const SizedBox();

  // 1. Parse the whole paragraph into spans (bold, labels, normal text)
  final spans = _parseRichText(text);

  // 2. Find the first TextSpan that actually contains visible characters
  int firstTextSpanIndex = -1;
  for (int i = 0; i < spans.length; i++) {
    final span = spans[i];
    if (span is TextSpan && (span.text?.trim().isNotEmpty ?? false)) {
      firstTextSpanIndex = i;
      break;
    }
  }

  // 3. If there is no text span, fall back to normal rendering
  if (firstTextSpanIndex == -1) {
    return buildNormalParagraph(text);
  }

  final TextSpan firstTextSpan = spans[firstTextSpanIndex] as TextSpan;
  final String fullText = firstTextSpan.text!;
  final firstChar = fullText[0];
  final remainingText = fullText.substring(1);

  // 4. Rebuild the spans with the first character split out
  final List<InlineSpan> newSpans = [];

  // Add all spans that appear BEFORE the target TextSpan unchanged
  newSpans.addAll(spans.sublist(0, firstTextSpanIndex));

  // Add the drop‑cap character as a WidgetSpan (big letter)
  newSpans.add(
    WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Text(
        firstChar,
        style: const TextStyle(
          fontSize: 64,
          height: 1,
          fontWeight: FontWeight.bold,
          fontFamily: 'Times New Roman',
        ),
      ),
    ),
  );

  // Add the remaining part of the split TextSpan
  if (remainingText.isNotEmpty) {
    newSpans.add(
      TextSpan(
        text: remainingText,
        style: firstTextSpan.style,
      ),
    );
  }

  // Add all spans that come AFTER the target TextSpan
  newSpans.addAll(spans.sublist(firstTextSpanIndex + 1));

  // 5. Render everything in a RichText with a row for alignment
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The drop cap is already inside the RichText, but we need to add
        // some left spacing to make room for the big letter. However,
        // the RichText will handle wrapping around it automatically.
        // For better control, we embed the whole RichText in an Expanded.
        Expanded(
          child: RichText(
            text: TextSpan(
              children: newSpans,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

List<TextSpan> _parseBoldText(String text) {
  final List<TextSpan> spans = [];
  final RegExp exp = RegExp(r'\*\*(.*?)\*\*');

  int start = 0;

  for (final match in exp.allMatches(text)) {
    if (match.start > start) {
      spans.add(TextSpan(text: text.substring(start, match.start)));
    }

    spans.add(
      TextSpan(
        text: match.group(1) ?? '',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );

    start = match.end;
  }

  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start)));
  }

  return spans;
}

  Widget buildTable({
    //  Widget buildPremiumTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    if (headers.isEmpty || rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(color: Colors.grey.shade100),
              child: Row(
                children: List.generate(headers.length, (index) {
                  return Expanded(
                    flex: index == headers.length - 1 ? 2 : 1,
                    child: Text(
                      headers[index],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  );
                }),
              ),
            ),

            /// BODY
            ...rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;

              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.white : Colors.grey.shade50,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(row.length, (i) {
                    return Expanded(
                      flex: i == row.length - 1 ? 2 : 1,
                      child: Text(
                        row[i],
                        style: const TextStyle(fontSize: 13.5, height: 1.5),
                      ),
                    );
                  }),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📝 QUOTE
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Colors.black, width: 3)),
          ),
          child: Text(
            '“${post.subtitle}”',
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ),

        const SizedBox(height: 24),

        // 👤 AUTHOR
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: post.authorAvatar != null
                      ? NetworkImage(post.authorAvatar!)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  post.author,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text("Staff Writer", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Divider(),

        const SizedBox(height: 12),
      ],
    );
  }
}

class RelatedPostsSection extends StatelessWidget {
  final List<String> related;
  final Function(String) onTap;

  const RelatedPostsSection({
    Key? key,
    required this.related,
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
    if (related.isEmpty) return const SizedBox();

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
        ...related.map((slug) {
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

class FaqSection extends StatefulWidget {
  final List<Map<String, String>> faq;

  const FaqSection({super.key, required this.faq});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Divider(thickness: 1),
        const SizedBox(height: 20),

        // 📖 Header (newspaper style)
        Text(
          "FREQUENTLY ASKED QUESTIONS",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),

        // 📋 FAQ List
        ...widget.faq.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isOpen = expandedIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                0,
              ), // square corners for newspaper feel
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                // ❓ Question
                InkWell(
                  onTap: () {
                    setState(() {
                      expandedIndex = isOpen ? null : index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 0,
                    ),
                    child: Row(
                      children: [
                        // Number (optional, but adds structure)
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['question'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: isOpen ? 0.5 : 0,
                          child: Icon(
                            Icons.expand_more,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 📝 Answer (animated)
                AnimatedCrossFade(
                  firstChild: const SizedBox(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(bottom: 16, right: 40),
                    child: Text(
                      item['answer'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                        fontFamily: 'Times New Roman',
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

class DynamicSidebar extends StatefulWidget {
  final BlogPost post;
  final ScrollController scrollController;
  final Map<String, GlobalKey> headingKeys;
  final Function(String) onTagTap; // optional, for filtering
  final Function(String) onRelatedTap; // optional, for navigation
  final Function(String) onSearch; // optional, for search

  const DynamicSidebar({
    super.key,
    required this.post,
    required this.scrollController,
    required this.headingKeys,
    required this.onTagTap,
    required this.onRelatedTap,
    required this.onSearch,
  });

  @override
  State<DynamicSidebar> createState() => _DynamicSidebarState();
}

class _DynamicSidebarState extends State<DynamicSidebar> {
  String? activeHeading;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // Find the heading closest to the top of the viewport
    String? closestHeading;
    double closestDistance = double.infinity;
    final screenTop = 100.0; // offset to consider heading visible

    for (final entry in widget.headingKeys.entries) {
      final key = entry.value;
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero).dy;
        if (position <= screenTop && position >= 0) {
          // heading is above or at the top threshold
          final distance = screenTop - position;
          if (distance < closestDistance) {
            closestDistance = distance;
            closestHeading = entry.key;
          }
        }
      }
    }

    // If no heading above threshold, take the first one below threshold
    if (closestHeading == null) {
      for (final entry in widget.headingKeys.entries) {
        final context = entry.value.currentContext;
        if (context != null) {
          final box = context.findRenderObject() as RenderBox;
          final position = box.localToGlobal(Offset.zero).dy;
          if (position > screenTop) {
            closestHeading = entry.key;
            break;
          }
        }
      }
    }

    if (closestHeading != activeHeading) {
      setState(() {
        activeHeading = closestHeading;
      });
    }
  }

  void _scrollTo(String heading) {
    final key = widget.headingKeys[heading];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final headings = widget.headingKeys.keys.toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔍 SEARCH
          _search(),

          const SizedBox(height: 24),

          /// 📌 TOC
          if (headings.isNotEmpty) ...[
            _toc(headings),
            const SizedBox(height: 24),
          ],

          /// 👤 AUTHOR
          _author(),

          const SizedBox(height: 24),

          /// 🚀 CTA
          _cta(),

          const SizedBox(height: 24),

          /// 🔥 RELATED
          if (widget.post.related.isNotEmpty) ...[
            _related(),
            const SizedBox(height: 24),
          ],

          /// 🏷 TAGS
          if (widget.post.tags.isNotEmpty) ...[
            _tags(),
            const SizedBox(height: 24),
          ],

          /// 📬 NEWSLETTER
          _newsletter(),
        ],
      ),
    );
  }

  /// 🔍 SEARCH
  Widget _search() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SEARCH',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onSubmitted: (value) {
            if (widget.onSearch != null) widget.onSearch!(value);
          },
          decoration: InputDecoration(
            hintText: 'Search articles...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  /// 📌 TOC
  Widget _toc(List<String> headings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONTENTS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ...headings.map((heading) {
          final isActive = heading == activeHeading;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: () => _scrollTo(heading),
              child: Row(
                children: [
                  Container(
                    width: 2,
                    height: 12,
                    color: isActive ? Colors.black : Colors.transparent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      heading,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isActive ? Colors.black : Colors.grey.shade700,
                        fontFamily: 'Times New Roman',
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 👤 AUTHOR
  Widget _author() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ABOUT THE AUTHOR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: widget.post.authorAvatar != null
                    ? NetworkImage(widget.post.authorAvatar!)
                    : null,
                child: widget.post.authorAvatar == null
                    ? Text(
                        widget.post.author.isNotEmpty
                            ? widget.post.author[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(fontSize: 20),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Times New Roman',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.post.author ?? 'Staff writer at RevoChamp.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🚀 CTA
  Widget _cta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRY NOW',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            // You can replace with actual URL
            // openUrl('https://revochamp.com');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.black),
            ),
            child: const Text(
              '🚀 Build UI with RevoChamp',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: 'Times New Roman',
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🔥 RELATED POSTS
  Widget _related() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RELATED',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.post.related.map((slug) {
          final title = _formatTitle(slug);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                if (widget.onRelatedTap != null) {
                  widget.onRelatedTap!(slug);
                } else {
                  // Default navigation
                  Navigator.pushReplacementNamed(context, '/blog/$slug');
                }
              },
              child: Text(
                '→ $title',
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Times New Roman',
                  height: 1.4,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 🏷 TAGS
  Widget _tags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TAGS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.post.tags.map((tag) {
            return GestureDetector(
              onTap: () {
                if (widget.onTagTap != null) {
                  widget.onTagTap!(tag);
                } else {
                  // Default: just print or could navigate to tag page
                  debugPrint('Tag tapped: $tag');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: Text(
                  '#$tag',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Times New Roman',
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 📬 NEWSLETTER
  Widget _newsletter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NEWSLETTER',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Your email',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          onSubmitted: (email) {
            // Show a snackbar or handle subscription
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Subscribe with $email')));
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            // Could show a dialog for email input
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.black),
            shape: const RoundedRectangleBorder(),
          ),
          child: const Text('SUBSCRIBE'),
        ),
      ],
    );
  }

  /// Helper: format slug to title
  String _formatTitle(String slug) {
    return slug
        .replaceFirst('blog-', '')
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
