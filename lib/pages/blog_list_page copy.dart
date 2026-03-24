import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/blog_summary.dart';          // ← new model
import '../services/blog_service.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS (unchanged)
// ─────────────────────────────────────────────────────────────
class _T {
  static const paper = Color(0xFFF7F4EF);
  static const ink = Color(0xFF0F0E0C);
  static const accent = Color(0xFFC8401E);
  static const accentLight = Color(0xFFFAEEE9);
  static const muted = Color(0xFF6B6760);
  static const border = Color(0xFFDDD9D2);

  static TextStyle display(double size,
          {FontWeight w = FontWeight.w700, Color? color}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: w,
        color: color ?? ink,
        height: 1.2,
      );

  static TextStyle displayItalic(double size, {Color? color}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontStyle: FontStyle.italic,
        color: color ?? ink,
        height: 1.4,
      );

  static TextStyle body(double size,
          {FontWeight w = FontWeight.w300, Color? color}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: w,
        color: color ?? ink,
        height: 1.7,
      );

  static TextStyle label(double size, {Color? color}) => GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: size * 0.13,
        color: color ?? muted,
      );
}

// ─────────────────────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────────────────────
class BlogListPage extends StatefulWidget {
  const BlogListPage({Key? key}) : super(key: key);

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  List<BlogSummary> _all = [];
  List<BlogSummary> _filtered = [];
  String _query = '';
  bool _loading = true;
  String? _error;

  final _scroll = ScrollController();
  final _search = TextEditingController();
  final _service = BlogService();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Fetch first page (or all posts)
      final posts = await _service.fetchPage(1); // adjust pagination if needed
      _all = posts;
      _applyFilter();
      setState(() => _loading = false);
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        _error = 'Failed to load posts';
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    var list = _all;
    if (_query.isNotEmpty) {
      list = list.where((p) {
        return p.title.toLowerCase().contains(_query.toLowerCase()) ||
            p.summary.toLowerCase().contains(_query.toLowerCase());
      }).toList();
    }
    _filtered = list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.paper,
      body: RepaintBoundary(
        child: NestedScrollView(
          controller: _scroll,
          headerSliverBuilder: (_, _) => [_buildSliverHeader()],
          body: _loading
              ? _buildLoading()
              : _error != null
                  ? _buildError()
                  : _filtered.isEmpty
                      ? _buildEmpty()
                      : _buildList(),
        ),
      ),
    );
  }

  // ── Sliver Header (masthead + hero) ──────────────────────
  Widget _buildSliverHeader() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Masthead(
            onSearch: (q) => setState(() {
              _query = q;
              _applyFilter();
            }),
            searchController: _search,
            allPosts: _all,
          ),
          const _HeroHeader(),
          // Category bar removed because categories not in summary
        ],
      ),
    );
  }

  // ── Post list ─────────────────────────────────────────────
  Widget _buildList() {
    return LayoutBuilder(
      builder: (context, bc) {
        final isDesktop = bc.maxWidth > 900;
        if (isDesktop) {
          return _DesktopLayout(posts: _filtered);
        }
        return RefreshIndicator(
          color: _T.accent,
          onRefresh: _fetch,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              if (i == 0) return _FeatureCard(post: _filtered[0]);
              return Column(
                children: [
                  const Divider(color: _T.border, height: 1),
                  _ListCard(post: _filtered[i]),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoading() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _T.accent),
            const SizedBox(height: 16),
            Text('Loading articles…', style: _T.body(13, color: _T.muted)),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                color: _T.accentLight,
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: _T.accent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text('Failed to load', style: _T.display(18)),
              const SizedBox(height: 8),
              Text(
                'Check your connection and try again.',
                style: _T.body(14, color: _T.muted),
              ),
              const SizedBox(height: 24),
              _AccentButton(label: 'Try Again', onTap: _fetch),
            ],
          ),
        ),
      );

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No results', style: _T.display(22)),
              const SizedBox(height: 8),
              Text(
                'Try a different search.',
                style: _T.body(14, color: _T.muted),
              ),
              const SizedBox(height: 20),
              _AccentButton(
                label: 'Clear search',
                onTap: () => setState(() {
                  _query = '';
                  _search.clear();
                  _applyFilter();
                }),
              ),
            ],
          ),
        ),
      );
}

String formatDate(DateTime date) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[date.month]} ${date.day}, ${date.year}';
}

// ─────────────────────────────────────────────────────────────
//  MASTHEAD BAR (updated to use BlogSummary)
// ─────────────────────────────────────────────────────────────
class _Masthead extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final TextEditingController searchController;
  final List<BlogSummary> allPosts;

  const _Masthead({
    required this.onSearch,
    required this.searchController,
    required this.allPosts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.ink,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RevoChamp', style: _T.label(10, color: _T.accent)),
              const SizedBox(height: 2),
              Text(
                'Journal',
                style: _T.display(18, color: Colors.white),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: () {
              Future.microtask(() {
                showDialog(
                  context: context,
                  builder: (_) => _SearchDialog(
                    controller: searchController,
                    onSearch: onSearch,
                    allPosts: allPosts,
                  ),
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.rss_feed, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SEARCH DIALOG (updated to use BlogSummary)
// ─────────────────────────────────────────────────────────────
class _SearchDialog extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final List<BlogSummary> allPosts;

  const _SearchDialog({
    required this.controller,
    required this.onSearch,
    required this.allPosts,
  });

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  List<BlogSummary> _results = [];

  @override
  void initState() {
    super.initState();
    _results = widget.allPosts;
  }

  void _filter(String query) {
    final q = query.toLowerCase();
    setState(() {
      _results = widget.allPosts.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.summary.toLowerCase().contains(q);
      }).toList();
    });
    widget.onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      backgroundColor: _T.paper,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: widget.controller,
                autofocus: true,
                onChanged: _filter,
                style: _T.body(14),
                decoration: InputDecoration(
                  hintText: 'Search articles...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: _T.body(14, color: _T.muted),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final p = _results[i];
                        return ListTile(
                          title: Text(
                            p.title,
                            style: _T.display(14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            p.summary,
                            style: _T.body(12, color: _T.muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/blog/${p.slug}');
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HERO HEADER (unchanged)
// ─────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 20 : 40,
        0,
        isMobile ? 20 : 40,
        isMobile ? 24 : 36,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0E0C), Color(0xFF1A1815)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: isMobile ? _buildMobile() : _buildDesktop(),
    );
  }

  Widget _buildDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Articles',
                style: _T.display(42, w: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Insights, ideas and practical guides across tech, business and design.',
                style: _T.body(15, color: Colors.white70),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Articles',
          style: _T.display(30, w: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          'Insights, ideas and practical guides across tech, business and design.',
          style: _T.body(14, color: Colors.white70),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DESKTOP LAYOUT (uses BlogSummary)
// ─────────────────────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final List<BlogSummary> posts;
  const _DesktopLayout({required this.posts});

  @override
  Widget build(BuildContext context) {
    final feature = posts.first;
    final rest = posts.skip(1).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 60, child: _FeatureCard(post: feature)),
              const SizedBox(width: 24),
              Expanded(
                flex: 40,
                child: Column(
                  children: [
                    if (rest.isNotEmpty) _ListCard(post: rest[0]),
                    if (rest.length > 1) ...[
                      const SizedBox(height: 1),
                      const Divider(color: _T.border, height: 1),
                      _ListCard(post: rest[1]),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: _T.border, thickness: 1.5),
          const SizedBox(height: 32),
          if (rest.length > 2)
            LayoutBuilder(
              builder: (_, bc) {
                final cols = bc.maxWidth > 900 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                    childAspectRatio: 1.52,
                  ),
                  itemCount: rest.length - 2,
                  itemBuilder: (_, i) => _GridCard(post: rest[i + 2]),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FEATURE CARD (BlogSummary)
// ─────────────────────────────────────────────────────────────
class _FeatureCard extends StatefulWidget {
  final BlogSummary post;
  const _FeatureCard({required this.post});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/blog/${p.slug}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.image != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  transform: _hover
                      ? (Matrix4.identity()..scale(1.005))
                      : Matrix4.identity(),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(borderRadius: BorderRadius.zero),
                  child: CachedNetworkImage(
                    imageUrl: p.image!,
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 300),
                    placeholder: (_, _) => Container(height: 320, color: _T.border),
                    errorWidget: (_, _, _) => Container(height: 320, color: _T.border),
                  ),
                ),
              const SizedBox(height: 16),
              _CategoryPill(label: 'Article'), // no category from summary, use generic
              const SizedBox(height: 10),
              Text(
                p.title,
                style: _T.display(26),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                p.summary,
                style: _T.body(14, color: _T.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Text(
                formatDate(p.date),
                style: _T.body(11, color: _T.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LIST CARD (BlogSummary)
// ─────────────────────────────────────────────────────────────
class _ListCard extends StatefulWidget {
  final BlogSummary post;
  const _ListCard({required this.post});

  @override
  State<_ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<_ListCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/blog/${p.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: _hover ? _T.accentLight.withOpacity(0.35) : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryPill(label: 'Article'),
                    const SizedBox(height: 6),
                    Text(
                      p.title,
                      style: _T.display(15),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatDate(p.date),
                      style: _T.body(11, color: _T.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              if (p.image != null)
                ClipRect(
                  child: CachedNetworkImage(
                    imageUrl: p.image!,
                    width: 88,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(width: 88, height: 72, color: _T.border),
                    errorWidget: (_, _, _) => Container(width: 88, height: 72, color: _T.border),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  GRID CARD (BlogSummary)
// ─────────────────────────────────────────────────────────────
class _GridCard extends StatefulWidget {
  final BlogSummary post;
  const _GridCard({required this.post});

  @override
  State<_GridCard> createState() => _GridCardState();
}

class _GridCardState extends State<_GridCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/blog/${p.slug}'),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _hover ? _T.accentLight.withOpacity(0.25) : _T.paper,
            border: Border.all(color: _T.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.image != null)
                ClipRect(
                  child: CachedNetworkImage(
                    imageUrl: p.image!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(height: 140, color: _T.border),
                    errorWidget: (_, _, _) => Container(height: 140, color: _T.border),
                  ),
                ),
              const SizedBox(height: 14),
              _CategoryPill(label: 'Article'),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  p.title,
                  style: _T.display(15),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                formatDate(p.date),
                style: _T.body(11, color: _T.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────────────────────
class _CategoryPill extends StatelessWidget {
  final String label;
  const _CategoryPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      color: _T.accent,
      child: Text(label.toUpperCase(), style: _T.label(9, color: Colors.white)),
    );
  }
}

class _AccentButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _AccentButton({required this.label, required this.onTap});

  @override
  State<_AccentButton> createState() => _AccentButtonState();
}

class _AccentButtonState extends State<_AccentButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: _hover ? const Color(0xFFA33318) : _T.accent,
          child: Text(widget.label, style: _T.label(12, color: Colors.white)),
        ),
      ),
    );
  }
}


// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/blog_post.dart';
// import '../services/blog_service.dart';

// // ─────────────────────────────────────────────────────────────
// //  DESIGN TOKENS  (identical to content_widget.dart + newspaper)
// // ─────────────────────────────────────────────────────────────
// class _T {
//   static const paper = Color(0xFFF7F4EF);
//   static const ink = Color(0xFF0F0E0C);
//   static const accent = Color(0xFFC8401E);
//   static const accentLight = Color(0xFFFAEEE9);
//   static const muted = Color(0xFF6B6760);
//   static const border = Color(0xFFDDD9D2);

//   static TextStyle display(
//     double size, {
//     FontWeight w = FontWeight.w700,
//     Color? color,
//   }) => GoogleFonts.playfairDisplay(
//     fontSize: size,
//     fontWeight: w,
//     color: color ?? ink,
//     height: 1.2,
//   );

//   static TextStyle displayItalic(double size, {Color? color}) =>
//       GoogleFonts.playfairDisplay(
//         fontSize: size,
//         fontStyle: FontStyle.italic,
//         color: color ?? ink,
//         height: 1.4,
//       );

//   static TextStyle body(
//     double size, {
//     FontWeight w = FontWeight.w300,
//     Color? color,
//   }) => GoogleFonts.dmSans(
//     fontSize: size,
//     fontWeight: w,
//     color: color ?? ink,
//     height: 1.7,
//   );

//   static TextStyle label(double size, {Color? color}) => GoogleFonts.dmSans(
//     fontSize: size,
//     fontWeight: FontWeight.w500,
//     letterSpacing: size * 0.13,
//     color: color ?? muted,
//   );
// }

// // ─────────────────────────────────────────────────────────────
// //  PAGE
// // ─────────────────────────────────────────────────────────────
// class BlogListPage extends StatefulWidget {
//   const BlogListPage({Key? key}) : super(key: key);

//   @override
//   State<BlogListPage> createState() => _BlogListPageState();
// }

// class _BlogListPageState extends State<BlogListPage> {
//   List<BlogPost> _all = [];
//   List<BlogPost> _filtered = [];
//   List<String> _categories = [];
//   String? _activeCat;
//   String _query = '';
//   bool _loading = true;
//   String? _error;

//   final _scroll = ScrollController();
//   final _search = TextEditingController();
//   final _service = BlogService();

//   @override
//   void initState() {
//     super.initState();
//     _fetch();
//   }

//   @override
//   void dispose() {
//     _scroll.dispose();
//     _search.dispose();
//     super.dispose();
//   }

//   // ── Data ──────────────────────────────────────────────────
//   Future<void> _fetch() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       // final posts = await _service.fetchAllBlogPosts();
//       final posts = await _service.fetchPage(1);
//       _all = posts;
//       final cats = <String>{};
//       for (final p in posts) cats.addAll(p.categories);
//       _categories = cats.toList()..sort();
//       _filter();
//       setState(() => _loading = false);
//     } catch (_) {
//       setState(() {
//         _error = 'Failed to load posts';
//         _loading = false;
//       });
//     }
//   }


//   void _filter() {
//     var list = _all;
//     if (_activeCat != null) {
//       list = list.where((p) => p.categories.contains(_activeCat)).toList();
//     }
//     if (_query.isNotEmpty) {
//       list = list
//           .where(
//             (p) =>
//                 p.title.toLowerCase().contains(_query.toLowerCase()) ||
//                 p.subtitle.toLowerCase().contains(_query.toLowerCase()),
//           )
//           .toList();
//     }
//     _filtered = list;
//   }

//   // ── Build ─────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _T.paper,
//       body: RepaintBoundary(
//         child: NestedScrollView(
//           controller: _scroll,
//           headerSliverBuilder: (_, _) => [_buildSliverHeader()],
//           body: _loading
//               ? _buildLoading()
//               : _error != null
//               ? _buildError()
//               : _filtered.isEmpty
//               ? _buildEmpty()
//               : _buildList(),
//         ),
//       ),
//     );
//   }

//   // ── Sliver Header (masthead + hero + filters) ─────────────
//   Widget _buildSliverHeader() {
//     return SliverToBoxAdapter(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _Masthead(
//             onSearch: (q) => setState(() {
//               _query = q;
//               _filter();
//             }),
//             searchController: _search,
//         allPosts: _all, // ✅ PASS HERE
//           ),
//           _HeroHeader(),
//           _CategoryBar(
//             categories: _categories,
//             active: _activeCat,
//             onSelect: (c) => setState(() {
//               _activeCat = c;
//               _filter();
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Post list ─────────────────────────────────────────────
//   Widget _buildList() {
//     return LayoutBuilder(
//       builder: (context, bc) {
//         final isDesktop = bc.maxWidth > 900;
//         final isTablet = bc.maxWidth > 600;

//         if (isDesktop) {
//           return _DesktopLayout(posts: _filtered);
//         }
//         return RefreshIndicator(
//           color: _T.accent,
//           onRefresh: _fetch,
//           child: ListView.builder(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
//             itemCount: _filtered.length,
//             itemBuilder: (_, i) {
//               if (i == 0) return _FeatureCard(post: _filtered[0]);
//               return Column(
//                 children: [
//                   const Divider(color: _T.border, height: 1),
//                   _ListCard(post: _filtered[i]),
//                 ],
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLoading() => Center(
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const CircularProgressIndicator(color: _T.accent),
//         const SizedBox(height: 16),
//         Text('Loading articles…', style: _T.body(13, color: _T.muted)),
//       ],
//     ),
//   );

//   Widget _buildError() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(32),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 56,
//             height: 56,
//             color: _T.accentLight,
//             child: const Icon(
//               Icons.wifi_off_rounded,
//               color: _T.accent,
//               size: 28,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text('Failed to load', style: _T.display(18)),
//           const SizedBox(height: 8),
//           Text(
//             'Check your connection and try again.',
//             style: _T.body(14, color: _T.muted),
//           ),
//           const SizedBox(height: 24),
//           _AccentButton(label: 'Try Again', onTap: _fetch),
//         ],
//       ),
//     ),
//   );

//   Widget _buildEmpty() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(32),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text('No results', style: _T.display(22)),
//           const SizedBox(height: 8),
//           Text(
//             'Try a different search or category.',
//             style: _T.body(14, color: _T.muted),
//           ),
//           const SizedBox(height: 20),
//           _AccentButton(
//             label: 'Clear filters',
//             onTap: () => setState(() {
//               _activeCat = null;
//               _query = '';
//               _search.clear();
//               _filter();
//             }),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// String formatDate(DateTime? date) {
//   if (date == null) return '';

//   const months = [
//     '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//   ];

//   return '${months[date.month]} ${date.day}, ${date.year}';
// }

// // ─────────────────────────────────────────────────────────────
// //  MASTHEAD BAR
// // ─────────────────────────────────────────────────────────────
// class _Masthead extends StatelessWidget {
//   final ValueChanged<String> onSearch;
//   final TextEditingController searchController;
//  final List<BlogPost> allPosts; // ✅ ADD THIS
//   const _Masthead({
//     required this.onSearch,
//     required this.searchController,
//      required this.allPosts,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: _T.ink,
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
//       child: Row(
//         children: [
//           // Logo / Brand
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('RevoChamp', style: _T.label(10, color: _T.accent)),
//               const SizedBox(height: 2),
//               Text(
//                 'Journal',
//                 style: _T.display(18, color: Colors.white),
//               ),
//             ],
//           ),

//           const Spacer(),

//           // Search (icon only)
//           IconButton(
//             icon: const Icon(Icons.search, color: Colors.white70),
//            onPressed: () {
//   Future.microtask(() {
//     showDialog(
//       context: context,
//       builder: (_) => _SearchDialog(
//         controller: searchController,
//         onSearch: onSearch,
//          allPosts: allPosts, // pass your blog list
//       ),
//     );
//   });
// }
//           ),

//           IconButton(
//             icon: const Icon(Icons.bookmark_border, color: Colors.white70),
//             onPressed: () {},
//           ),

//           IconButton(
//             icon: const Icon(Icons.rss_feed, color: Colors.white70),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
// class _SearchDialog extends StatefulWidget {
//   final TextEditingController controller;
//   final ValueChanged<String> onSearch;
//   final List<BlogPost> allPosts; // pass full list

//   const _SearchDialog({
//     required this.controller,
//     required this.onSearch,
//     required this.allPosts,
//   });

//   @override
//   State<_SearchDialog> createState() => _SearchDialogState();
// }

// class _SearchDialogState extends State<_SearchDialog> {
//   List<BlogPost> _results = [];

//   @override
//   void initState() {
//     super.initState();
//     _results = widget.allPosts;
//   }

//   void _filter(String query) {
//     final q = query.toLowerCase();

//     setState(() {
//       _results = widget.allPosts.where((p) {
//         return p.title.toLowerCase().contains(q) ||
//             p.subtitle.toLowerCase().contains(q);
//       }).toList();
//     });

//     widget.onSearch(query);
//   }

//   @override
// @override
// Widget build(BuildContext context) {
//   return Dialog(
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12),
//     ),
//     insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
//     backgroundColor: _T.paper,
//     child: ConstrainedBox(
//       constraints: const BoxConstraints(
//         maxWidth: 600,   // desktop nice width
//         maxHeight: 500,  // NOT full screen
//       ),
//       child: Column(
//         children: [
//           // 🔍 Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               controller: widget.controller,
//               autofocus: true,
//               onChanged: _filter,
//               style: _T.body(14),
//               decoration: InputDecoration(
//                 hintText: 'Search articles...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 12),
//               ),
//             ),
//           ),

//           const Divider(height: 1),

//           // 📜 Results (scrollable)
//           Expanded(
//             child: _results.isEmpty
//                 ? Center(
//                     child: Text(
//                       'No results found',
//                       style: _T.body(14, color: _T.muted),
//                     ),
//                   )
//                 : ListView.separated(
//                     itemCount: _results.length,
//                     separatorBuilder: (_, _) =>
//                         const Divider(height: 1),
//                     itemBuilder: (_, i) {
//                       final p = _results[i];

//                       return ListTile(
//                         title: Text(
//                           p.title,
//                           style: _T.display(14),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         subtitle: Text(
//                           p.subtitle,
//                           style: _T.body(12, color: _T.muted),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.pushNamed(
//                               context, '/blog/${p.slug}');
//                         },
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
// }

// // ─────────────────────────────────────────────────────────────
// //  HERO HEADER  (editorial edition headline)
// // ─────────────────────────────────────────────────────────────
// class _HeroHeader extends StatelessWidget {
//   final String? title;
//   final List<String>? categories;

//   const _HeroHeader({
//     this.title,
//     this.categories,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final isMobile = w < 700;

//     final displayTitle = title ?? 'All Articles';
//     final categoryText =
//         (categories != null && categories!.isNotEmpty)
//             ? categories!.take(3).join(' · ')
//             : 'Strategy · AI · CRM';

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.fromLTRB(
//         isMobile ? 20 : 40,
//         0,
//         isMobile ? 20 : 40,
//         isMobile ? 24 : 36,
//       ),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color(0xFF0F0E0C),
//             Color(0xFF1A1815),
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: isMobile
//           ? _buildMobile(displayTitle, categoryText)
//           : _buildDesktop(displayTitle, categoryText),
//     );
//   }

//   // ─────────────────────────────────────────────
//   // DESKTOP
//   // ─────────────────────────────────────────────
// Widget _buildDesktop(String title, String categoryText) {
//   return Row(
//     crossAxisAlignment: CrossAxisAlignment.end,
//     children: [
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title (stronger presence)
//             Text(
//               title,
//               style: _T.display(42, w: FontWeight.w800, color: Colors.white),
//             ),

//             const SizedBox(height: 12),

//             // Subtitle (clean + generic)
//             Text(
//               'Insights, ideas and practical guides across tech, business and design.',
//               style: _T.body(15, color: Colors.white70),
//             ),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     ],
//   );
// }  // ─────────────────────────────────────────────
//   // MOBILE
//   // ─────────────────────────────────────────────
// Widget _buildMobile(String title, String categoryText) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // Title
//       Text(
//         title,
//         style: _T.display(30, w: FontWeight.w800, color: Colors.white),
//       ),

//       const SizedBox(height: 10),

//       // Generic subtitle
//       Text(
//         'Insights, ideas and practical guides across tech, business and design.',
//         style: _T.body(14, color: Colors.white70),
//       ),

//       const SizedBox(height: 16),
//     ],
//   );
// }}
// // ─────────────────────────────────────────────────────────────
// //  CATEGORY FILTER BAR
// // ─────────────────────────────────────────────────────────────
// class _CategoryBar extends StatelessWidget {
//   final List<String> categories;
//   final String? active;
//   final ValueChanged<String?> onSelect;

//   const _CategoryBar({
//     required this.categories,
//     required this.active,
//     required this.onSelect,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final all = ['All', ...categories];

//     return Container(
//       color: _T.paper,
//       child: Column(
//         children: [
//           SizedBox(
//             height: 48,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: all.length,
//               itemBuilder: (_, i) {
//                 final cat = all[i];
//                 final isActive = i == 0 ? active == null : active == cat;

//                 return GestureDetector(
//                   onTap: () => onSelect(i == 0 ? null : cat),
//                   child: Padding(
//                     padding: const EdgeInsets.only(right: 24),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         AnimatedDefaultTextStyle(
//                           duration: const Duration(milliseconds: 180),
//                           style: isActive
//                               ? _T.label(13, color: _T.ink)
//                               : _T.body(
//                                   13,
//                                   color: _T.muted,
//                                   w: FontWeight.w300,
//                                 ),
//                           child: Text(cat),
//                         ),
//                         const SizedBox(height: 4),
//                         AnimatedContainer(
//                           duration: const Duration(milliseconds: 180),
//                           height: 1.5,
//                           width: isActive ? 20 : 0,
//                           color: _T.accent,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const Divider(height: 1, thickness: 1, color: _T.border),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  DESKTOP LAYOUT  (feature card left + grid right)
// // ─────────────────────────────────────────────────────────────
// class _DesktopLayout extends StatelessWidget {
//   final List<BlogPost> posts;
//   const _DesktopLayout({required this.posts});

//   @override
//   Widget build(BuildContext context) {
//     final feature = posts.first;
//     final rest = posts.skip(1).toList();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
//       child: Column(
//         children: [
//           // ── Top feature row ───────────────────────────────
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Big feature card (60 %)
//               Expanded(flex: 60, child: _FeatureCard(post: feature)),
//               const SizedBox(width: 24),
//               // Stack of 2 smaller cards (40 %)
//               Expanded(
//                 flex: 40,
//                 child: Column(
//                   children: [
//                     if (rest.isNotEmpty) _ListCard(post: rest[0]),
//                     if (rest.length > 1) ...[
//                       const SizedBox(height: 1),
//                       const Divider(color: _T.border, height: 1),
//                       _ListCard(post: rest[1]),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 32),
//           const Divider(color: _T.border, thickness: 1.5),
//           const SizedBox(height: 32),

//           // ── Remaining grid ────────────────────────────────
//           if (rest.length > 2)
//             LayoutBuilder(
//               builder: (_, bc) {
//                 final cols = bc.maxWidth > 900 ? 3 : 2;
//                 return GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: cols,
//                     crossAxisSpacing: 1,
//                     mainAxisSpacing: 1,
//                     childAspectRatio: 1.52,
//                   ),
//                   itemCount: rest.length - 2,
//                   itemBuilder: (_, i) => _GridCard(post: rest[i + 2]),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  FEATURE CARD  (large hero card — first post)
// // ─────────────────────────────────────────────────────────────
// class _FeatureCard extends StatefulWidget {
//   final BlogPost post;
//   const _FeatureCard({required this.post});

//   @override
//   State<_FeatureCard> createState() => _FeatureCardState();
// }

// class _FeatureCardState extends State<_FeatureCard> {
//   bool _hover = false;

//   @override
//   Widget build(BuildContext context) {
//     final p = widget.post;

//     return MouseRegion(
//       onEnter: (_) => setState(() => _hover = true),
//       onExit: (_) => setState(() => _hover = false),
//       child: GestureDetector(
//         onTap: () => Navigator.pushNamed(context, '/blog/${p.slug}'),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 28),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Image
//               if (p.featuredImage != null)
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 250),
//                   transform: _hover
//                       ? (Matrix4.identity()..scale(1.005))
//                       : Matrix4.identity(),
//                   clipBehavior: Clip.antiAlias,
//                   decoration: const BoxDecoration(
//                     borderRadius: BorderRadius.zero,
//                   ),
//                   child: CachedNetworkImage(
//                     imageUrl: p.featuredImage!,
//                     height: 320,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     fadeInDuration: const Duration(milliseconds: 300),
//                     placeholder: (_, _) =>
//                         Container(height: 320, color: _T.border),
//                     errorWidget: (_, _, _) =>
//                         Container(height: 320, color: _T.border),
//                   ),
//                 ),

//               const SizedBox(height: 16),

//               // Category pill
//               _CategoryPill(
//                 label: p.categories.isNotEmpty ? p.categories.first : 'Article',
//               ),

//               const SizedBox(height: 10),

//               // Title
//               Text(
//                 p.title,
//                 style: _T.display(26),
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),

//               const SizedBox(height: 8),

//               // Subtitle
//               if (p.subtitle.isNotEmpty)
//                 Text(
//                   p.subtitle,
//                   style: _T.body(14, color: _T.muted),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),

//               const SizedBox(height: 14),

//               // Meta
//               _CardMeta(post: p),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  LIST CARD  (horizontal — used in mobile list + desktop sidebar)
// // ─────────────────────────────────────────────────────────────
// class _ListCard extends StatefulWidget {
//   final BlogPost post;
//   const _ListCard({required this.post});

//   @override
//   State<_ListCard> createState() => _ListCardState();
// }

// class _ListCardState extends State<_ListCard> {
//   bool _hover = false;

//   @override
//   Widget build(BuildContext context) {
//     final p = widget.post;

//     return MouseRegion(
//       onEnter: (_) => setState(() => _hover = true),
//       onExit: (_) => setState(() => _hover = false),
//       child: GestureDetector(
//         onTap: () => Navigator.pushNamed(context, '/blog/${p.slug}'),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           color: _hover ? _T.accentLight.withOpacity(0.35) : Colors.transparent,
//           padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Text block
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _CategoryPill(
//                       label: p.categories.isNotEmpty
//                           ? p.categories.first
//                           : 'Article',
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       p.title,
//                       style: _T.display(15),
//                       maxLines: 3,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 6),
//                     _CardMeta(post: p),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 14),

//               // Thumbnail
//               if (p.featuredImage != null)
//                 ClipRect(
//                   child: CachedNetworkImage(
//                     imageUrl: p.featuredImage!,
//                     width: 88,
//                     height: 72,
//                     fit: BoxFit.cover,
//                     placeholder: (_, _) =>
//                         Container(width: 88, height: 72, color: _T.border),
//                     errorWidget: (_, _, _) =>
//                         Container(width: 88, height: 72, color: _T.border),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  GRID CARD  (used in desktop lower grid)
// // ─────────────────────────────────────────────────────────────
// class _GridCard extends StatefulWidget {
//   final BlogPost post;
//   const _GridCard({required this.post});

//   @override
//   State<_GridCard> createState() => _GridCardState();
// }

// class _GridCardState extends State<_GridCard> {
//   bool _hover = false;

//   @override
//   Widget build(BuildContext context) {
//     final p = widget.post;

//     return MouseRegion(
//       onEnter: (_) => setState(() => _hover = true),
//       onExit: (_) => setState(() => _hover = false),
//       child: GestureDetector(
//         onTap: () => Navigator.pushNamed(context, '/blog/${p.slug}'),
//         child: Container(
//           padding: const EdgeInsets.all(18),
//           decoration: BoxDecoration(
//             color: _hover ? _T.accentLight.withOpacity(0.25) : _T.paper,
//             border: Border.all(color: _T.border, width: 0.5),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Image
//               if (p.featuredImage != null)
//                 ClipRect(
//                   child: CachedNetworkImage(
//                     imageUrl: p.featuredImage!,
//                     height: 140,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     placeholder: (_, _) =>
//                         Container(height: 140, color: _T.border),
//                     errorWidget: (_, _, _) =>
//                         Container(height: 140, color: _T.border),
//                   ),
//                 ),

//               const SizedBox(height: 14),

//               _CategoryPill(
//                 label: p.categories.isNotEmpty ? p.categories.first : 'Article',
//               ),

//               const SizedBox(height: 8),

//               Expanded(
//                 child: Text(
//                   p.title,
//                   style: _T.display(15),
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),

//               const SizedBox(height: 10),
//               _CardMeta(post: p),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  SHARED SMALL WIDGETS
// // ─────────────────────────────────────────────────────────────
// class _CategoryPill extends StatelessWidget {
//   final String label;
//   const _CategoryPill({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       color: _T.accent,
//       child: Text(label.toUpperCase(), style: _T.label(9, color: Colors.white)),
//     );
//   }
// }

// class _CardMeta extends StatelessWidget {
//   final BlogPost post;
//   const _CardMeta({required this.post});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(post.author, style: _T.body(11, color: _T.muted)),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 6),
//           child: Container(width: 2, height: 2, color: _T.border),
//         ),
//         Text(post.readTime, style: _T.body(11, color: _T.muted)),
//       ],
//     );
//   }
// }

// class _AccentButton extends StatefulWidget {
//   final String label;
//   final VoidCallback onTap;
//   const _AccentButton({required this.label, required this.onTap});

//   @override
//   State<_AccentButton> createState() => _AccentButtonState();
// }

// class _AccentButtonState extends State<_AccentButton> {
//   bool _hover = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _hover = true),
//       onExit: (_) => setState(() => _hover = false),
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 150),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           color: _hover ? const Color(0xFFA33318) : _T.accent,
//           child: Text(widget.label, style: _T.label(12, color: Colors.white)),
//         ),
//       ),
//     );
//   }
// }
