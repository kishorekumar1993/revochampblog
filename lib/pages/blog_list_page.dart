import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/blog_post.dart';
import '../services/blog_service.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS  (identical to content_widget.dart + newspaper)
// ─────────────────────────────────────────────────────────────
class _T {
  static const paper = Color(0xFFF7F4EF);
  static const ink = Color(0xFF0F0E0C);
  static const accent = Color(0xFFC8401E);
  static const accentLight = Color(0xFFFAEEE9);
  static const muted = Color(0xFF6B6760);
  static const border = Color(0xFFDDD9D2);

  static TextStyle display(
    double size, {
    FontWeight w = FontWeight.w700,
    Color? color,
  }) => GoogleFonts.playfairDisplay(
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

  static TextStyle body(
    double size, {
    FontWeight w = FontWeight.w300,
    Color? color,
  }) => GoogleFonts.dmSans(
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
  List<BlogPost> _all = [];
  List<BlogPost> _filtered = [];
  List<String> _categories = [];
  String? _activeCat;
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

  // ── Data ──────────────────────────────────────────────────
  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await _service.fetchAllBlogPosts();
      _all = posts;
      final cats = <String>{};
      for (final p in posts) cats.addAll(p.categories);
      _categories = cats.toList()..sort();
      _filter();
      setState(() => _loading = false);
    } catch (_) {
      setState(() {
        _error = 'Failed to load posts';
        _loading = false;
      });
    }
  }

  void _filter() {
    var list = _all;
    if (_activeCat != null) {
      list = list.where((p) => p.categories.contains(_activeCat)).toList();
    }
    if (_query.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.title.toLowerCase().contains(_query.toLowerCase()) ||
                p.subtitle.toLowerCase().contains(_query.toLowerCase()),
          )
          .toList();
    }
    _filtered = list;
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.paper,
      body: RepaintBoundary(
        child: NestedScrollView(
          controller: _scroll,
          headerSliverBuilder: (_, __) => [_buildSliverHeader()],
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

  // ── Sliver Header (masthead + hero + filters) ─────────────
  Widget _buildSliverHeader() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Masthead(
            onSearch: (q) => setState(() {
              _query = q;
              _filter();
            }),
            searchController: _search,
          ),
          _HeroHeader(),
          _CategoryBar(
            categories: _categories,
            active: _activeCat,
            onSelect: (c) => setState(() {
              _activeCat = c;
              _filter();
            }),
          ),
        ],
      ),
    );
  }

  // ── Post list ─────────────────────────────────────────────
  Widget _buildList() {
    return LayoutBuilder(
      builder: (context, bc) {
        final isDesktop = bc.maxWidth > 900;
        final isTablet = bc.maxWidth > 600;

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
            'Try a different search or category.',
            style: _T.body(14, color: _T.muted),
          ),
          const SizedBox(height: 20),
          _AccentButton(
            label: 'Clear filters',
            onTap: () => setState(() {
              _activeCat = null;
              _query = '';
              _search.clear();
              _filter();
            }),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  MASTHEAD BAR
// ─────────────────────────────────────────────────────────────
class _Masthead extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final TextEditingController searchController;
  const _Masthead({required this.onSearch, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.ink,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: brand + actions ──────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RevoChamp', style: _T.label(11, color: _T.accent)),
                  const SizedBox(height: 2),
                  Text(
                    'CRM Journal',
                    style: _T.display(20, color: Colors.white),
                  ),
                ],
              ),
              const Spacer(),
              _IconBtn(icon: Icons.bookmark_border_rounded),
              const SizedBox(width: 4),
              _IconBtn(icon: Icons.rss_feed_rounded),
            ],
          ),

          const SizedBox(height: 16),

          // ── Search bar ────────────────────────────────────
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(Icons.search, color: Colors.white38, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearch,
                    style: _T.body(14, color: Colors.white),
                    cursorColor: _T.accent,
                    decoration: InputDecoration(
                      hintText: 'Search articles…',
                      hintStyle: _T.body(14, color: Colors.white38),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      searchController.clear();
                      onSearch('');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.close, color: Colors.white38, size: 16),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Date rule ─────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white12),
                bottom: BorderSide(color: Colors.white12),
              ),
            ),
            child: Row(
              children: [
                Text('March 2026', style: _T.label(10, color: Colors.white38)),
                const Spacer(),
                Text(
                  'Strategy · AI · CRM',
                  style: _T.label(10, color: Colors.white38),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon, color: Colors.white54, size: 20),
    onPressed: () {},
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
  );
}

// ─────────────────────────────────────────────────────────────
//  HERO HEADER  (editorial edition headline)
// ─────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.ink,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Articles',
                  style: _T.display(34, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'In-depth guides on CRM, AI, sales strategy\nand business intelligence.',
                  style: _T.body(13, color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CATEGORY FILTER BAR
// ─────────────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String? active;
  final ValueChanged<String?> onSelect;

  const _CategoryBar({
    required this.categories,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final all = ['All', ...categories];

    return Container(
      color: _T.paper,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: all.length,
              itemBuilder: (_, i) {
                final cat = all[i];
                final isActive = i == 0 ? active == null : active == cat;

                return GestureDetector(
                  onTap: () => onSelect(i == 0 ? null : cat),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: isActive
                              ? _T.label(13, color: _T.ink)
                              : _T.body(
                                  13,
                                  color: _T.muted,
                                  w: FontWeight.w300,
                                ),
                          child: Text(cat),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 1.5,
                          width: isActive ? 20 : 0,
                          color: _T.accent,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: _T.border),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DESKTOP LAYOUT  (feature card left + grid right)
// ─────────────────────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final List<BlogPost> posts;
  const _DesktopLayout({required this.posts});

  @override
  Widget build(BuildContext context) {
    final feature = posts.first;
    final rest = posts.skip(1).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      child: Column(
        children: [
          // ── Top feature row ───────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Big feature card (60 %)
              Expanded(flex: 60, child: _FeatureCard(post: feature)),
              const SizedBox(width: 24),
              // Stack of 2 smaller cards (40 %)
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

          // ── Remaining grid ────────────────────────────────
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
//  FEATURE CARD  (large hero card — first post)
// ─────────────────────────────────────────────────────────────
class _FeatureCard extends StatefulWidget {
  final BlogPost post;
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
              // Image
              if (p.featuredImage != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  transform: _hover
                      ? (Matrix4.identity()..scale(1.005))
                      : Matrix4.identity(),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: p.featuredImage!,
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 300),
                    placeholder: (_, __) =>
                        Container(height: 320, color: _T.border),
                    errorWidget: (_, __, ___) =>
                        Container(height: 320, color: _T.border),
                  ),
                ),

              const SizedBox(height: 16),

              // Category pill
              _CategoryPill(
                label: p.categories.isNotEmpty ? p.categories.first : 'Article',
              ),

              const SizedBox(height: 10),

              // Title
              Text(
                p.title,
                style: _T.display(26),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Subtitle
              if (p.subtitle.isNotEmpty)
                Text(
                  p.subtitle,
                  style: _T.body(14, color: _T.muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 14),

              // Meta
              _CardMeta(post: p),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LIST CARD  (horizontal — used in mobile list + desktop sidebar)
// ─────────────────────────────────────────────────────────────
class _ListCard extends StatefulWidget {
  final BlogPost post;
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
              // Text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryPill(
                      label: p.categories.isNotEmpty
                          ? p.categories.first
                          : 'Article',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.title,
                      style: _T.display(15),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _CardMeta(post: p),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Thumbnail
              if (p.featuredImage != null)
                ClipRect(
                  child: CachedNetworkImage(
                    imageUrl: p.featuredImage!,
                    width: 88,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(width: 88, height: 72, color: _T.border),
                    errorWidget: (_, __, ___) =>
                        Container(width: 88, height: 72, color: _T.border),
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
//  GRID CARD  (used in desktop lower grid)
// ─────────────────────────────────────────────────────────────
class _GridCard extends StatefulWidget {
  final BlogPost post;
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
              // Image
              if (p.featuredImage != null)
                ClipRect(
                  child: CachedNetworkImage(
                    imageUrl: p.featuredImage!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(height: 140, color: _T.border),
                    errorWidget: (_, __, ___) =>
                        Container(height: 140, color: _T.border),
                  ),
                ),

              const SizedBox(height: 14),

              _CategoryPill(
                label: p.categories.isNotEmpty ? p.categories.first : 'Article',
              ),

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
              _CardMeta(post: p),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED SMALL WIDGETS
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

class _CardMeta extends StatelessWidget {
  final BlogPost post;
  const _CardMeta({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(post.author, style: _T.body(11, color: _T.muted)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(width: 2, height: 2, color: _T.border),
        ),
        Text(post.readTime, style: _T.body(11, color: _T.muted)),
      ],
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
