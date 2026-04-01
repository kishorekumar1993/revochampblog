import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/content_item.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS  (mirrors the HTML CSS variables exactly)
// ─────────────────────────────────────────────────────────────
class _T {
  static const paper       = Color(0xFFF7F4EF);
  static const ink         = Color(0xFF0F0E0C);
  static const accent      = Color(0xFFC8401E);
  static const accentLight = Color(0xFFFAEEE9);
  static const muted       = Color(0xFF6B6760);
  static const border      = Color(0xFFDDD9D2);
  static const warning     = Color(0xFFFFF8E6);
  static const warnBorder  = Color(0xFFD4900A);
  static const warnText    = Color(0xFF3A3010);
  static const insightText = Color(0xFF3A2820);
  static const successBg   = Color(0xFFEAF3DE);
  static const successText = Color(0xFF3B6D11);

  static TextStyle display(double size, {FontWeight w = FontWeight.w700, Color? color}) =>
      GoogleFonts.playfairDisplay(fontSize: size, fontWeight: w, color: color ?? ink, height: 1.25);

  static TextStyle displayItalic(double size, {Color? color}) =>
      GoogleFonts.playfairDisplay(fontSize: size, fontStyle: FontStyle.italic, color: color ?? ink, height: 1.55);

  static TextStyle body(double size, {FontWeight w = FontWeight.w300, Color? color, double height = 1.8}) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: w, color: color ?? ink, height: height);

  static TextStyle label(double size, {Color? color}) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: FontWeight.w500,
          letterSpacing: size * 0.13, color: color ?? muted);
}

// ─────────────────────────────────────────────────────────────
//  DISPATCHER  (drop-in replacement for old ContentItemWidget)
// ─────────────────────────────────────────────────────────────
class ContentItemWidget extends StatelessWidget {
  final ContentItem item;
  final void Function(String)? onCopy;

  /// Pass [isFirstText] = true for the very first text block in an article
  /// so it gets a drop-cap. The parent list builder should track this.
  final bool isFirstText;

  const ContentItemWidget({
    super.key,
    required this.item,
    this.onCopy,
    this.isFirstText = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case ContentType.heading:
        return NpHeading(text: item.value);

      case ContentType.text:
        return NpBodyText(text: item.value, dropCap: isFirstText);

      case ContentType.list:
        return NpList(raw: item.value, data: '',);

      case ContentType.table:
        if (item.headers != null && item.rows != null) {
          return NpTable(headers: item.headers!, rows: item.rows!);
        }
        return const SizedBox.shrink();

      case ContentType.image:
        return NpImage(
          url: item.imageUrl ?? '',
          caption: item.caption,
          title: item.title,
        );

      case ContentType.code:
        return NpCode(
          code: item.value,
          language: item.language,
          onCopy: onCopy,
        );

      case ContentType.highlight:
        return NpInsightBox(text: item.value);

      case ContentType.tip:
        return NpTipBox(text: item.value);

      case ContentType.warning:
        return NpWarningBox(text: item.value);

      case ContentType.cta:
        return NpCtaBlock(text: item.value);
      case ContentType.featureBox:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  INLINE RICH-TEXT PARSER  (**bold**, *italic*)
// ─────────────────────────────────────────────────────────────
List<InlineSpan> _parseInline(String text,
    {TextStyle? baseStyle, Color? defaultColor}) {
  final spans = <InlineSpan>[];
  final exp = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*');
  int cursor = 0;

  final base = baseStyle ??
      _T.body(15, color: defaultColor ?? _T.ink);

  for (final m in exp.allMatches(text)) {
    if (m.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, m.start), style: base));
    }
    if (m.group(1) != null) {
      // **bold**
      spans.add(TextSpan(
          text: m.group(1),
          style: base.copyWith(fontWeight: FontWeight.w600)));
    } else if (m.group(2) != null) {
      // *italic*
      spans.add(TextSpan(
          text: m.group(2),
          style: base.copyWith(fontStyle: FontStyle.italic)));
    }
    cursor = m.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor), style: base));
  }
  return spans;
}

// ─────────────────────────────────────────────────────────────
//  1. HEADING
// ─────────────────────────────────────────────────────────────
class NpHeading extends StatelessWidget {
  final String text;
  const NpHeading({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(thickness: 1.5, color: _T.ink),
          const SizedBox(height: 12),
          SelectableText(text, style: _T.display(22)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  2. BODY TEXT  (with optional drop-cap on first paragraph)
// ─────────────────────────────────────────────────────────────
class NpBodyText extends StatelessWidget {
  final String text;
  final bool dropCap;
  const NpBodyText({super.key, required this.text, this.dropCap = false});

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
              ? _DropCap(text: e.value)
              : RichText(
                  text: TextSpan(children: _parseInline(e.value)),
                ),
        );
      }).toList(),
    );
  }
}

class _DropCap extends StatelessWidget {
  final String text;
  const _DropCap({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final firstChar = text[0];
    final rest = text.substring(1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstChar,
          style: _T.display(72).copyWith(height: 0.85),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            text: TextSpan(children: _parseInline(rest)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  3. LIST
// ─────────────────────────────────────────────────────────────
class NpList extends StatelessWidget {
  final dynamic raw; // String or Map
  const NpList({super.key, required this.raw, required String data});

  String _content() {
    if (raw is String) return raw as String;
    if (raw is Map && raw['value'] is String) return raw['value'] as String;
    return raw.toString();
  }

  @override
  Widget build(BuildContext context) {
    final lines = _content()
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    if (lines.length <= 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: RichText(
            text: TextSpan(children: _parseInline(_content()))),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: lines.asMap().entries.map((e) {
          final parsed = _parseLine(e.value);
          final isFirst = e.key == 0;

          return Container(
            padding:
                const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: isFirst ? _T.ink : _T.border,
                    width: isFirst ? 1.5 : 0.5),
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
                      children: [
                        if (parsed.title.isNotEmpty)
                          TextSpan(
                            text: '${parsed.title}  ',
                            style: _T.body(14,
                                w: FontWeight.w600, color: _T.ink),
                          ),
                        ..._parseInline(parsed.desc,
                            baseStyle: _T.body(14, color: _T.muted)),
                      ],
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

  _ParsedItem _parseLine(String line) {
    line = line.replaceAll(RegExp(r'^[-•*]\s*'), '').trim();
    final bold = RegExp(r'^\*\*(.*?)\*\*\s*[–:\-]\s*(.*)$');
    final m = bold.firstMatch(line);
    if (m != null) {
      return _ParsedItem(title: m.group(1)!.trim(), desc: m.group(2)!.trim());
    }
    final colon = RegExp(r'^([^:–\-]+)[:–\-]\s*(.+)$');
    final m2 = colon.firstMatch(line);
    if (m2 != null) {
      return _ParsedItem(
          title: m2.group(1)!.trim(), desc: m2.group(2)!.trim());
    }
    return _ParsedItem(title: '', desc: line);
  }
}

class _ParsedItem {
  final String title;
  final String desc;
  _ParsedItem({required this.title, required this.desc});
}

// ─────────────────────────────────────────────────────────────
//  4. TABLE
// ─────────────────────────────────────────────────────────────
class NpTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  const NpTable({super.key, required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: _T.border)),
        child: Column(
          children: [
            // ── Header row ───────────────────────────────────
            Container(
              color: _T.ink,
              child: Row(
                children: headers.asMap().entries.map((e) {
                  return Expanded(
                    flex: e.key == headers.length - 1 ? 2 : 1,
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

            // ── Body rows ────────────────────────────────────
            ...rows.asMap().entries.map((re) {
              return Container(
                color: re.key.isEven ? Colors.white : _T.paper,
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
                        decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: _T.border, width: 0.5)),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: _parseInline(ce.value,
                                baseStyle: _T.body(13,
                                    w: isFirst
                                        ? FontWeight.w500
                                        : FontWeight.w300)),
                          ),
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

// ─────────────────────────────────────────────────────────────
//  5. IMAGE
// ─────────────────────────────────────────────────────────────
class NpImage extends StatelessWidget {
  final String url;
  final String? caption;
  final String? title;
  const NpImage({super.key, required this.url, this.caption, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            Text(title!, style: _T.body(14, w: FontWeight.w500)),
            const SizedBox(height: 8),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: url.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, _) => Container(
                        height: 200,
                        color: _T.border,
                        child: const Center(
                            child: CircularProgressIndicator(
                                color: _T.accent))),
                    errorWidget: (_, _, _) => _brokenImage(),
                  )
                : Image.asset(url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _brokenImage()),
          ),
          if (caption != null && caption!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(caption!,
                style: _T
                    .body(12, color: _T.muted)
                    .copyWith(fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _brokenImage() => Container(
        height: 180,
        color: _T.border,
        child: const Center(
            child: Icon(Icons.broken_image, color: _T.muted, size: 40)),
      );
}

// ─────────────────────────────────────────────────────────────
//  6. CODE BLOCK
// ─────────────────────────────────────────────────────────────
class NpCode extends StatefulWidget {
  final String code;
  final String? language;
  final void Function(String)? onCopy;
  const NpCode(
      {super.key,
      required this.code,
      this.language,
      this.onCopy});

  @override
  State<NpCode> createState() => _NpCodeState();
}

class _NpCodeState extends State<NpCode> {
  bool _copied = false;

  void _doCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    widget.onCopy?.call(widget.code);
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1917),
          border: Border.all(color: _T.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar ──────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFF252320),
              child: Row(
                children: [
                  if (widget.language != null)
                    Text(widget.language!.toUpperCase(),
                        style: _T.label(10, color: const Color(0xFF888580))),
                  const Spacer(),
                  GestureDetector(
                    onTap: _doCopy,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _copied
                          ? Row(
                              key: const ValueKey('copied'),
                              children: [
                                const Icon(Icons.check,
                                    color: Color(0xFF63A375), size: 14),
                                const SizedBox(width: 4),
                                Text('Copied',
                                    style:
                                        _T.label(11, color: const Color(0xFF63A375))),
                              ],
                            )
                          : Row(
                              key: const ValueKey('copy'),
                              children: [
                                Icon(Icons.copy_outlined,
                                    color: Colors.grey.shade500, size: 14),
                                const SizedBox(width: 4),
                                Text('Copy',
                                    style: _T.label(11,
                                        color: Colors.grey.shade500)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Code body ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                widget.code,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  height: 1.7,
                  color: const Color(0xFFD4D0C8),
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
//  7. INSIGHT / HIGHLIGHT BOX
// ─────────────────────────────────────────────────────────────
class NpInsightBox extends StatelessWidget {
  final String text;
  const NpInsightBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // Strip leading emoji + bold label if present
    final clean = text
        .replaceAll(RegExp(r'^💡\s*'), '')
        .replaceFirst(RegExp(r'^\*\*[^*]+\*\*\s*[:·]?\s*'), '')
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
                children: _parseInline(clean,
                    baseStyle: _T.body(14, color: _T.insightText)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  8. TIP / PULL-QUOTE BOX
// ─────────────────────────────────────────────────────────────
class NpTipBox extends StatelessWidget {
  final String text;
  const NpTipBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final clean = text
        .replaceAll(RegExp(r'^👉\s*'), '')
        .replaceFirst(RegExp(r'^\*\*[^*]+\*\*\s*[:·]?\s*'), '')
        .trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: _T.accent, width: 2),
            bottom: BorderSide(color: _T.border, width: 0.5),
          ),
        ),
        child: Text('"$clean"', style: _T.displayItalic(17)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  9. WARNING BOX
// ─────────────────────────────────────────────────────────────
class NpWarningBox extends StatelessWidget {
  final String text;
  const NpWarningBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final clean = text
        .replaceAll(RegExp(r'^❌\s*'), '')
        .replaceFirst(RegExp(r'^\*\*[^*]+\*\*\s*[:·]?\s*'), '')
        .trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: _T.warning,
          border:
              Border(left: BorderSide(color: _T.warnBorder, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CRITICAL ERROR',
                style: _T.label(9, color: _T.warnBorder)),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                children: _parseInline(clean,
                    baseStyle: _T.body(14, color: _T.warnText)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  10. CTA BLOCK
// ─────────────────────────────────────────────────────────────
class NpCtaBlock extends StatelessWidget {
  final String text;
  const NpCtaBlock({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // Strip emoji and extract a clean label if possible
    final clean = text
        .replaceAll(RegExp(r'^🚀\s*'), '')
        .replaceFirst(RegExp(r'^\*\*[^*]+\*\*\s*[-—]?\s*'), '')
        .trim();

    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(28),
        color: _T.ink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Download the Advanced CRM Playbook',
                style: _T.display(18, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              clean.isNotEmpty
                  ? clean
                  : 'AI templates, personalization frameworks, and omnichannel checklists. Free access.',
              style: _T.body(13, color: const Color(0xFFB0ADA8)),
            ),
            const SizedBox(height: 20),
            _CtaButton(label: 'Download Free Playbook →'),
          ],
        ),
      ),
    );
  }
}

class _CtaButton extends StatefulWidget {
  final String label;
  const _CtaButton({required this.label});

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: _hovered
              ? const Color(0xFFA33318)
              : _T.accent,
          child: Text(widget.label,
              style: _T.label(12, color: Colors.white)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LEGACY ALIASES  (keep old import names working)
// ─────────────────────────────────────────────────────────────
typedef HeadingWidget = NpHeading;
typedef TextWidget   = NpBodyText;
typedef ListWidget   = NpList;
typedef ImageWidget  = NpImage;
typedef CodeWidget   = NpCode;


// import 'package:flutter/material.dart';
// import '../models/content_item.dart';

// // Change the onCopy type to a function that takes a String
// class ContentItemWidget extends StatelessWidget {
//   final ContentItem item;
//   final void Function(String)? onCopy; // ← now takes String

//   const ContentItemWidget({super.key, required this.item, this.onCopy});

//   @override
//   Widget build(BuildContext context) {
//     switch (item.type) {
//       case ContentType.heading:
//         return HeadingWidget(text: item.value);
//       case ContentType.text:
//         return TextWidget(text: item.value);
//       case ContentType.table:
//       case ContentType.code:
//         return CodeWidget(
//           code: item.value,
//           language: item.language,
//           onCopy: onCopy,
//         );
//       case ContentType.list:
//         return ListWidget(data: item.value);
//       case ContentType.warning:
//       case ContentType.tip:
//       case ContentType.cta:
//       case ContentType.image:
//         return ImageWidget(imageUrl: item.imageUrl!, caption: item.caption,   title: item.title,);
//       case ContentType.highlight:
//         // TODO: Handle this case.
//         throw UnimplementedError();
//     }
//   }
// }

// class HeadingWidget extends StatelessWidget {
//   final String text;
//   const HeadingWidget({super.key, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Semantics(
//       header: true,
//       child: SelectableText(
//         text,
//         style: const TextStyle(
//           fontSize: 28,
//           fontWeight: FontWeight.bold,
//           color: Color(0xFF1E3C72),
//         ),
//       ),
//     );
//   }
// }

// class TextWidget extends StatelessWidget {
//   final String text;
//   const TextWidget({Key? key, required this.text}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SelectableText(
//       text,
//       style: const TextStyle(fontSize: 16, height: 1.6),
//     );
//   }
// }

// class CodeWidget extends StatelessWidget {
//   final String code;
//   final String? language;
//   final void Function(String)? onCopy; // ← now takes String

//   const CodeWidget({super.key, required this.code, this.language, this.onCopy});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           if (language != null)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Text(
//                 language!.toUpperCase(),
//                 style: const TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ),
//           SelectableText(
//             code,
//             style: const TextStyle(
//               fontFamily: 'monospace',
//               color: Colors.white,
//             ),
//           ),
//           if (onCopy != null)
//             Align(
//               alignment: Alignment.centerRight,
//               child: IconButton(
//                 icon: const Icon(Icons.copy, color: Colors.white, size: 18),
//                 onPressed: () =>
//                     onCopy!(code), // ← pass the code to the callback
//                 tooltip: 'Copy code',
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }


// // class ListWidget extends StatelessWidget {
// //   final String text;

// //   const ListWidget({super.key, required this.text});

// //   @override
// //   Widget build(BuildContext context) {
// //     final items = text.split('\n').where((e) => e.trim().isNotEmpty).toList();

// //     // 🔹 If only one item → render as normal paragraph
// //     if (items.length <= 1) {
// //       return Text(
// //         text,
// //         style: TextStyle(
// //           fontSize: 15,
// //           height: 1.7,
// //           color: Colors.grey.shade800,
// //         ),
// //       );
// //     }

// //     // 🔹 Multiple items → render list
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: List.generate(items.length, (index) {
// //         final item = items[index];

// //         final parts = item.split(':');
// //         final hasTitle = parts.length > 1;

// //         final title = hasTitle ? parts[0].trim() : '';
// //         final description =
// //             hasTitle ? parts.sublist(1).join(':').trim() : item.trim();

// //         return Padding(
// //           padding: const EdgeInsets.symmetric(vertical: 8),
// //           child: Row(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // 🔹 Minimal Dot Bullet
// //               Container(
// //                 margin: const EdgeInsets.only(top: 8),
// //                 width: 6,
// //                 height: 6,
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey.shade600,
// //                   shape: BoxShape.circle,
// //                 ),
// //               ),

// //               const SizedBox(width: 10),

// //               // 🔹 Text
// //               Expanded(
// //                 child: RichText(
// //                   text: TextSpan(
// //                     style: DefaultTextStyle.of(context).style,
// //                     children: [
// //                       if (hasTitle)
// //                         TextSpan(
// //                           text: "$title: ",
// //                           style: const TextStyle(
// //                             fontWeight: FontWeight.w600,
// //                             fontSize: 15.5,
// //                           ),
// //                         ),
// //                       TextSpan(
// //                         text: description,
// //                         style: TextStyle(
// //                           fontSize: 15,
// //                           height: 1.7,
// //                           color: Colors.grey.shade700,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       }),
// //     );
// //   }
// // }



// /// A widget that renders a list from either a raw string or a JSON‑like map.
// ///
// /// Example usage:
// /// ```
// /// ListWidget(
// ///   data: {
// ///     "type": "list",
// ///     "value": "**Predictive lead scoring** – AI models rank leads…"
// ///   }
// /// )
// /// ```
// class ListWidget extends StatelessWidget {
//   final dynamic data; // renamed for clarity

//   const ListWidget({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     // 1. Normalize input
//     String content = '';

//     if (data is String) {
//       content = data;
//     } else if (data is Map<String, dynamic>) {
//       if (data['type'] == 'list' && data['value'] is String) {
//         content = data['value'];
//       } else {
//         content = data.toString();
//       }
//     }

//     // 2. Split lines
//     final lines =
//         content.split('\n').where((e) => e.trim().isNotEmpty).toList();

//     // 3. Single line → plain text
//     if (lines.length <= 1) {
//       return Text(
//         content,
//         style: TextStyle(
//           fontSize: 15,
//           height: 1.7,
//           color: Colors.grey.shade800,
//         ),
//       );
//     }

//     // 4. Parse items
//     final items = lines
//         .map(_parseListItem)
//         .where((e) => e != null)
//         .cast<_ListItem>()
//         .toList();

//     // 5. Render
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: List.generate(items.length, (index) {
//         final item = items[index];

//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 6),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Bullet
//               Container(
//                 margin: const EdgeInsets.only(top: 8),
//                 width: 5,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade500,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 12),

//               // Content
//               Expanded(
//                 child: RichText(
//                   text: TextSpan(
//                     style: DefaultTextStyle.of(context).style.copyWith(
//                           fontSize: 15,
//                           height: 1.7,
//                           color: Colors.grey.shade700,
//                         ),
//                     children: [
//                       if (item.title.isNotEmpty)
//                         TextSpan(
//                           text: '${item.title}: ',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 15.5,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       TextSpan(
//                         text: item.description,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   _ListItem? _parseListItem(String line) {
//     line = line.trim();
//     if (line.isEmpty) return null;

//     // **Title** – Description
//     final boldRegex = RegExp(r'^\*\*(.*?)\*\*\s*[–:\-]\s*(.*)$');
//     final match = boldRegex.firstMatch(line);

//     if (match != null) {
//       return _ListItem(
//         title: match.group(1)!.trim(),
//         description: match.group(2)!.trim(),
//       );
//     }

//     // Title: Description
//     final fallbackRegex = RegExp(r'^([^:–\-]+)[:–\-]\s*(.*)$');
//     final fallbackMatch = fallbackRegex.firstMatch(line);

//     if (fallbackMatch != null) {
//       return _ListItem(
//         title: fallbackMatch.group(1)!.trim(),
//         description: fallbackMatch.group(2)!.trim(),
//       );
//     }

//     return _ListItem(title: '', description: line);
//   }
// }

// class _ListItem {
//   final String title;
//   final String description;

//   _ListItem({
//     required this.title,
//     required this.description,
//   });
// }

// class ImageWidget extends StatelessWidget {
//   final String imageUrl;
//   final String? caption;
//   final String? title;

//   const ImageWidget({
//     Key? key,
//     required this.imageUrl,
//     this.caption,
//     this.title,
//   }) : super(key: key);

//   bool get _isNetwork => imageUrl.startsWith('http');

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // 🔥 TITLE (SEO + UX)
//         if (title != null && title!.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 10),
//             child: Text(
//               title!,
//               style: const TextStyle(height: 1.8),    ),
//           ),

//         // 🖼 IMAGE
//         ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: AspectRatio(
//             aspectRatio: 16 / 9,
//             child: _isNetwork ? _buildNetworkImage() : _buildAssetImage(),
//           ),
//         ),

//         // ✨ CAPTION
//         if (caption != null && caption!.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Text(
//               caption!,
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
//                 fontStyle: FontStyle.italic,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),

//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildNetworkImage() {
//     return Image.network(
//       imageUrl,
//       fit: BoxFit.cover,

//       // 🔄 LOADING
//       loadingBuilder: (context, child, progress) {
//         if (progress == null) return child;

//         return Container(
//           color: Colors.grey[200],
//           child: const Center(child: CircularProgressIndicator()),
//         );
//       },

//       // ❌ ERROR (NO CRASH)
//       errorBuilder: (context, error, stackTrace) {
//         return Container(
//           color: Colors.grey[300],
//           child: const Center(
//             child: Icon(Icons.broken_image, size: 48),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildAssetImage() {
//     return Image.asset(
//       imageUrl,
//       fit: BoxFit.cover,
//       errorBuilder: (context, error, stackTrace) {
//         return Container(
//           color: Colors.grey[300],
//           child: const Center(
//             child: Icon(Icons.broken_image, size: 48),
//           ),
//         );
//       },
//     );
//   }
// }