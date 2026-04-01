import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revochampblog/models/blog_post.dart';
import 'package:revochampblog/models/content_item.dart';
import 'package:revochampblog/widgets/share_buttons.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS — Premium Editorial
// ─────────────────────────────────────────────────────────────
class _T {
  // Core palette
  static const paper = Color(0xFFFAF9F7);
  static const cream = Color(0xFFF0EEEA);
  static const ink = Color(0xFF0F0D0B);
  static const darkSurface = Color(0xFF1A1814);

  // Accent colors
  static const red = Color(0xFFD84242);
  static const redHover = Color(0xFFC23333);
  static const redLight = Color(0xFFFEE5E5);
  static const gold = Color(0xFFD4A574);
  static const blue = Color(0xFF4A7BA7);
  static const blueLight = Color(0xFFE8EFF7);

  // Neutral palette
  static const muted = Color(0xFF8B8680);
  static const border = Color(0xFFE5E0D8);
  static const divider = Color(0xFFEBE6DE);

  // ── Typography ──────────────────────────────────────────────

  /// Serif display typography
  static TextStyle serif(double size,
      {FontWeight w = FontWeight.w600,
      bool italic = false,
      Color? color,
      double? height,
      double? letterSpacing}) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: w,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        color: color ?? ink,
        height: height ?? 1.2,
        letterSpacing: letterSpacing ?? -0.005 * size,
      );

  /// Modern sans typography
  static TextStyle syne(double size,
      {FontWeight w = FontWeight.w500,
      Color? color,
      double? letterSpacing}) =>
      GoogleFonts.syne(
        fontSize: size,
        fontWeight: w,
        color: color ?? ink,
        letterSpacing: letterSpacing ?? 0.5,
      );

  /// Body text typography
  static TextStyle body(double size,
      {FontWeight w = FontWeight.w300,
      Color? color,
      double? height,
      double? letterSpacing}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: w,
        color: color ?? ink,
        height: height ?? 1.8,
        letterSpacing: letterSpacing ?? 0.2,
      );
}

// ─────────────────────────────────────────────────────────────
//  UTILITIES
// ─────────────────────────────────────────────────────────────
String getJournalName(List<String> categories) {
  if (categories.isEmpty) return 'RevoChamp Journal';
  final c = categories.map((e) => e.toLowerCase()).toList();
  if (c.contains('crm')) return 'CRM Journal';
  if (c.contains('insurance')) return 'Insurance Journal';
  if (c.contains('ai')) return 'AI Journal';
  if (c.contains('technology') || c.contains('tech')) return 'Tech Journal';
  if (c.contains('analytics')) return 'Analytics Journal';
  return 'RevoChamp Journal';
}

String formatCategories(List<String> categories) {
  if (categories.isEmpty) return 'General';
  if (categories.length <= 2) return categories.join(' • ');
  return '${categories.take(2).join(' • ')} +${categories.length - 2}';
}

String formatDate(DateTime date) {
  const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month]} ${date.day}, ${date.year}';
}

List<InlineSpan> _parseInline(String text) {
  final spans = <InlineSpan>[];
  final exp = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*');
  int start = 0;

  for (final m in exp.allMatches(text)) {
    if (m.start > start) {
      spans.add(TextSpan(text: text.substring(start, m.start)));
    }
    if (m.group(1) != null) {
      spans.add(TextSpan(
        text: m.group(1),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ));
    } else if (m.group(2) != null) {
      spans.add(TextSpan(
        text: m.group(2),
        style: const TextStyle(fontStyle: FontStyle.italic),
      ));
    }
    start = m.end;
  }
  if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
  return spans;
}

// ─────────────────────────────────────────────────────────────
//  MAIN PAGE
// ─────────────────────────────────────────────────────────────
class NewsDetailPage extends StatefulWidget {
  final BlogPost post;
  final String slug;

  const NewsDetailPage({
    Key? key,
    required this.post,
    required this.slug,
  }) : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final _scrollController = ScrollController();
  bool _showBackButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final show = _scrollController.offset > 100;
    if (show != _showBackButton) {
      setState(() => _showBackButton = show);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 1000;
    final isTablet = w > 600 && w <= 1000;

    return Scaffold(
      backgroundColor: _T.paper,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Header ──────────────────────────────────────────
          _BlogHeader(
            post: widget.post,
            slug: widget.slug,
            showBackButton: _showBackButton,
          ),

          // ── Content ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: _T.paper,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1300),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 48 : (isTablet ? 32 : 20),
                      vertical: 40,
                    ),
                    child: isDesktop
                        ? _DesktopLayout(post: widget.post, slug: widget.slug)
                        : isTablet
                            ? _TabletLayout(post: widget.post, slug: widget.slug)
                            : _MobileLayout(post: widget.post, slug: widget.slug),
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

// ─────────────────────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────────────────────
class _BlogHeader extends StatelessWidget {
  final BlogPost post;
  final String slug;
  final bool showBackButton;

  const _BlogHeader({
    required this.post,
    required this.slug,
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final journal = getJournalName(post.categories);
    final date = formatDate(post.date!);
    final categoryText = formatCategories(post.categories);

    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: _T.paper,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _T.divider,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Back button
              AnimatedOpacity(
                opacity: showBackButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: showBackButton ? () => context.go('/news') : null,
                  // onTap: showBackButton ? () => Navigator.pop(context) : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: showBackButton ? _T.ink : Colors.transparent,
                    ),
                  ),
                ),
              ),

              // Brand
              Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 16, color: _T.red),
                  const SizedBox(width: 6),
                  Text('RevoChamp',
                      style: _T.syne(11, w: FontWeight.w700, color: _T.red)),
                ],
              ),

              const Spacer(),

              // Center info (desktop only)
              if (!isMobile)
                Row(
                  children: [
                    Text(journal,
                        style: _T.syne(10, color: _T.ink.withValues(alpha: 0.7))),
                    const SizedBox(width: 16),
                    Container(
                      width: 1,
                      height: 16,
                      color: _T.border,
                    ),
                    const SizedBox(width: 16),
                    Text(date,
                        style: _T.syne(10, color: _T.muted)),
                  ],
                ),

              const Spacer(),

              // Category badge
              if (!isMobile)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _T.redLight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    categoryText,
                    style: _T.syne(9, w: FontWeight.w700, color: _T.red),
                  ),
                )
              else
                Icon(Icons.more_vert_rounded, size: 20, color: _T.muted),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DESKTOP LAYOUT
// ─────────────────────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final BlogPost post;
  final String slug;

  const _DesktopLayout({required this.post, required this.slug});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 65,
          child: _MainContent(post: post, slug: slug),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 35,
          child: _Sidebar(post: post),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TABLET LAYOUT
// ─────────────────────────────────────────────────────────────
class _TabletLayout extends StatelessWidget {
  final BlogPost post;
  final String slug;

  const _TabletLayout({required this.post, required this.slug});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MainContent(post: post, slug: slug),
        const SizedBox(height: 40),
        _Sidebar(post: post),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  MOBILE LAYOUT
// ─────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final BlogPost post;
  final String slug;

  const _MobileLayout({required this.post, required this.slug});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MainContent(post: post, slug: slug),
        const SizedBox(height: 32),
        _Sidebar(post: post),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HERO SECTION
// ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final BlogPost post;
  final bool isDesktop;

  const _HeroSection({required this.post, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final stats = post.stats.take(3).toList();
    final hasStats = stats.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          color: _T.red,
          child: Text(
            post.categories.take(2).join(' • ').toUpperCase(),
            style: _T.syne(8.5, w: FontWeight.w700, color: Colors.white),
          ),
        ),

        const SizedBox(height: 18),

        // Title
        Text(
          post.title,
          style: _T.serif(
            isDesktop ? 44 : 32,
            w: FontWeight.w700,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle
        if (post.subtitle.isNotEmpty)
          Text(
            post.subtitle,
            style: _T.body(16, color: _T.muted, height: 1.6),
          ),

        const SizedBox(height: 24),

        // Meta row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: _T.divider, width: 0.5),
              bottom: BorderSide(color: _T.divider, width: 0.5),
            ),
          ),
          child: Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _MetaItem(label: 'By', value: post.author),
              _MetaItem(label: 'Date', value: formatDate(post.date!)),
              _MetaItem(label: 'Read', value: post.readTime),
              _MetaItem(label: 'Category', value: post.categories.first),
            ],
          ),
        ),

        // Stats
        if (hasStats) ...[
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: isDesktop ? 3 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: stats
                .map((s) => _StatCard(value: s.value, label: s.label))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: _T.syne(9, w: FontWeight.w700, color: _T.muted)),
        const SizedBox(width: 8),
        Text(value, style: _T.body(13, color: _T.ink)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _T.cream,
        border: Border.all(color: _T.border, width: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: _T.serif(28, w: FontWeight.w700, color: _T.red),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: _T.body(12, color: _T.muted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  MAIN CONTENT
// ─────────────────────────────────────────────────────────────
class _MainContent extends StatelessWidget {
  final BlogPost post;
  final String slug;

  const _MainContent({required this.post, required this.slug});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero section
        _HeroSection(post: post, isDesktop: isDesktop),

        const SizedBox(height: 40),
        Divider(color: _T.divider, thickness: 0.5),
        const SizedBox(height: 40),

        // Featured image
        if (post.featuredImage != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: post.featuredImage!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 400,
              placeholder: (_, __) =>
                  Container(height: 400, color: _T.cream),
              errorWidget: (_, __, ___) =>
                  Container(height: 400, color: _T.cream),
            ),
          ),
          const SizedBox(height: 40),
        ],

        // Content
        ..._buildContent(post.content),

        const SizedBox(height: 48),
        Divider(color: _T.divider, thickness: 0.5),
        const SizedBox(height: 32),

        // Share buttons
        _ShareSection(url: 'https://revochamp.com/news/$slug', title: post.title),

        const SizedBox(height: 40),

        // FAQ
        if (post.faq != null && post.faq!.isNotEmpty)
          _FaqSection(faq: post.faq!),

        // Related articles
        if (post.related.isNotEmpty) ...[
          const SizedBox(height: 48),
          _RelatedSection(related: post.related),
        ],
      ],
    );
  }

  List<Widget> _buildContent(List<ContentItem> items) {
    final widgets = <Widget>[];
    bool firstText = true;

    for (final item in items) {
      switch (item.type) {
        case ContentType.heading:
          widgets.add(_SectionHeading(text: item.value));
          break;

        case ContentType.text:
          if (firstText) {
            widgets.add(_BodyText(text: item.value, dropCap: true));
            firstText = false;
          } else {
            widgets.add(_BodyText(text: item.value));
          }
          break;

        case ContentType.list:
          widgets.add(_FeatureList(raw: item.value));
          break;

        case ContentType.table:
          if (item.headers != null && item.rows != null) {
            widgets.add(_TableComponent(headers: item.headers!, rows: item.rows!));
          }
          break;

        case ContentType.image:
          if (item.imageUrl != null) {
            widgets.add(_ContentImage(url: item.imageUrl!, caption: item.caption));
          }
          break;

        case ContentType.highlight:
          widgets.add(_InsightBox(text: item.value));
          break;

        case ContentType.tip:
          widgets.add(_TipBox(text: item.value));
          break;

        case ContentType.warning:
          widgets.add(_WarningBox(text: item.value));
          break;

        case ContentType.featureBox:
          widgets.add(_FeatureBoxComponent(text: item.value));
          break;

        default:
          break;
      }
    }
    return widgets;
  }
}

// ─────────────────────────────────────────────────────────────
//  CONTENT COMPONENTS
// ─────────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: _T.divider, thickness: 1),
          const SizedBox(height: 16),
          Text(text, style: _T.serif(28, w: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  final bool dropCap;

  const _BodyText({required this.text, this.dropCap = false});

  @override
  Widget build(BuildContext context) {
    final paragraphs = text
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.asMap().entries.map((e) {
        final isFirst = e.key == 0 && dropCap;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: isFirst
              ? _DropCapParagraph(text: e.value)
              : RichText(
                  text: TextSpan(
                    style: _T.body(15),
                    children: _parseInline(e.value),
                  ),
                ),
        );
      }).toList(),
    );
  }
}

class _DropCapParagraph extends StatelessWidget {
  final String text;
  const _DropCapParagraph({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox();
    final firstChar = text[0];
    final rest = text.substring(1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstChar,
          style: _T.serif(72, w: FontWeight.w700, height: 0.8),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: _T.body(15),
              children: _parseInline(rest),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  final String raw;
  const _FeatureList({required this.raw});

  @override
  Widget build(BuildContext context) {
    final items = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _T.divider,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  width: 4,
                  height: 4,
                  color: _T.red,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: _T.body(14),
                      children: _parseInline(
                        e.value.replaceAll(RegExp(r'^[-•]\s*'), ''),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TableComponent extends StatefulWidget {
  final List<String> headers;
  final List<List<String>> rows;

  const _TableComponent({required this.headers, required this.rows});

  @override
  State<_TableComponent> createState() => _TableComponentState();
}

class _TableComponentState extends State<_TableComponent> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: _T.divider),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  color: _T.ink,
                  child: Row(
                    children: widget.headers.map((h) {
                      return _TableCell(
                        text: h.toUpperCase(),
                        isHeader: true,
                      );
                    }).toList(),
                  ),
                ),

                // Rows
                ...widget.rows.asMap().entries.map((entry) {
                  final isEven = entry.key.isEven;
                  return Container(
                    color: isEven ? Colors.white : _T.paper,
                    child: Row(
                      children: entry.value.map((cell) {
                        return _TableCell(text: cell);
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell({required this.text, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: _T.divider, width: 0.5),
          ),
        ),
        child: Text(
          text,
          style: isHeader
              ? _T.syne(10, w: FontWeight.w700, color: Colors.white)
              : _T.body(13),
          softWrap: true,
        ),
      ),
    );
  }
}

class _ContentImage extends StatelessWidget {
  final String url;
  final String? caption;

  const _ContentImage({required this.url, this.caption});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
              placeholder: (_, __) =>
                  Container(height: 300, color: _T.cream),
              errorWidget: (_, __, ___) =>
                  Container(height: 300, color: _T.cream),
            ),
          ),
          if (caption != null && caption!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              caption!,
              style: _T.body(12, color: _T.muted, w: FontWeight.w300)
                  .copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightBox extends StatelessWidget {
  final String text;
  const _InsightBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final clean = text.replaceAll(RegExp(r'💡\s*\*\*.*?\*\*\s*'), '').trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _T.blueLight,
          border: Border(left: BorderSide(color: _T.blue, width: 3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💡 KEY INSIGHT', style: _T.syne(9, w: FontWeight.w700, color: _T.blue)),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: _T.body(14, color: _T.ink),
                children: _parseInline(clean),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipBox extends StatelessWidget {
  final String text;
  const _TipBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final clean = text.replaceAll(RegExp(r'👉\s*'), '').trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: _T.red, width: 2),
            bottom: BorderSide(color: _T.divider, width: 0.5),
          ),
        ),
        child: Text(
          '"$clean"',
          style: _T.serif(20, italic: true, height: 1.6),
        ),
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String text;
  const _WarningBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final clean = text.replaceAll(RegExp(r'❌\s*\*\*.*?\*\*\s*'), '').trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E6),
          border: Border(left: BorderSide(color: const Color(0xFFD4900A), width: 3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⚠️ IMPORTANT', style: _T.syne(9, w: FontWeight.w700, color: const Color(0xFFD4900A))),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: _T.body(14, color: _T.ink),
                children: _parseInline(clean),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureBoxComponent extends StatefulWidget {
  final String text;

  const _FeatureBoxComponent({required this.text});

  @override
  State<_FeatureBoxComponent> createState() => _FeatureBoxComponentState();
}

class _FeatureBoxComponentState extends State<_FeatureBoxComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.text.split('\n');
    String? title;
    String content = widget.text;

    if (lines.isNotEmpty &&
        lines.first.startsWith('**') &&
        lines.first.contains('**')) {
      title = lines.first.replaceAll('**', '').trim();
      content = lines.skip(1).join('\n').trim();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _isExpanded ? _T.red : _T.divider,
            width: 0.5,
          ),
          color: _isExpanded ? _T.redLight : Colors.white,
        ),
        child: Column(
          children: [
            InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      color: _T.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title ?? 'Feature Information',
                        style: _T.serif(16, w: FontWeight.w700),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _T.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipRect(
              child: Align(
                heightFactor: _controller.value,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                  child: Text(
                    content,
                    style: _T.body(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARE SECTION
// ─────────────────────────────────────────────────────────────
class _ShareSection extends StatelessWidget {
  final String url;
  final String title;

  const _ShareSection({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Share This Article', style: _T.syne(10, w: FontWeight.w700)),
        const SizedBox(height: 14),
        ShareButtons(url: url, title: title),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SIDEBAR
// ─────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final BlogPost post;

  const _Sidebar({required this.post});

  @override
  Widget build(BuildContext context) {
    final headings = post.content
        .where((i) => i.type == ContentType.heading)
        .map((i) => i.value)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table of contents
        if (headings.isNotEmpty) ...[
          _SidebarSection(
            title: 'In This Article',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: headings
                  .map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(h, style: _T.body(13)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Stat highlight
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _T.darkSurface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Text(
                post.stats.isNotEmpty ? post.stats.first.value : '85%',
                style: _T.serif(40, w: FontWeight.w700, color: _T.gold),
              ),
              const SizedBox(height: 8),
              Text(
                post.stats.isNotEmpty
                    ? post.stats.first.label
                    : 'Key Metric',
                style: _T.body(12, color: Colors.white.withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Tags
        if (post.tags.isNotEmpty)
          _SidebarSection(
            title: 'Topics',
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: post.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _T.cream,
                          border: Border.all(color: _T.divider),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(tag, style: _T.body(11, color: _T.muted)),
                      ))
                  .toList(),
            ),
          ),

        const SizedBox(height: 32),

        // Newsletter
        _NewsletterSubscription(),
      ],
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SidebarSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: _T.syne(9, w: FontWeight.w700, color: _T.muted),
          ),
        ),
        child,
      ],
    );
  }
}

class _NewsletterSubscription extends StatefulWidget {
  @override
  State<_NewsletterSubscription> createState() =>
      _NewsletterSubscriptionState();
}

class _NewsletterSubscriptionState extends State<_NewsletterSubscription> {
  final _controller = TextEditingController();
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _T.cream,
        border: Border.all(color: _T.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stay Updated', style: _T.serif(16, w: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Get insights delivered weekly',
            style: _T.body(12, color: _T.muted),
          ),
          const SizedBox(height: 14),
          if (!_submitted) ...[
            TextField(
              controller: _controller,
              style: _T.body(13),
              decoration: InputDecoration(
                hintText: 'Your email',
                hintStyle: _T.body(13, color: _T.border),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: _T.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: _T.red),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                if (_controller.text.contains('@')) {
                  setState(() => _submitted = true);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: _T.red,
                child: Text(
                  'Subscribe',
                  textAlign: TextAlign.center,
                  style: _T.syne(10, w: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: const Color(0xFFEAF3DE),
              child: Text(
                '✓ Subscribed!',
                textAlign: TextAlign.center,
                style: _T.body(12, color: const Color(0xFF3B6D11)),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FAQ SECTION
// ─────────────────────────────────────────────────────────────
class _FaqSection extends StatefulWidget {
  final List<Map<String, String>> faq;

  const _FaqSection({required this.faq});

  @override
  State<_FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<_FaqSection> {
  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: _T.divider, thickness: 1),
        const SizedBox(height: 32),
        Text('Frequently Asked Questions', style: _T.serif(28, w: FontWeight.w700)),
        const SizedBox(height: 24),
        ...widget.faq.asMap().entries.map((e) {
          final isOpen = _openIndex == e.key;
          return Column(
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _openIndex = isOpen ? null : e.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOpen ? _T.redLight : _T.cream,
                          border: Border.all(
                            color: isOpen ? _T.red : _T.divider,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: _T.syne(
                              11,
                              w: FontWeight.w700,
                              color: isOpen ? _T.red : _T.muted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          e.value['question'] ?? '',
                          style: _T.serif(15, w: FontWeight.w600),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isOpen ? _T.red : _T.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 48, bottom: 16),
                  child: Text(
                    e.value['answer'] ?? '',
                    style: _T.body(14, color: _T.muted),
                  ),
                ),
                crossFadeState: isOpen
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
              Divider(color: _T.divider, thickness: 0.5),
            ],
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  RELATED ARTICLES
// ─────────────────────────────────────────────────────────────
class _RelatedSection extends StatelessWidget {
  final List<String> related;

  const _RelatedSection({required this.related});

  String _formatSlug(String slug) {
    return slug
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: _T.divider, thickness: 1),
        const SizedBox(height: 32),
        Text('Related Articles', style: _T.serif(28, w: FontWeight.w700)),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: related
              .take(4)
              .map((slug) => _RelatedCard(
                    title: _formatSlug(slug),
                    slug: slug,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _RelatedCard extends StatefulWidget {
  final String title;
  final String slug;

  const _RelatedCard({required this.title, required this.slug});

  @override
  State<_RelatedCard> createState() => _RelatedCardState();
}

class _RelatedCardState extends State<_RelatedCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          // Navigator.pushReplacementNamed(context, '/news/${widget.slug}');
context.push('/news/${widget.slug}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _hover ? _T.redLight : _T.cream,
            border: Border.all(
              color: _hover ? _T.red : _T.divider,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: _T.serif(16, w: FontWeight.w700, height: 1.3),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Read more',
                    style: _T.syne(9, w: FontWeight.w700, color: _T.red),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: _hover ? _T.red : _T.muted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}