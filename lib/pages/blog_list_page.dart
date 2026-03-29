import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/blog_summary.dart';
import '../services/blog_service.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS — Editorial Dark Luxury
// ─────────────────────────────────────────────────────────────
class _T {
  // Core palette
  static const paper = Color(0xFFF5F2EC);
  static const cream = Color(0xFFEDE9E0);
  static const ink = Color(0xFF0B0A09);
  static const red = Color(0xFFBE3A1A);
  static const redDim = Color(0xFF8C2B12);
  static const redPale = Color(0xFFF7EAE5);
  static const gold = Color(0xFFC9A84C);
  static const muted = Color(0xFF7A7570);
  static const border = Color(0xFFD8D3CA);
  static const dark = Color(0xFF131210);
  static const darkSurface = Color(0xFF1A1814);

  // ── Typography ──────────────────────────────────────────────

  /// Cormorant Garamond – serif display
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
        height: height ?? 1.15,
        letterSpacing: letterSpacing ?? -0.01 * size,
      );

  /// Syne – geometric sans for labels / UI chrome
  static TextStyle syne(double size,
      {FontWeight w = FontWeight.w500,
      Color? color,
      double? letterSpacing}) =>
      GoogleFonts.syne(
        fontSize: size,
        fontWeight: w,
        color: color ?? ink,
        letterSpacing: letterSpacing ?? size * 0.18,
      );

  /// DM Sans – readable body
  static TextStyle body(double size,
      {FontWeight w = FontWeight.w300, Color? color, double? height}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: w,
        color: color ?? ink,
        height: height ?? 1.75,
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
  String? _activeCategory;
  bool _loading = true;
  String? _error;

  final _scroll = ScrollController();
  final _search = TextEditingController();
  final _service = BlogService();

  static const _categories = ['Latest', 'Strategy', 'AI', 'Product', 'Design'];

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
    setState(() { _loading = true; _error = null; });
    try {
      final posts = await _service.fetchPage(1);
      _all = posts;
      _applyFilter();
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = 'Failed to load posts'; _loading = false; });
    }
  }

  void _applyFilter() {
    var list = _all;
    if (_query.isNotEmpty) {
      list = list.where((p) =>
        p.title.toLowerCase().contains(_query.toLowerCase()) ||
        p.summary.toLowerCase().contains(_query.toLowerCase()),
      ).toList();
    }
    _filtered = list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.paper,
      body: NestedScrollView(
        controller: _scroll,
        headerSliverBuilder: (_, _) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _MastheadBar(
                  onSearch: (q) => setState(() { _query = q; _applyFilter(); }),
                  searchController: _search,
                  allPosts: _all,
                ),
                _HeroSection(
                  categories: _categories,
                  activeCategory: _activeCategory,
                  onCategorySelect: (c) => setState(() { _activeCategory = c; }),
                ),
              ],
            ),
          ),
        ],
        body: _loading
            ? _buildLoading()
            : _error != null
                ? _buildError()
                : _filtered.isEmpty
                    ? _buildEmpty()
                    : _buildList(),
      ),
    );
  }

  Widget _buildList() {
    return LayoutBuilder(
      builder: (context, bc) {
        if (bc.maxWidth > 900) return _DesktopLayout(posts: _filtered);
        return RefreshIndicator(
          color: _T.red,
          onRefresh: _fetch,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              if (i == 0) return _FeatureCard(post: _filtered[0]);
              return Column(children: [
                Divider(color: _T.border, height: 1, thickness: 0.5),
                _ListCard(post: _filtered[i]),
              ]);
            },
          ),
        );
      },
    );
  }

  Widget _buildLoading() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 28, height: 28,
        child: CircularProgressIndicator(
          color: _T.red, strokeWidth: 1.5,
        ),
      ),
      const SizedBox(height: 20),
      Text('Loading articles', style: _T.syne(10, color: _T.muted)),
    ]),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 48, height: 48,
          color: _T.redPale,
          child: Icon(Icons.wifi_off_rounded, color: _T.red, size: 22),
        ),
        const SizedBox(height: 24),
        Text('Connection failed', style: _T.serif(22)),
        const SizedBox(height: 8),
        Text('Check your connection and try again.',
            style: _T.body(13, color: _T.muted)),
        const SizedBox(height: 28),
        _PillButton(label: 'Try Again', onTap: _fetch),
      ]),
    ),
  );

  Widget _buildEmpty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('No results', style: _T.serif(28)),
        const SizedBox(height: 8),
        Text('Try a different search term.',
            style: _T.body(13, color: _T.muted)),
        const SizedBox(height: 24),
        _PillButton(
          label: 'Clear search',
          onTap: () => setState(() {
            _query = ''; _search.clear(); _applyFilter();
          }),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  MASTHEAD BAR
// ─────────────────────────────────────────────────────────────
class _MastheadBar extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final TextEditingController searchController;
  final List<BlogSummary> allPosts;

  const _MastheadBar({
    required this.onSearch,
    required this.searchController,
    required this.allPosts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.ink,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        // Brand
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('REVOCHAMP',
                style: _T.syne(7.5, w: FontWeight.w700, color: _T.gold)),
            const SizedBox(height: 1),
            Text('Journal',
                style: _T.serif(20, w: FontWeight.w600, color: Colors.white)),
          ],
        ),

        // Divider
        Container(
          width: 1, height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          color: const Color(0xFF2A2A28),
        ),

        // Nav (desktop)
        if (MediaQuery.of(context).size.width > 700) ...[
          ..._navItems(context),
          const Spacer(),
        ] else
          const Spacer(),

        // Search pill
        GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => _SearchDialog(
              controller: searchController,
              onSearch: onSearch,
              allPosts: allPosts,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A18),
              border: Border.all(color: const Color(0xFF2A2A28), width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.search_rounded,
                  size: 14, color: Colors.white.withValues(alpha: 0.45)),
              const SizedBox(width: 8),
              Text('Search',
                  style: _T.body(11, color: Colors.white.withValues(alpha: 0.4))),
            ]),
          ),
        ),

        const SizedBox(width: 6),
        _IconBtn(icon: Icons.bookmark_border_rounded),
        _IconBtn(icon: Icons.rss_feed_rounded),
      ]),
    );
  }

  List<Widget> _navItems(BuildContext context) {
    const items = ['All', 'Strategy', 'Technology', 'Design', 'Business'];
    return items.map((item) => Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Text(
        item.toUpperCase(),
        style: _T.syne(8.5,
            w: item == 'All' ? FontWeight.w700 : FontWeight.w500,
            color: item == 'All' ? Colors.white : Colors.white38),
      ),
    )).toList();
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon, size: 18, color: Colors.white38),
    onPressed: () {},
    splashRadius: 18,
  );
}

// ─────────────────────────────────────────────────────────────
//  HERO SECTION
// ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final List<String> categories;
  final String? activeCategory;
  final ValueChanged<String?> onCategorySelect;

  const _HeroSection({
    required this.categories,
    required this.activeCategory,
    required this.onCategorySelect,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;

    return Container(
      width: double.infinity,
      color: _T.ink,
      child: Column(children: [
        // Edition bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(children: [
            Text(
              _formatEditionDate(),
              style: _T.syne(8, color: const Color(0xFF444440)),
            ),
            Expanded(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 0.5,
              color: const Color(0xFF222220),
            )),
            Text('48 total articles',
                style: _T.syne(8, color: const Color(0xFF444440))),
          ]),
        ),

        // Headline
        Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 24 : 24, 20,
            isMobile ? 24 : 24, 0,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'All ',
                  style: _T.serif(
                    isMobile ? 44 : 62,
                    w: FontWeight.w700,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: 'Articles',
                  style: _T.serif(
                    isMobile ? 44 : 62,
                    w: FontWeight.w300,
                    italic: true,
                    color: _T.gold,
                    height: 1.0,
                  ),
                ),
              ]),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Insights, ideas and practical guides across technology, strategy, and modern design.',
              style: _T.body(13, color: Colors.white.withValues(alpha: 0.4), height: 1.6),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Category filter
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFF1C1C1A), width: 0.5)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: categories.map((cat) => _CategoryChip(
                label: cat,
                isActive: activeCategory == null
                    ? cat == 'Latest'
                    : activeCategory == cat,
                onTap: () => onCategorySelect(cat == 'Latest' ? null : cat),
              )).toList(),
            ),
          ),
        ),
      ]),
    );
  }

  String _formatEditionDate() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[now.weekday - 1]} · ${months[now.month]} ${now.day}, ${now.year}';
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? _T.red : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: _T.syne(
            8.5,
            w: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? Colors.white : const Color(0xFF555550),
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
  final List<BlogSummary> posts;
  const _DesktopLayout({required this.posts});

  @override
  Widget build(BuildContext context) {
    final feature = posts.first;
    final sidebar = posts.skip(1).take(3).toList();
    final grid = posts.skip(4).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      child: Column(children: [
        // Feature row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 58,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 36, 32, 36),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: _T.border, width: 0.5),
                    ),
                  ),
                  child: _FeatureCard(post: feature),
                ),
              ),
              Expanded(
                flex: 42,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 36, 0, 36),
                  child: Column(
                    children: sidebar.asMap().entries.map((e) {
                      final isLast = e.key == sidebar.length - 1;
                      return Column(children: [
                        _SidebarCard(post: e.value, index: e.key + 2),
                        if (!isLast)
                          const Divider(
                              color: _T.border, height: 1, thickness: 0.5),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Section header
        const Divider(color: _T.border, height: 1, thickness: 0.5),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Row(children: [
            Text('MORE ARTICLES',
                style: _T.syne(8.5, w: FontWeight.w700)),
            const SizedBox(width: 16),
            Expanded(child: Container(height: 0.5, color: _T.border)),
            const SizedBox(width: 16),
            Text('${grid.length} articles',
                style: _T.syne(8, color: _T.muted)),
          ]),
        ),

        // Grid
        if (grid.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              childAspectRatio: 1.45,
            ),
            itemCount: grid.length,
            itemBuilder: (_, i) => _GridCard(post: grid[i]),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FEATURE CARD
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
        onTap: () => context.go('/${p.slug}'),
        // onTap: () => Navigator.pushNamed(context, '/blog/${p.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (p.image != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: _hover
                    ? (Matrix4.identity()..scale(1.008))
                    : Matrix4.identity(),
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(),
                child: CachedNetworkImage(
                  imageUrl: p.image!,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 350),
                  placeholder: (_, _) =>
                      Container(height: 240, color: _T.cream),
                  errorWidget: (_, _, _) =>
                      Container(height: 240, color: _T.cream),
                ),
              )
            else
              Container(
                height: 240,
                width: double.infinity,
                color: _T.dark,
              ),

            const SizedBox(height: 20),

            // Tag
            _TagPill(label: 'Featured'),
            const SizedBox(height: 12),

            // Title
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: _T.serif(
                26,
                color: _hover ? _T.red : _T.ink,
                height: 1.2,
              ),
              child: Text(p.title, maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ),

            const SizedBox(height: 10),
            Text(p.summary,
                style: _T.body(13, color: _T.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),

            const SizedBox(height: 16),
            _MetaRow(date: p.date),

            const SizedBox(height: 16),
            _ReadMore(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SIDEBAR CARD (desktop right column)
// ─────────────────────────────────────────────────────────────
class _SidebarCard extends StatefulWidget {
  final BlogSummary post;
  final int index;
  const _SidebarCard({required this.post, required this.index});
  @override
  State<_SidebarCard> createState() => _SidebarCardState();
}

class _SidebarCardState extends State<_SidebarCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go('/${p.slug}'),
        // onTap: () => Navigator.pushNamed(context, '/blog/${p.slug}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Italic number
              SizedBox(
                width: 30,
                child: Text(
                  '${widget.index}',
                  style: _T.serif(30,
                      w: FontWeight.w300,
                      italic: true,
                      color: _T.border,
                      height: 1.0,
                      letterSpacing: 0),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: _T.serif(15,
                          color: _hover ? _T.red : _T.ink,
                          height: 1.3,
                          letterSpacing: 0),
                      child: Text(p.title,
                          maxLines: 3, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        color: _T.redPale,
                        child: Text('ARTICLE',
                            style: _T.syne(7.5,
                                w: FontWeight.w600, color: _T.red)),
                      ),
                      const SizedBox(width: 8),
                      Text(formatDate(p.date),
                          style: _T.syne(8, color: _T.border)),
                    ]),
                  ],
                ),
              ),
              if (p.image != null) ...[
                const SizedBox(width: 14),
                ClipRect(
                  child: CachedNetworkImage(
                    imageUrl: p.image!,
                    width: 72,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(width: 72, height: 60, color: _T.cream),
                    errorWidget: (_, _, _) =>
                        Container(width: 72, height: 60, color: _T.cream),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LIST CARD (mobile)
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
        // onTap: () => Navigator.pushNamed(context, '/blog/${p.slug}'),
        onTap: () => context.go('/${p.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: _hover ? _T.cream : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TagPill(label: 'Article'),
                    const SizedBox(height: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: _T.serif(16,
                          color: _hover ? _T.red : _T.ink,
                          height: 1.25,
                          letterSpacing: 0),
                      child: Text(p.title,
                          maxLines: 3, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 8),
                    _MetaRow(date: p.date),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (p.image != null)
                ClipRect(
                  child: CachedNetworkImage(
                    imageUrl: p.image!,
                    width: 86,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(width: 86, height: 70, color: _T.cream),
                    errorWidget: (_, _, _) =>
                        Container(width: 86, height: 70, color: _T.cream),
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
//  GRID CARD
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
        onTap: () => context.go('/${p.slug}'),
        // onTap: () => Navigator.pushNamed(context, '/blog/${p.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: _hover ? _T.cream : _T.paper,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.image != null)
                CachedNetworkImage(
                  imageUrl: p.image!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(height: 120, color: _T.cream),
                  errorWidget: (_, _, _) =>
                      Container(height: 120, color: _T.cream),
                )
              else
                Container(height: 120, width: double.infinity, color: _T.cream),

              const SizedBox(height: 14),
              _TagPill(label: 'Article'),
              const SizedBox(height: 10),

              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: _T.serif(15,
                      color: _hover ? _T.red : _T.ink,
                      height: 1.3,
                      letterSpacing: 0),
                  child: Text(p.title,
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDate(p.date),
                      style: _T.syne(8, color: _T.border)),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 24,
                    height: 24,
                    color: _hover ? _T.red : Colors.transparent,
                    // child: Border.all(
                    //     color: _hover ? _T.red : _T.border, width: 0.5),
                    alignment: Alignment.center,
                    child: Text('→',
                        style: _T.body(10,
                            color: _hover ? Colors.white : _T.muted)),
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

// ─────────────────────────────────────────────────────────────
//  SEARCH DIALOG
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
      _results = widget.allPosts.where((p) =>
        p.title.toLowerCase().contains(q) ||
        p.summary.toLowerCase().contains(q),
      ).toList();
    });
    widget.onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      backgroundColor: _T.paper,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 480),
        child: Column(children: [
          // Search input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _T.border, width: 0.5)),
            ),
            child: Row(children: [
              Icon(Icons.search_rounded, size: 16, color: _T.muted),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  autofocus: true,
                  onChanged: _filter,
                  style: _T.body(14),
                  decoration: InputDecoration(
                    hintText: 'Search articles, topics…',
                    hintStyle: _T.body(14, color: _T.border),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: _T.border, width: 0.5),
                  ),
                  child: Text('ESC',
                      style: _T.syne(8, w: FontWeight.w600, color: _T.muted)),
                ),
              ),
            ]),
          ),

          // Results
          Expanded(
            child: _results.isEmpty
                ? Center(child: Text('No results found',
                    style: _T.body(13, color: _T.muted)))
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: _T.border, height: 1, thickness: 0.5),
                    itemBuilder: (_, i) {
                      final p = _results[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        title: Text(p.title,
                            style: _T.serif(15, letterSpacing: 0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(p.summary,
                            style: _T.body(11, color: _T.muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        trailing: Text('→',
                            style: _T.body(14, color: _T.border)),
                        onTap: () {
                          Navigator.pop(context);
                          // Navigator.pushNamed(context, '/blog/${p.slug}');
                     context.go('/${p.slug}');
                        },
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────────────────────
class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      color: _T.red,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 4, height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 5),
        Text(label.toUpperCase(),
            style: _T.syne(7.5, w: FontWeight.w700, color: Colors.white)),
      ]),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final DateTime date;
  const _MetaRow({required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(formatDate(date), style: _T.syne(8, color: _T.border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
            width: 2, height: 2,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: _T.border)),
      ),
      Text('5 min read', style: _T.body(11, color: _T.border)),
    ]);
  }
}

class _ReadMore extends StatefulWidget {
  const _ReadMore();
  @override
  State<_ReadMore> createState() => _ReadMoreState();
}

class _ReadMoreState extends State<_ReadMore> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('CONTINUE READING',
            style: _T.syne(8.5, w: FontWeight.w700, color: _T.red)),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(left: _hover ? 12 : 6),
          child: Text('→', style: _T.body(13, color: _T.red)),
        ),
      ]),
    );
  }
}

class _PillButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _PillButton({required this.label, required this.onTap});
  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
          color: _hover ? _T.redDim : _T.red,
          child: Text(widget.label.toUpperCase(),
              style: _T.syne(9, w: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  UTILITIES
// ─────────────────────────────────────────────────────────────
String formatDate(DateTime date) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month]} ${date.day}, ${date.year}';
}
