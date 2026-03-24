import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revochampblog/models/blog_post.dart';
import 'package:revochampblog/models/content_item.dart';
import 'package:revochampblog/widgets/share_buttons.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
class _T {
  // Colors
  static const paper = Color(0xFFF7F4EF);
  static const ink = Color(0xFF0F0E0C);
  static const accent = Color(0xFFC8401E);
  static const accentLight = Color(0xFFFAEEE9);
  static const muted = Color(0xFF6B6760);
  static const border = Color(0xFFDDD9D2);
  static const warning = Color(0xFFFFF8E6);
  static const warningBorder = Color(0xFFD4900A);
  static const success = Color(0xFFEAF3DE);

  // Typography
  static TextStyle display(double size, {FontWeight w = FontWeight.w700}) =>
      GoogleFonts.playfairDisplay(fontSize: size, fontWeight: w, color: ink);

  static TextStyle displayItalic(double size) => GoogleFonts.playfairDisplay(
        fontSize: size,
        fontStyle: FontStyle.italic,
        color: ink,
      );

  static TextStyle body(double size,
          {FontWeight w = FontWeight.w300, Color? color}) =>
      GoogleFonts.dmSans(
          fontSize: size, fontWeight: w, color: color ?? ink, height: 1.8);

  static TextStyle label(double size, {Color? color}) => GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.14 * size,
        color: color ?? muted,
      );
}

// ─────────────────────────────────────────────────────────────
//  MAIN DESIGN
// ─────────────────────────────────────────────────────────────
class NewspaperBlogDesign1 extends StatelessWidget {
  final BlogPost post;
  final ScrollController scrollController;
  final Function(String) onCopyCode;
  final String slug;

  const NewspaperBlogDesign1({
    Key? key,
    required this.post,
    required this.scrollController,
    required this.onCopyCode,
    required this.slug,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 900;

    return Scaffold(
      backgroundColor: _T.paper,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          // ── Sticky masthead ──────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: _T.paper,
            elevation: 0,
            centerTitle: true,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text('RevoChamp',
                          style: _T.label(11, color: _T.accent)),
                      const Spacer(),
                      Text('CRM Journal · March 2026',
                          style: _T.label(11)),
                      const Spacer(),
                      Text('Strategy & Technology',
                          style: _T.label(11)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1.5, color: _T.ink),
              ],
            ),
            toolbarHeight: 44,
          ),

          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero ──────────────────────────────────
                      _HeroSection(post: post, isDesktop: isDesktop),

                      const SizedBox(height: 24),
                      const Divider(thickness: 1.5, color: _T.ink),
                      const SizedBox(height: 32),

                      // ── Body layout ───────────────────────────
                      isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 62,
                                  child: _MainContent(
                                      post: post, slug: slug),
                                ),
                                const SizedBox(width: 48),
                                Expanded(
                                  flex: 38,
                                  child: _Sidebar(
                                    post: post,
                                    scrollController: scrollController,
                                    onRelatedTap: (s) =>
                                        Navigator.pushReplacementNamed(
                                            context, '/blog/$s'),
                                    onTagTap: (t) =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                                SnackBar(content: Text(t))),
                                  ),
                                ),
                              ],
                            )
                          : _MainContent(post: post, slug: slug),

                      const SizedBox(height: 40),

                      // ── FAQ ───────────────────────────────────
                      if (post.faq != null && post.faq!.isNotEmpty)
                        _FaqSection(faq: post.faq!),

                      // ── Related ───────────────────────────────
                      if (post.related.isNotEmpty)
                        _RelatedSection(
                          related: post.related,
                          onTap: (s) => Navigator.pushReplacementNamed(
                              context, '/blog/$s'),
                        ),
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

// ─────────────────────────────────────────────────────────────
//  HERO SECTION
// ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final BlogPost post;
  final bool isDesktop;

  const _HeroSection({required this.post, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(value: '34%', label: 'Increase in sales productivity with AI'),
      _StatItem(value: '3×', label: 'Higher engagement via omnichannel'),
      _StatItem(value: '89%', label: 'Customer retention — omnichannel firms'),
    ];

    final leftBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: _T.accent,
          child: Text(
            post.categories.take(3).join(' · ').toUpperCase(),
            style: _T.label(10, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(post.title,
            style: _T.display(
                isDesktop ? 38 : 26,
                w: FontWeight.w700)),
        const SizedBox(height: 12),

        // Subtitle
        if (post.subtitle.isNotEmpty)
          Text(post.subtitle,
              style: _T.body(15, color: _T.muted)),
        const SizedBox(height: 20),

        // Meta bar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: _T.border),
              bottom: BorderSide(color: _T.border),
            ),
          ),
          child: Wrap(
            spacing: 24,
            runSpacing: 4,
            children: [
              _MetaChip(label: 'By', value: post.author),
              _MetaChip(label: 'Date', value: '24 March 2026'),
              _MetaChip(label: 'Read', value: post.readTime),
            ],
          ),
        ),
      ],
    );

    final rightBlock = Column(
      children: stats
          .map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _HeroStat(value: s.value, label: s.label),
              ))
          .toList(),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 55, child: leftBlock),
          const SizedBox(width: 40),
          Expanded(flex: 45, child: rightBlock),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leftBlock,
        const SizedBox(height: 28),
        Row(
          children: stats
              .map((s) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _HeroStat(value: s.value, label: s.label),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _StatItem {
  final String value;
  final String label;
  _StatItem({required this.value, required this.label});
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: _T.accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: _T.display(28).copyWith(color: _T.accent, height: 1)),
          const SizedBox(height: 4),
          Text(label, style: _T.body(11, color: _T.muted)),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: _T.body(13, color: _T.muted),
        children: [
          TextSpan(
              text: '$label  ',
              style: const TextStyle(fontWeight: FontWeight.w500)),
          TextSpan(text: value),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured image
        if (post.featuredImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: post.featuredImage!,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),

        const SizedBox(height: 28),

        // Content items
        ..._buildContent(post.content),

        const SizedBox(height: 32),
        const Divider(color: _T.border),
        const SizedBox(height: 20),

        ShareButtons(
          url: 'https://revochamp.com/blog/$slug',
          title: post.title,
        ),
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
            widgets.add(_NpTable(
                headers: item.headers!, rows: item.rows!));
          }
          break;

        case ContentType.image:
          if (item.imageUrl != null) {
            widgets.add(_ContentImage(
                url: item.imageUrl!, caption: item.caption));
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

        case ContentType.cta:
          widgets.add(_CtaBlock(text: item.value));
          break;

        default:
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(item.value, style: _T.body(15)),
          ));
      }
    }
    return widgets;
  }
}

// ─────────────────────────────────────────────────────────────
//  CONTENT WIDGETS
// ─────────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(thickness: 1.5, color: _T.ink),
          const SizedBox(height: 12),
          Text(text, style: _T.display(22)),
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
    final paragraphs =
        text.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.asMap().entries.map((e) {
        final isFirst = e.key == 0 && dropCap;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
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
          style: _T.display(72).copyWith(
                height: 0.85,
                color: _T.ink,
              ),
        ),
        const SizedBox(width: 4),
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

// ── Rich text inline parser (bold, italic) ───────────────────
List<InlineSpan> _parseInline(String text) {
  final spans = <InlineSpan>[];
  // handles **bold** and *italic*
  final exp = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*');
  int start = 0;

  for (final m in exp.allMatches(text)) {
    if (m.start > start) {
      spans.add(TextSpan(text: text.substring(start, m.start)));
    }
    if (m.group(1) != null) {
      // bold
      spans.add(TextSpan(
          text: m.group(1),
          style: const TextStyle(fontWeight: FontWeight.w600)));
    } else if (m.group(2) != null) {
      // italic
      spans.add(TextSpan(
          text: m.group(2),
          style: const TextStyle(fontStyle: FontStyle.italic)));
    }
    start = m.end;
  }
  if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
  return spans;
}

// ── Feature list ─────────────────────────────────────────────
class _FeatureList extends StatelessWidget {
  final String raw;
  const _FeatureList({required this.raw});

  @override
  Widget build(BuildContext context) {
    final items = raw
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isFirst = e.key == 0;
          return Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: isFirst ? _T.border : _T.border, width: 0.5),
                bottom:
                    const BorderSide(color: _T.border, width: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 9, right: 12),
                  width: 6,
                  height: 6,
                  color: _T.accent,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: _T.body(14),
                      children: _parseInline(e.value.replaceAll(RegExp(r'^[-•]\s*'), '')),
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

// ── Table ─────────────────────────────────────────────────────
class _NpTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  const _NpTable({required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _T.border),
        ),
        child: Column(
          children: [
            // Header row
            Container(
              color: _T.ink,
              child: Row(
                children: headers.asMap().entries.map((e) {
                  final isLast = e.key == headers.length - 1;
                  return Expanded(
                    flex: isLast ? 2 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Text(e.value.toUpperCase(),
                          style: _T.label(10, color: Colors.white)),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Body rows
            ...rows.asMap().entries.map((re) {
              final isEven = re.key.isEven;
              return Container(
                color: isEven
                    ? Colors.white
                    : _T.paper,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: re.value.asMap().entries.map((ce) {
                    final isLast = ce.key == re.value.length - 1;
                    final isFirst = ce.key == 0;
                    return Expanded(
                      flex: isLast ? 2 : 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: _T.border, width: 0.5)),
                        ),
                        child: Text(
                          ce.value,
                          style: _T.body(13,
                              w: isFirst
                                  ? FontWeight.w500
                                  : FontWeight.w300),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Content image ─────────────────────────────────────────────
class _ContentImage extends StatelessWidget {
  final String url;
  final String? caption;
  const _ContentImage({required this.url, this.caption});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, __) => Container(
                  height: 200,
                  color: _T.border,
                  child: const Center(child: CircularProgressIndicator())),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image),
            ),
          ),
          if (caption != null && caption!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(caption!,
                style: _T.body(12,
                    color: _T.muted,
                    w: FontWeight.w300)
                    .copyWith(fontStyle: FontStyle.italic)),
          ]
        ],
      ),
    );
  }
}

// ── Insight box ───────────────────────────────────────────────
class _InsightBox extends StatelessWidget {
  final String text;
  const _InsightBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final clean = text
        .replaceAll(RegExp(r'💡\s*\*\*.*?\*\*\s*'), '')
        .trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: _T.accentLight,
          border: Border(left: BorderSide(color: _T.accent, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INSIGHT', style: _T.label(9, color: _T.accent)),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                  style: _T.body(14, color: const Color(0xFF3A2820)),
                  children: _parseInline(clean)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tip / pull-quote box ──────────────────────────────────────
class _TipBox extends StatelessWidget {
  final String text;
  const _TipBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final clean = text.replaceAll(RegExp(r'👉\s*'), '').trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: _T.accent, width: 2),
            bottom: BorderSide(color: _T.border, width: 0.5),
          ),
        ),
        child: Text(
          '"$clean"',
          style: _T.displayItalic(18).copyWith(height: 1.55),
        ),
      ),
    );
  }
}

// ── Warning box ───────────────────────────────────────────────
class _WarningBox extends StatelessWidget {
  final String text;
  const _WarningBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final clean = text.replaceAll(RegExp(r'❌\s*\*\*.*?\*\*\s*'), '').trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: _T.warning,
          border: Border(
              left: BorderSide(color: _T.warningBorder, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CRITICAL ERROR',
                style: _T.label(9, color: _T.warningBorder)),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                  style: _T.body(14, color: const Color(0xFF3A3010)),
                  children: _parseInline(clean)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CTA block ─────────────────────────────────────────────────
class _CtaBlock extends StatelessWidget {
  final String text;
  const _CtaBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Container(
        padding: const EdgeInsets.all(28),
        color: _T.ink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Download the Advanced CRM Playbook',
                style: _T.display(18).copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'Includes AI templates, personalization frameworks, and omnichannel checklists. Free access.',
              style: _T.body(13, color: const Color(0xFFB0ADA8)),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                color: _T.accent,
                child:
                    Text('Download Free Playbook →', style: _T.label(12, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SIDEBAR
// ─────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final BlogPost post;
  final ScrollController scrollController;
  final Function(String) onRelatedTap;
  final Function(String) onTagTap;

  const _Sidebar({
    required this.post,
    required this.scrollController,
    required this.onRelatedTap,
    required this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extract headings from content
    final headings = post.content
        .where((i) => i.type == ContentType.heading)
        .map((i) => i.value)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── TOC ───────────────────────────────────────────────
        _SideSection(
          label: 'In This Article',
          child: Column(
            children: headings.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '0${e.key + 1}',
                      style: _T.label(11, color: _T.accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e.value,
                          style: _T.body(13, color: _T.ink)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 28),

        // ── Stat card ─────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          color: _T.ink,
          child: Column(
            children: [
              Text('40%',
                  style:
                      _T.display(48).copyWith(color: _T.accent, height: 1)),
              const SizedBox(height: 6),
              Text(
                'Improvement in forecast accuracy with AI-powered CRM',
                style: _T.body(12, color: const Color(0xFFB0ADA8)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── Tools ─────────────────────────────────────────────
        _SideSection(
          label: 'Top CRM Platforms · 2026',
          child: Column(
            children: const [
              _ToolCard(
                name: 'Salesforce CRM',
                desc:
                    'Gold standard for enterprise AI with Einstein integration.',
              ),
              _ToolCard(
                name: 'HubSpot CRM',
                desc:
                    'Premier choice for startups seeking powerful automation.',
              ),
              _ToolCard(
                name: 'Zoho CRM',
                desc:
                    'Affordable and feature-rich with Zia AI predictions.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── Tags ──────────────────────────────────────────────
        _SideSection(
          label: 'Topics',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: post.tags.map((t) {
              return GestureDetector(
                onTap: () => onTagTap(t),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: _T.border),
                  ),
                  child: Text(t, style: _T.body(11, color: _T.muted)),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 28),

        // ── Related ───────────────────────────────────────────
        if (post.related.isNotEmpty)
          _SideSection(
            label: 'Related',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: post.related.map((slug) {
                final title = _formatSlug(slug);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => onRelatedTap(slug),
                    child: Text('→  $title',
                        style: _T.body(13, color: _T.ink)),
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 28),

        // ── Newsletter ────────────────────────────────────────
        _NewsletterBox(),
      ],
    );
  }

  String _formatSlug(String slug) {
    return slug
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

class _SideSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _SideSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _T.border))),
          child: Text(label.toUpperCase(), style: _T.label(10)),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String name;
  final String desc;
  const _ToolCard({required this.name, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: _T.border, width: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: _T.body(14, w: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(desc, style: _T.body(12, color: _T.muted)),
        ],
      ),
    );
  }
}

class _NewsletterBox extends StatefulWidget {
  @override
  State<_NewsletterBox> createState() => _NewsletterBoxState();
}

class _NewsletterBoxState extends State<_NewsletterBox> {
  final _ctrl = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return _SideSection(
      label: 'Newsletter',
      child: _sent
          ? Container(
              padding: const EdgeInsets.all(14),
              color: _T.success,
              child: Text('You\'re subscribed!',
                  style: _T.body(13,
                      color: const Color(0xFF3B6D11),
                      w: FontWeight.w500)),
            )
          : Column(
              children: [
                TextField(
                  controller: _ctrl,
                  style: _T.body(13),
                  decoration: InputDecoration(
                    hintText: 'Your email address',
                    hintStyle: _T.body(13, color: _T.muted),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide:
                          const BorderSide(color: _T.border),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: _T.ink),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide:
                          const BorderSide(color: _T.border),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    if (_ctrl.text.isNotEmpty) {
                      setState(() => _sent = true);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    color: _T.ink,
                    child: Text('SUBSCRIBE',
                        textAlign: TextAlign.center,
                        style: _T.label(11, color: Colors.white)),
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
  int? _open;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(thickness: 1.5, color: _T.ink),
          const SizedBox(height: 20),
          Text('Frequently Asked Questions',
              style: _T.display(22)),
          const SizedBox(height: 20),
          ...widget.faq.asMap().entries.map((e) {
            final isOpen = _open == e.key;
            return Column(
              children: [
                InkWell(
                  onTap: () =>
                      setState(() => _open = isOpen ? null : e.key),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        // Number badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isOpen ? _T.accent : _T.border),
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: _T.body(12,
                                  color: isOpen ? _T.accent : _T.muted,
                                  w: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            e.value['question'] ?? '',
                            style: _T.body(15, w: FontWeight.w500),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isOpen ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(Icons.expand_more,
                              color: isOpen ? _T.accent : _T.muted),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding:
                        const EdgeInsets.only(left: 42, bottom: 16, right: 24),
                    child: Text(e.value['answer'] ?? '',
                        style: _T.body(14, color: _T.muted)),
                  ),
                  crossFadeState: isOpen
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                ),
                const Divider(color: _T.border, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  RELATED POSTS
// ─────────────────────────────────────────────────────────────
class _RelatedSection extends StatelessWidget {
  final List<String> related;
  final Function(String) onTap;
  const _RelatedSection({required this.related, required this.onTap});

  String _format(String slug) => slug
      .replaceAll('-', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(thickness: 1.5, color: _T.ink),
          const SizedBox(height: 20),
          Text('Related Articles'.toUpperCase(),
              style: _T.label(12, color: _T.ink)),
          const SizedBox(height: 16),
          ...related.map((slug) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => onTap(slug),
                  child: Row(
                    children: [
                      Container(
                          width: 4, height: 4, color: _T.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_format(slug),
                            style: _T.body(14,
                                w: FontWeight.w500,
                                color: _T.ink)),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}