import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/blog_summary.dart';
import '../../services/blog_service.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS — Modern Luxury Editorial
// ─────────────────────────────────────────────────────────────
class _T {
  // Premium color palette
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

  /// Cormorant Garamond – elegant serif display
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

  /// Syne – modern geometric sans
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

  /// DM Sans – highly readable body text
  static TextStyle body(double size,
      {FontWeight w = FontWeight.w300,
      Color? color,
      double? height,
      double? letterSpacing}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: w,
        color: color ?? ink,
        height: height ?? 1.65,
        letterSpacing: letterSpacing ?? 0.2,
      );
}

// ─────────────────────────────────────────────────────────────
//  MAIN PAGE
// ─────────────────────────────────────────────────────────────
class NewListPage extends StatefulWidget {
  const NewListPage({Key? key}) : super(key: key);

  @override
  State<NewListPage> createState() => _NewListPageState();
}

class _NewListPageState extends State<NewListPage> {
  // Data management
  List<BlogSummary> _blogs = [];
  List<BlogSummary> _filtered = [];
  String _query = '';
  String? _activeCategory;
  int _page = 1;
  bool _hasMore = true;
  bool _loading = true;
  String? _error;

  // Controllers
  final _search = TextEditingController();
  final _service = BlogService();
  final _scroll = ScrollController();

  static const _categories = [
    "All",
    "Technology",
    "AI",
    "Business",
    "Finance",
    "Insurance",
    "Startups",
    "Politics",
    "International",
    "Health",
    "Education",
    "Entertainment",
    "Consumer"
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 500) {
      _loadMore();
    }
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
      _blogs.clear();
      _hasMore = true;
    });

    try {
      final response = await _service.fetchPage(_page);
      setState(() {
        _blogs = response.data;
        _hasMore = response.page < response.totalPages;
        _page++;
        _loading = false;
      });
      _applyFilter();
    } catch (e) {
      setState(() {
        _error = 'Failed to load posts';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loading) return;

    setState(() => _loading = true);

    try {
      BlogResponse response;

      if (_activeCategory != null && _activeCategory != 'All') {
        response = await _service.fetchByCategory(_activeCategory!, page: _page);
      } else {
        response = await _service.fetchPage(_page);
      }

      setState(() {
        _blogs.addAll(response.data);
        _hasMore = response.page < response.totalPages;
        _page++;
        _loading = false;
      });

      _applyFilter();
    } catch (e) {
      setState(() {
        _error = 'Failed to load more posts';
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    var list = _blogs;

    if (_query.isNotEmpty) {
      list = list.where((p) =>
          p.title.toLowerCase().contains(_query.toLowerCase()) ||
          p.summary.toLowerCase().contains(_query.toLowerCase())).toList();
    }

    setState(() => _filtered = list);
  }

  void _updateCategory(String? category) async {
    setState(() {
      _activeCategory = category;
      _loading = true;
      _error = null;
      _page = 1;
      _blogs.clear();
    });

    try {
      BlogResponse response;

      if (category == null || category == 'All') {
        response = await _service.fetchPage(1);
      } else {
        response = await _service.fetchByCategory(category.toLowerCase(), page: 1);
      }

      setState(() {
        _blogs = response.data;
        _hasMore = response.page < response.totalPages;
        _page = 2;
        _loading = false;
      });

      _applyFilter();
    } catch (e) {
      setState(() {
        _error = 'Failed to load category';
        _loading = false;
      });
    }
  }

  void _updateSearch(String query) {
    setState(() {
      _query = query;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.paper,
      body: NestedScrollView(
        controller: _scroll,
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _MastheadBar(
                  onSearch: _updateSearch,
                  searchController: _search,
                  allPosts: _blogs,
                ),
                _HeroSection(
                  categories: _categories,
                  activeCategory: _activeCategory,
                  onCategorySelect: _updateCategory,
                  filteredCount: _filtered.length,
                ),
              ],
            ),
          ),
        ],
        body: _loading && _blogs.isEmpty
            ? _buildLoading()
            : _error != null && _blogs.isEmpty
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
        if (bc.maxWidth > 1000) return _DesktopLayout(posts: _filtered);
        if (bc.maxWidth > 600) return _TabletLayout(posts: _filtered);
        return _MobileLayout(posts: _filtered);
      },
    );
  }

  Widget _buildLoading() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          color: _T.red,
          strokeWidth: 2,
        ),
      ),
      const SizedBox(height: 24),
      Text('Loading articles', style: _T.syne(11, color: _T.muted)),
    ]),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _T.redLight,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.wifi_off_rounded, color: _T.red, size: 28),
        ),
        const SizedBox(height: 24),
        Text('Connection failed', style: _T.serif(24, w: FontWeight.w700)),
        const SizedBox(height: 12),
        Text('Check your connection and try again.',
            style: _T.body(14, color: _T.muted, height: 1.6)),
        const SizedBox(height: 32),
        _PillButton(label: 'Try Again', onTap: _fetch),
      ]),
    ),
  );

  Widget _buildEmpty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('No results found', style: _T.serif(28, w: FontWeight.w700)),
        const SizedBox(height: 12),
        Text('Try a different search or category.',
            style: _T.body(14, color: _T.muted, height: 1.6)),
        const SizedBox(height: 32),
        _PillButton(
          label: 'Reset filters',
          onTap: () {
            _search.clear();
            setState(() {
              _query = '';
              _activeCategory = null;
              _applyFilter();
            });
          },
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  MOBILE LAYOUT
// ─────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final List<BlogSummary> posts;
  const _MobileLayout({required this.posts});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _T.red,
      onRefresh: () async {
        // Refresh logic handled by parent
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        itemCount: posts.length,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Column(
              children: [
                _MobileFeatureCard(post: posts[0]),
                const SizedBox(height: 24),
                _SectionDivider(label: 'More Articles'),
                const SizedBox(height: 16),
              ],
            );
          }
          return _MobileArticleCard(post: posts[i]);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TABLET LAYOUT
// ─────────────────────────────────────────────────────────────
class _TabletLayout extends StatelessWidget {
  final List<BlogSummary> posts;
  const _TabletLayout({required this.posts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        children: [
          _TabletFeatureCard(post: posts.first),
          const SizedBox(height: 32),
          _SectionDivider(label: 'More Articles'),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: posts.length - 1,
            itemBuilder: (_, i) => _GridArticleCard(post: posts[i + 1]),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 48),
      child: Column(children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 60,
                child: Padding(
                  padding: const EdgeInsets.only(right: 32),
                  child: _DesktopFeatureCard(post: feature),
                ),
              ),
              Expanded(
                flex: 40,
                child: Column(
                  children: sidebar.asMap().entries.map((e) {
                    final isLast = e.key == sidebar.length - 1;
                    return Column(
                      children: [
                        _SidebarCard(post: e.value, index: e.key + 2),
                        if (!isLast) const SizedBox(height: 24),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        _SectionDivider(label: 'More Articles'),
        const SizedBox(height: 32),
        if (grid.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.3,
            ),
            itemCount: grid.length,
            itemBuilder: (_, i) => _GridArticleCard(post: grid[i]),
          ),
      ]),
    );
  }
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('REVOCHAMP',
                  style: _T.syne(7, w: FontWeight.w700, color: _T.gold)),
              const SizedBox(height: 2),
              Text('NEWSJournal',
                  style: _T.serif(22, w: FontWeight.w700, color: Colors.white)),
            ],
          ),
          if (MediaQuery.of(context).size.width > 700) ...[
            const SizedBox(width: 32),
            Expanded(child: _navItems(context)),
          ] else
            const Spacer(),
          const SizedBox(width: 16),
          _SearchButton(
            controller: searchController,
            onSearch: onSearch,
            allPosts: allPosts,
          ),
        ]),
      ),
    );
  }

  Widget _navItems(BuildContext context) {
    const items = ['All', 'Technology', 'AI', 'Business'];
    return Row(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Text(
                  item.toUpperCase(),
                  style: _T.syne(9,
                      w: item == 'All' ? FontWeight.w700 : FontWeight.w500,
                      color: item == 'All' ? Colors.white : Colors.white54),
                ),
              ))
          .toList(),
    );
  }
}

class _SearchButton extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final List<BlogSummary> allPosts;

  const _SearchButton({
    required this.controller,
    required this.onSearch,
    required this.allPosts,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => _SearchDialog(
          controller: controller,
          onSearch: onSearch,
          allPosts: allPosts,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_rounded,
              size: 16, color: Colors.white.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text('Search',
              style: _T.syne(10, color: Colors.white.withValues(alpha: 0.5))),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HERO SECTION
// ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final List<String> categories;
  final String? activeCategory;
  final ValueChanged<String?> onCategorySelect;
  final int filteredCount;

  const _HeroSection({
    required this.categories,
    required this.activeCategory,
    required this.onCategorySelect,
    required this.filteredCount,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final displayCategory = activeCategory ?? 'All';

    return Container(
      width: double.infinity,
      color: _T.ink,
      child: Column(children: [
        // Metadata bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(children: [
            Text(
              _formatEditionDate(),
              style: _T.syne(8, color: Colors.white.withValues(alpha: 0.4)),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 0.5,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Text('$filteredCount articles',
                style: _T.syne(8, color: Colors.white.withValues(alpha: 0.4))),
          ]),
        ),

        // Headline
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: '$displayCategory ',
                  style: _T.serif(
                    isMobile ? 42 : 64,
                    w: FontWeight.w700,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: 'News',
                  style: _T.serif(
                    isMobile ? 42 : 64,
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
              _getDescription(displayCategory),
              style: _T.body(13, color: Colors.white.withValues(alpha: 0.5), height: 1.6),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Category pills
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: categories.map((cat) => _CategoryPill(
                label: cat,
                isActive: activeCategory == null ? cat == 'All' : activeCategory == cat,
                onTap: () => onCategorySelect(cat == 'All' ? null : cat),
              )).toList(),
            ),
          ),
        ),
      ]),
    );
  }

  String _getDescription(String category) {
    const descriptions = {
      'All': 'Latest news, insights, and analysis across all categories.',
      'Technology': 'Latest tech innovations and digital transformation.',
      'AI': 'Artificial intelligence breakthroughs and applications.',
      'Business': 'Business strategies and entrepreneurial insights.',
      'Finance': 'Financial markets, investing, and economic trends.',
      'Insurance': 'Insurance industry updates and insights.',
      'Startups': 'Startup funding, growth, and success stories.',
    };
    return descriptions[category] ?? 'Explore the latest articles.';
  }

  String _formatEditionDate() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[now.weekday - 1]} · ${months[now.month]} ${now.day}, ${now.year}';
  }
}

class _CategoryPill extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_CategoryPill> createState() => _CategoryPillState();
}

class _CategoryPillState extends State<_CategoryPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 0),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isActive ? _T.red : (
                  _hovered ? _T.gold : Colors.transparent
                ),
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: _T.syne(
              9,
              w: widget.isActive ? FontWeight.w700 : FontWeight.w500,
              color: widget.isActive 
                  ? Colors.white 
                  : Colors.white.withValues(alpha: _hovered ? 0.8 : 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CARD COMPONENTS
// ─────────────────────────────────────────────────────────────

// Mobile Feature Card
class _MobileFeatureCard extends StatefulWidget {
  final BlogSummary post;
  const _MobileFeatureCard({required this.post});

  @override
  State<_MobileFeatureCard> createState() => _MobileFeatureCardState();
}

class _MobileFeatureCardState extends State<_MobileFeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return GestureDetector(
      onTap: () => context.go('/news/${p.slug}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (p.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: p.image!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (_, _) =>
                    Container(height: 200, color: _T.cream),
                errorWidget: (_, _, _) =>
                    Container(height: 200, color: _T.cream),
              ),
            )
          else
            Container(height: 200, width: double.infinity, color: _T.cream),

          const SizedBox(height: 16),

          // Category
          _CategoryBadge(label: p.category ?? 'Featured'),
          const SizedBox(height: 12),

          // Title
          Text(
            p.title,
            style: _T.serif(20, w: FontWeight.w700, height: 1.3),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),
          Text(
            p.summary,
            style: _T.body(13, color: _T.muted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),
          _ArticleMeta(date: p.date),
        ],
      ),
    );
  }
}

// Tablet Feature Card
class _TabletFeatureCard extends StatelessWidget {
  final BlogSummary post;
  const _TabletFeatureCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final p = post;
    return GestureDetector(
      onTap: () => context.go('/news/${p.slug}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (p.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: p.image!,
                width: 200,
                height: 160,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(width: 200, height: 160, color: _T.cream),
                errorWidget: (_, _, _) =>
                    Container(width: 200, height: 160, color: _T.cream),
              ),
            )
          else
            Container(width: 200, height: 160, color: _T.cream),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryBadge(label: p.category ?? 'Featured'),
                const SizedBox(height: 10),
                Text(
                  p.title,
                  style: _T.serif(22, w: FontWeight.w700, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  p.summary,
                  style: _T.body(13, color: _T.muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                _ArticleMeta(date: p.date),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Desktop Feature Card
class _DesktopFeatureCard extends StatefulWidget {
  final BlogSummary post;
  const _DesktopFeatureCard({required this.post});

  @override
  State<_DesktopFeatureCard> createState() => _DesktopFeatureCardState();
}

class _DesktopFeatureCardState extends State<_DesktopFeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go('/news/${p.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (p.image != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: _hover
                    ? (Matrix4.identity()..scale(1.04))
                    : Matrix4.identity(),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                child: CachedNetworkImage(
                  imageUrl: p.image!,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 300),
                  placeholder: (_, _) =>
                      Container(height: 280, color: _T.cream),
                  errorWidget: (_, _, _) =>
                      Container(height: 280, color: _T.cream),
                ),
              )
            else
              Container(height: 280, width: double.infinity, color: _T.cream),

            const SizedBox(height: 22),

            // Category
            _CategoryBadge(label: p.category ?? 'Featured'),
            const SizedBox(height: 14),

            // Title
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: _T.serif(
                28,
                color: _hover ? _T.red : _T.ink,
                height: 1.3,
              ),
              child: Text(
                p.title,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 12),
            Text(
              p.summary,
              style: _T.body(14, color: _T.muted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 18),
            _ArticleMeta(date: p.date),

            const SizedBox(height: 18),
            _ReadMoreButton(),
          ],
        ),
      ),
    );
  }
}

// Sidebar Card (Desktop right column)
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
        onTap: () => context.go('/news/${p.slug}'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number
              SizedBox(
                width: 36,
                child: Text(
                  '${widget.index}',
                  style: _T.serif(
                    36,
                    w: FontWeight.w300,
                    italic: true,
                    color: _T.border,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: _T.serif(
                        16,
                        color: _hover ? _T.red : _T.ink,
                        height: 1.3,
                      ),
                      child: Text(
                        p.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      _CategoryBadge(label: p.category ?? 'Article'),
                      const SizedBox(width: 10),
                      Text(
                        formatDate(p.date),
                        style: _T.syne(8.5, color: _T.muted),
                      ),
                    ]),
                  ],
                ),
              ),
              if (p.image != null) ...[
                const SizedBox(width: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: CachedNetworkImage(
                    imageUrl: p.image!,
                    width: 80,
                    height: 64,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(width: 80, height: 64, color: _T.cream),
                    errorWidget: (_, _, _) =>
                        Container(width: 80, height: 64, color: _T.cream),
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

// Mobile Article Card
class _MobileArticleCard extends StatefulWidget {
  final BlogSummary post;
  const _MobileArticleCard({required this.post});

  @override
  State<_MobileArticleCard> createState() => _MobileArticleCardState();
}

class _MobileArticleCardState extends State<_MobileArticleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return GestureDetector(
      // onTap: () => context.go('/news/${p.slug}'),
onTap: () => context.push('/news/${p.slug}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _T.divider, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryBadge(label: p.category ?? 'Article'),
                  const SizedBox(height: 8),
                  Text(
                    p.title,
                    style: _T.serif(16, w: FontWeight.w600, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _ArticleMeta(date: p.date),
                ],
              ),
            ),
            if (p.image != null) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: CachedNetworkImage(
                  imageUrl: p.image!,
                  width: 80,
                  height: 64,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(width: 80, height: 64, color: _T.cream),
                  errorWidget: (_, _, _) =>
                      Container(width: 80, height: 64, color: _T.cream),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Grid Article Card
class _GridArticleCard extends StatefulWidget {
  final BlogSummary post;
  const _GridArticleCard({required this.post});

  @override
  State<_GridArticleCard> createState() => _GridArticleCardState();
}

class _GridArticleCardState extends State<_GridArticleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go('/news/${p.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hover ? _T.cream : _T.paper,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hover ? _T.border : _T.divider,
              width: 0.5,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: CachedNetworkImage(
                    imageUrl: p.image!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(height: 120, color: _T.cream),
                    errorWidget: (_, _, _) =>
                        Container(height: 120, color: _T.cream),
                  ),
                )
              else
                Container(height: 120, width: double.infinity, color: _T.cream),

              const SizedBox(height: 12),
              _CategoryBadge(label: p.category ?? 'Article'),
              const SizedBox(height: 10),

              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: _T.serif(
                    15,
                    color: _hover ? _T.red : _T.ink,
                    height: 1.3,
                  ),
                  child: Text(
                    p.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDate(p.date),
                    style: _T.syne(8, color: _T.muted),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _hover ? _T.red : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '→',
                      style: _T.syne(12,
                          color: _hover ? Colors.white : _T.muted),
                    ),
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
      _results = widget.allPosts
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.summary.toLowerCase().contains(q))
          .toList();
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
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 520),
        child: Column(children: [
          // Search input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: _T.divider, width: 0.5),
              ),
            ),
            child: Row(children: [
              Icon(Icons.search_rounded, size: 18, color: _T.muted),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  autofocus: true,
                  onChanged: _filter,
                  style: _T.body(15),
                  decoration: InputDecoration(
                    hintText: 'Search articles…',
                    hintStyle: _T.body(15, color: _T.border),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: _T.border, width: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'ESC',
                    style: _T.syne(8, w: FontWeight.w600, color: _T.muted),
                  ),
                ),
              ),
            ]),
          ),

          // Results
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Text('No results found',
                        style: _T.body(14, color: _T.muted)))
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: _T.divider, height: 1, thickness: 0.5),
                    itemBuilder: (_, i) {
                      final p = _results[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        title: Text(
                          p.title,
                          style: _T.serif(15, w: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          p.summary,
                          style: _T.body(12, color: _T.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text('→', style: _T.body(14, color: _T.muted)),
                        onTap: () {
                          Navigator.pop(context);
                          // context.go('/news/${p.slug}');
   context.push('/news/${p.slug}');
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
//  SHARED COMPONENTS
// ─────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _T.redLight,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _T.red,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: _T.syne(7.5, w: FontWeight.w700, color: _T.red),
        ),
      ]),
    );
  }
}

class _ArticleMeta extends StatelessWidget {
  final DateTime date;
  const _ArticleMeta({required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(formatDate(date), style: _T.syne(8.5, color: _T.muted)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _T.border,
          ),
        ),
      ),
      Text('5 min read', style: _T.body(11, color: _T.muted)),
    ]);
  }
}

class _ReadMoreButton extends StatefulWidget {
  const _ReadMoreButton();

  @override
  State<_ReadMoreButton> createState() => _ReadMoreButtonState();
}

class _ReadMoreButtonState extends State<_ReadMoreButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          'READ MORE',
          style: _T.syne(9, w: FontWeight.w700, color: _T.red),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(left: _hover ? 12 : 6),
          child: Text('→', style: _T.body(13, color: _T.red)),
        ),
      ]),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: _T.syne(9, w: FontWeight.w700)),
      const SizedBox(width: 16),
      Expanded(
        child: Container(height: 0.5, color: _T.border),
      ),
    ]);
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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: _hover ? _T.redHover : _T.red,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: _T.syne(9, w: FontWeight.w700, color: Colors.white),
          ),
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
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month]} ${date.day}';
}

// import 'dart:async';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/blog_summary.dart';
// import '../services/blog_service.dart';

// // ─────────────────────────────────────────────────────────────
// //  DESIGN TOKENS — Editorial Dark Luxury
// // ─────────────────────────────────────────────────────────────
// class _T {
//   // Core palette
//   static const paper = Color(0xFFF5F2EC);
//   static const cream = Color(0xFFEDE9E0);
//   static const ink = Color(0xFF0B0A09);
//   static const red = Color(0xFFBE3A1A);
//   static const redDim = Color(0xFF8C2B12);
//   static const redPale = Color(0xFFF7EAE5);
//   static const gold = Color(0xFFC9A84C);
//   static const muted = Color(0xFF7A7570);
//   static const border = Color(0xFFD8D3CA);
//   static const dark = Color(0xFF131210);
//   static const darkSurface = Color(0xFF1A1814);

//   // ── Typography ──────────────────────────────────────────────

//   /// Cormorant Garamond – serif display
//   static TextStyle serif(double size,
//       {FontWeight w = FontWeight.w600,
//       bool italic = false,
//       Color? color,
//       double? height,
//       double? letterSpacing}) =>
//       GoogleFonts.cormorantGaramond(
//         fontSize: size,
//         fontWeight: w,
//         fontStyle: italic ? FontStyle.italic : FontStyle.normal,
//         color: color ?? ink,
//         height: height ?? 1.15,
//         letterSpacing: letterSpacing ?? -0.01 * size,
//       );

//   /// Syne – geometric sans for labels / UI chrome
//   static TextStyle syne(double size,
//       {FontWeight w = FontWeight.w500,
//       Color? color,
//       double? letterSpacing}) =>
//       GoogleFonts.syne(
//         fontSize: size,
//         fontWeight: w,
//         color: color ?? ink,
//         letterSpacing: letterSpacing ?? size * 0.18,
//       );

//   /// DM Sans – readable body
//   static TextStyle body(double size,
//       {FontWeight w = FontWeight.w300, Color? color, double? height}) =>
//       GoogleFonts.dmSans(
//         fontSize: size,
//         fontWeight: w,
//         color: color ?? ink,
//         height: height ?? 1.75,
//       );
// }

// // ─────────────────────────────────────────────────────────────
// //  PAGE
// // ─────────────────────────────────────────────────────────────
// class NewListPage extends StatefulWidget {
//   const NewListPage({Key? key}) : super(key: key);

//   @override
//   State<NewListPage> createState() => _NewListPageState();
// }

// class _NewListPageState extends State<NewListPage> {
//   // List<BlogSummary> _all = [];
  
//   List<BlogSummary> _filtered = [];
//   String _query = '';
//   String? _activeCategory;
//   bool _loading = true;
//   String? _error;
// List<BlogSummary> _blogs = [];

// String _selectedCategory = "All";

// int _page = 1;
// bool _hasMore = true;

// // bool _loading = false;
// // String? _error;
//   // final _scroll = ScrollController();
//   final _search = TextEditingController();
//   final _service = BlogService();

//   static const _categories =
//   [
//    "Technology",
//     "Ai",
//     "Business",
//     "Finance",
//     "Insurance",
//     "Startups",
//     "Politics",
//     "International",
//     "Health",
//     "Education",
//     "Entertainment",
//     "Consumer"
//   ];
//   //  [
//   //   'All',
//   //   'CRM',
//   //   'Insurance',
//   //   'Finance',
//   //   'Technology',
//   //   'AI',
//   //   'Business',
//   //   'Marketing',
//   //   'Product',
//   //   'Startups',
//   // ];

//   @override
//   void initState() {
//     super.initState();
//     _fetch();
//   }

//   @override
//   void dispose() {
//     // _scroll.dispose();
//     _search.dispose();
//     super.dispose();
//   }


// Future<void> _fetch() async {
//   setState(() {
//     _loading = true;
//     _error = null;
//     _page = 1;
//     _blogs.clear();
//     _hasMore = true;
//   });

//   try {
//     final response = await _service.fetchPage(_page);

//     setState(() {
//       _blogs = response.data;
//       _hasMore = response.page < response.totalPages;
//       _page++;
//       _loading = false;
//     });

//     _applyFilter(); // ✅ IMPORTANT FIX
//   } catch (e) {
//     setState(() {
//       _error = 'Failed to load posts';
//       _loading = false;
//     });
//   }
// }
// void _applyFilter() {
//   var list = _blogs;
// print("Kishore Kumar 6");
 
//   // if (_activeCategory != null && _activeCategory != 'All') {
//   //   list = list.where((p) =>
//   //     p.category != null &&
//   //     p.category!.toLowerCase() == _activeCategory!.toLowerCase()
//   //   ).toList();
//   // }

//   if (_query.isNotEmpty) {
//     list = list.where((p) =>
//       p.title.toLowerCase().contains(_query.toLowerCase()) ||
//       p.summary.toLowerCase().contains(_query.toLowerCase())
//     ).toList();
//   }

//   // ✅ FIXED LOG
//   debugPrint("Category: $_activeCategory | Count: ${list.length}");

//   setState(() => _filtered = list);
// print("Kishore Kumar 7 ${_filtered.length}");

// }

//   void _updateCategory(String? category) async {
//   setState(() {
//     _activeCategory = category;
//     _loading = true;
//     _error = null;
//     _page = 1;
//     _blogs.clear();
//   });
// print("Kishore Kumar 1");
//   try {
//     BlogResponse response;
// print("Kishore Kumar 2");

//     if (category == null || category == 'All') {
// print("Kishore Kumar 3");

//       // ✅ LOAD ALL BLOGS
//       response = await _service.fetchPage(1);
//     } else {
// print("Kishore Kumar 4");

//       // ✅ LOAD CATEGORY BLOGS
//       response = await _service.fetchByCategory(category.toLowerCase(), page: 1);
// print("Kishore Kumar 5 $response");
//     }

//     setState(() {
//       _blogs = response.data;
//       _hasMore = response.page < response.totalPages;
//       _page = 2;
//       _loading = false;
//     });

//     _applyFilter(); // optional (for search)
//   } catch (e) {
//     setState(() {
//       _error = 'Failed to load category';
//       _loading = false;
//     });
//   }
// }
//   // Add pagination for loading more
//   Future<void> _loadMore() async {
//     if (!_hasMore || _loading) return;

//     setState(() {
//       _loading = true;
//     });

//     try {
//       BlogResponse response;
      
//       if (_activeCategory != null && _activeCategory != 'All') {
//         response = await _service.fetchByCategory(_activeCategory!, page: _page);
//       } else {
//         response = await _service.fetchPage(_page);
//       }

//       setState(() {
//         _blogs.addAll(response.data);
//         _hasMore = response.page < response.totalPages;
//         _page++;
//         _loading = false;
//       });
      
//       _applyFilter();
      
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to load more posts';
//         _loading = false;
//       });
//     }
//   }

//   void _updateSearch(String query) {
//     setState(() {
//       _query = query;
//       _applyFilter();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _T.paper,
//       body: NestedScrollView(
//         // controller: _scroll,
//         headerSliverBuilder: (_, _) => [
//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 _MastheadBar(
//                   onSearch: _updateSearch,
//                   searchController: _search,
//                   allPosts: _blogs,
//                   // allPosts: _all,
//                 ),
//                 _HeroSection(
//                   categories: _categories,
//                   activeCategory: _activeCategory,
//                   onCategorySelect: _updateCategory,
//                   filteredCount: _filtered.length,
//                 ),
//               ],
//             ),
//           ),
//         ],
//         body: _loading
//             ? _buildLoading()
//             : _error != null
//                 ? _buildError()
//                 : _filtered.isEmpty
//                     ? _buildEmpty()
//                     : _buildList(),
//       ),
//     );
//   }

//   Widget _buildList() {
//     return LayoutBuilder(
//       builder: (context, bc) {
//         if (bc.maxWidth > 900) return _DesktopLayout(posts: _filtered);
//         return RefreshIndicator(
//           color: _T.red,
//           onRefresh: _fetch,
//           child: ListView.builder(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
//             itemCount: _filtered.length,
//             itemBuilder: (_, i) {
//               if (i == 0) return _FeatureCard(post: _filtered[0]);
//               return Column(children: [
//                 Divider(color: _T.border, height: 1, thickness: 0.5),
//                 _ListCard(post: _filtered[i]),
//               ]);
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLoading() => Center(
//     child: Column(mainAxisSize: MainAxisSize.min, children: [
//       SizedBox(
//         width: 28, height: 28,
//         child: CircularProgressIndicator(
//           color: _T.red, strokeWidth: 1.5,
//         ),
//       ),
//       const SizedBox(height: 20),
//       Text('Loading articles', style: _T.syne(10, color: _T.muted)),
//     ]),
//   );

//   Widget _buildError() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(40),
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         Container(
//           width: 48, height: 48,
//           color: _T.redPale,
//           child: Icon(Icons.wifi_off_rounded, color: _T.red, size: 22),
//         ),
//         const SizedBox(height: 24),
//         Text('Connection failed', style: _T.serif(22)),
//         const SizedBox(height: 8),
//         Text('Check your connection and try again.',
//             style: _T.body(13, color: _T.muted)),
//         const SizedBox(height: 28),
//         _PillButton(label: 'Try Again', onTap: _fetch),
//       ]),
//     ),
//   );

//   Widget _buildEmpty() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(40),
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         Text('No results', style: _T.serif(28)),
//         const SizedBox(height: 8),
//         Text('Try a different search term or category.',
//             style: _T.body(13, color: _T.muted)),
//         const SizedBox(height: 24),
//         _PillButton(
//           label: 'Reset filters',
//           onTap: () {
//             _search.clear();
//             setState(() {
//               _query = '';
//               _activeCategory = null;
//               _applyFilter();
//             });
//           },
//         ),
//       ]),
//     ),
//   );
// }

// // ─────────────────────────────────────────────────────────────
// //  MASTHEAD BAR
// // ─────────────────────────────────────────────────────────────
// class _MastheadBar extends StatelessWidget {
//   final ValueChanged<String> onSearch;
//   final TextEditingController searchController;
//   final List<BlogSummary> allPosts;

//   const _MastheadBar({
//     required this.onSearch,
//     required this.searchController,
//     required this.allPosts,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: _T.ink,
//       height: 56,
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Row(children: [
//         // Brand
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('REVOCHAMP',
//                 style: _T.syne(7.5, w: FontWeight.w700, color: _T.gold)),
//             const SizedBox(height: 1),
//             Text('NEWSJournal',
//                 style: _T.serif(20, w: FontWeight.w600, color: Colors.white)),
//           ],
//         ),

//         // Divider
//         Container(
//           width: 1, height: 28,
//           margin: const EdgeInsets.symmetric(horizontal: 20),
//           color: const Color(0xFF2A2A28),
//         ),

//         // Nav (desktop)
//         if (MediaQuery.of(context).size.width > 700) ...[
//           ..._navItems(context),
//           const Spacer(),
//         ] else
//           const Spacer(),

//         // Search pill
//         GestureDetector(
//           onTap: () => showDialog(
//             context: context,
//             builder: (_) => _SearchDialog(
//               controller: searchController,
//               onSearch: onSearch,
//               allPosts: allPosts,
//             ),
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//             decoration: BoxDecoration(
//               color: const Color(0xFF1A1A18),
//               border: Border.all(color: const Color(0xFF2A2A28), width: 0.5),
//             ),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               Icon(Icons.search_rounded,
//                   size: 14, color: Colors.white.withValues(alpha: 0.45)),
//               const SizedBox(width: 8),
//               Text('Search',
//                   style: _T.body(11, color: Colors.white.withValues(alpha: 0.4))),
//             ]),
//           ),
//         ),

//         const SizedBox(width: 6),
//         _IconBtn(icon: Icons.bookmark_border_rounded),
//         _IconBtn(icon: Icons.rss_feed_rounded),
//       ]),
//     );
//   }

//   List<Widget> _navItems(BuildContext context) {
//     const items = ['All', 'CRM', 'Technology', 'AI', 'Business'];
//     return items.map((item) => Padding(
//       padding: const EdgeInsets.only(right: 20),
//       child: Text(
//         item.toUpperCase(),
//         style: _T.syne(8.5,
//             w: item == 'All' ? FontWeight.w700 : FontWeight.w500,
//             color: item == 'All' ? Colors.white : Colors.white38),
//       ),
//     )).toList();
//   }
// }

// class _IconBtn extends StatelessWidget {
//   final IconData icon;
//   const _IconBtn({required this.icon});

//   @override
//   Widget build(BuildContext context) => IconButton(
//     icon: Icon(icon, size: 18, color: Colors.white38),
//     onPressed: () {},
//     splashRadius: 18,
//   );
// }

// // ─────────────────────────────────────────────────────────────
// //  HERO SECTION
// // ─────────────────────────────────────────────────────────────
// class _HeroSection extends StatelessWidget {
//   final List<String> categories;
//   final String? activeCategory;
//   final ValueChanged<String?> onCategorySelect;
//   final int filteredCount;

//   const _HeroSection({
//     required this.categories,
//     required this.activeCategory,
//     required this.onCategorySelect,
//     required this.filteredCount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final isMobile = w < 700;
//     final displayCategory = activeCategory ?? 'All';

//     return Container(
//       width: double.infinity,
//       color: _T.ink,
//       child: Column(children: [
//         // Edition bar
//         Padding(
//           padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
//           child: Row(children: [
//             Text(
//               _formatEditionDate(),
//               style: _T.syne(8, color: const Color(0xFF444440)),
//             ),
//             Expanded(child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               height: 0.5,
//               color: const Color(0xFF222220),
//             )),
//             Text('$filteredCount articles',
//                 style: _T.syne(8, color: const Color(0xFF444440))),
//           ]),
//         ),

//         // Headline
//         Padding(
//           padding: EdgeInsets.fromLTRB(
//             isMobile ? 24 : 24, 20,
//             isMobile ? 24 : 24, 0,
//           ),
//           child: Align(
//             alignment: Alignment.centerLeft,
//             child: RichText(
//               text: TextSpan(children: [
//                 TextSpan(
//                   text: '$displayCategory ',
//                   style: _T.serif(
//                     isMobile ? 44 : 62,
//                     w: FontWeight.w700,
//                     color: Colors.white,
//                     height: 1.0,
//                   ),
//                 ),
//                 TextSpan(
//                   text: 'Articles',
//                   style: _T.serif(
//                     isMobile ? 44 : 62,
//                     w: FontWeight.w300,
//                     italic: true,
//                     color: _T.gold,
//                     height: 1.0,
//                   ),
//                 ),
//               ]),
//             ),
//           ),
//         ),

//         Padding(
//           padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
//           child: Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               _getHeadlineDescription(displayCategory),
//               style: _T.body(13, color: Colors.white.withValues(alpha: 0.4), height: 1.6),
//             ),
//           ),
//         ),

//         const SizedBox(height: 24),

//         // Category filter
//         Container(
//           decoration: const BoxDecoration(
//             border: Border(top: BorderSide(color: Color(0xFF1C1C1A), width: 0.5)),
//           ),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Row(
//               children: categories.map((cat) => _CategoryChip(
//                 label: cat,
//                 isActive: activeCategory == null
//                     ? cat == 'All'
//                     : activeCategory == cat,
//                 onTap: () => onCategorySelect(cat == 'All' ? null : cat),
//               )).toList(),
//             ),
//           ),
//         ),
//       ]),
//     );
//   }

//   String _getHeadlineDescription(String category) {
//     final descriptions = {
//       'All': 'Insights, ideas and practical guides across technology, strategy, and modern design.',
//       'CRM': 'Explore customer relationship management strategies and best practices.',
//       'Insurance': 'Insights into insurance industry trends, products, and innovations.',
//       'Finance': 'Financial guidance, investment strategies, and market analysis.',
//       'Technology': 'Latest tech trends, tools, and digital transformation insights.',
//       'AI': 'Artificial intelligence advancements, applications, and implications.',
//       'Business': 'Business strategies, entrepreneurship, and organizational growth.',
//       'Marketing': 'Marketing campaigns, digital strategies, and brand insights.',
//       'Product': 'Product development, management, and launch strategies.',
//       'Startups': 'Startup tips, funding guides, and entrepreneurial journeys.',
//     };
//     return descriptions[category] ?? 'Browse articles in this category.';
//   }

//   String _formatEditionDate() {
//     final now = DateTime.now();
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return '${days[now.weekday - 1]} · ${months[now.month]} ${now.day}, ${now.year}';
//   }
// }

// class _CategoryChip extends StatelessWidget {
//   final String label;
//   final bool isActive;
//   final VoidCallback onTap;

//   const _CategoryChip({
//     required this.label,
//     required this.isActive,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(right: 0),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: isActive ? _T.red : Colors.transparent,
//               width: 2,
//             ),
//           ),
//         ),
//         child: Text(
//           label.toUpperCase(),
//           style: _T.syne(
//             8.5,
//             w: isActive ? FontWeight.w700 : FontWeight.w400,
//             color: isActive ? Colors.white : const Color(0xFF555550),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  DESKTOP LAYOUT
// // ─────────────────────────────────────────────────────────────
// class _DesktopLayout extends StatelessWidget {
//   final List<BlogSummary> posts;
//   const _DesktopLayout({required this.posts});

//   @override
//   Widget build(BuildContext context) {
//     final feature = posts.first;
//     final sidebar = posts.skip(1).take(3).toList();
//     final grid = posts.skip(4).toList();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
//       child: Column(children: [
//         // Feature row
//         IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Expanded(
//                 flex: 58,
//                 child: Container(
//                   padding: const EdgeInsets.fromLTRB(0, 36, 32, 36),
//                   decoration: const BoxDecoration(
//                     border: Border(
//                       right: BorderSide(color: _T.border, width: 0.5),
//                     ),
//                   ),
//                   child: _FeatureCard(post: feature),
//                 ),
//               ),
//               Expanded(
//                 flex: 42,
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(32, 36, 0, 36),
//                   child: Column(
//                     children: sidebar.asMap().entries.map((e) {
//                       final isLast = e.key == sidebar.length - 1;
//                       return Column(children: [
//                         _SidebarCard(post: e.value, index: e.key + 2),
//                         if (!isLast)
//                           const Divider(
//                               color: _T.border, height: 1, thickness: 0.5),
//                       ]);
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Section header
//         const Divider(color: _T.border, height: 1, thickness: 0.5),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 28),
//           child: Row(children: [
//             Text('MORE ARTICLES',
//                 style: _T.syne(8.5, w: FontWeight.w700)),
//             const SizedBox(width: 16),
//             Expanded(child: Container(height: 0.5, color: _T.border)),
//             const SizedBox(width: 16),
//             Text('${grid.length} articles',
//                 style: _T.syne(8, color: _T.muted)),
//           ]),
//         ),

//         // Grid
//         if (grid.isNotEmpty)
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 1,
//               mainAxisSpacing: 1,
//               childAspectRatio: 1.45,
//             ),
//             itemCount: grid.length,
//             itemBuilder: (_, i) => _GridCard(post: grid[i]),
//           ),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  FEATURE CARD
// // ─────────────────────────────────────────────────────────────
// class _FeatureCard extends StatefulWidget {
//   final BlogSummary post;
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
//         onTap: () => context.go('/${p.slug}'),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image
//             if (p.image != null)
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 transform: _hover
//                     ? (Matrix4.identity()..scale(1.008))
//                     : Matrix4.identity(),
//                 clipBehavior: Clip.antiAlias,
//                 decoration: const BoxDecoration(),
//                 child: CachedNetworkImage(
//                   imageUrl: p.image!,
//                   height: 240,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   fadeInDuration: const Duration(milliseconds: 350),
//                   placeholder: (_, _) =>
//                       Container(height: 240, color: _T.cream),
//                   errorWidget: (_, _, _) =>
//                       Container(height: 240, color: _T.cream),
//                 ),
//               )
//             else
//               Container(
//                 height: 240,
//                 width: double.infinity,
//                 color: _T.dark,
//               ),

//             const SizedBox(height: 20),

//             // Tag
//             _TagPill(label: p.category ?? 'Featured'),
//             const SizedBox(height: 12),

//             // Title
//             AnimatedDefaultTextStyle(
//               duration: const Duration(milliseconds: 200),
//               style: _T.serif(
//                 26,
//                 color: _hover ? _T.red : _T.ink,
//                 height: 1.2,
//               ),
//               child: Text(p.title, maxLines: 3,
//                   overflow: TextOverflow.ellipsis),
//             ),

//             const SizedBox(height: 10),
//             Text(p.summary,
//                 style: _T.body(13, color: _T.muted),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis),

//             const SizedBox(height: 16),
//             _MetaRow(date: p.date),

//             const SizedBox(height: 16),
//             _ReadMore(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  SIDEBAR CARD (desktop right column)
// // ─────────────────────────────────────────────────────────────
// class _SidebarCard extends StatefulWidget {
//   final BlogSummary post;
//   final int index;
//   const _SidebarCard({required this.post, required this.index});
//   @override
//   State<_SidebarCard> createState() => _SidebarCardState();
// }

// class _SidebarCardState extends State<_SidebarCard> {
//   bool _hover = false;

//   @override
//   Widget build(BuildContext context) {
//     final p = widget.post;
//     return MouseRegion(
//       onEnter: (_) => setState(() => _hover = true),
//       onExit: (_) => setState(() => _hover = false),
//       child: GestureDetector(
//         onTap: () => context.go('/${p.slug}'),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 22),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Italic number
//               SizedBox(
//                 width: 30,
//                 child: Text(
//                   '${widget.index}',
//                   style: _T.serif(30,
//                       w: FontWeight.w300,
//                       italic: true,
//                       color: _T.border,
//                       height: 1.0,
//                       letterSpacing: 0),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AnimatedDefaultTextStyle(
//                       duration: const Duration(milliseconds: 180),
//                       style: _T.serif(15,
//                           color: _hover ? _T.red : _T.ink,
//                           height: 1.3,
//                           letterSpacing: 0),
//                       child: Text(p.title,
//                           maxLines: 3, overflow: TextOverflow.ellipsis),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 6, vertical: 2),
//                         color: _T.redPale,
//                         child: Text((p.category ?? 'ARTICLE').toUpperCase(),
//                             style: _T.syne(7.5,
//                                 w: FontWeight.w600, color: _T.red)),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(formatDate(p.date),
//                           style: _T.syne(8, color: _T.border)),
//                     ]),
//                   ],
//                 ),
//               ),
//               if (p.image != null) ...[
//                 const SizedBox(width: 14),
//                 ClipRect(
//                   child: CachedNetworkImage(
//                     imageUrl: p.image!,
//                     width: 72,
//                     height: 60,
//                     fit: BoxFit.cover,
//                     placeholder: (_, _) =>
//                         Container(width: 72, height: 60, color: _T.cream),
//                     errorWidget: (_, _, _) =>
//                         Container(width: 72, height: 60, color: _T.cream),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  LIST CARD (mobile)
// // ─────────────────────────────────────────────────────────────
// class _ListCard extends StatefulWidget {
//   final BlogSummary post;
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
//         onTap: () => context.go('/${p.slug}'),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           color: _hover ? _T.cream : Colors.transparent,
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _TagPill(label: p.category ?? 'Article'),
//                     const SizedBox(height: 8),
//                     AnimatedDefaultTextStyle(
//                       duration: const Duration(milliseconds: 180),
//                       style: _T.serif(16,
//                           color: _hover ? _T.red : _T.ink,
//                           height: 1.25,
//                           letterSpacing: 0),
//                       child: Text(p.title,
//                           maxLines: 3, overflow: TextOverflow.ellipsis),
//                     ),
//                     const SizedBox(height: 8),
//                     _MetaRow(date: p.date),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 16),
//               if (p.image != null)
//                 ClipRect(
//                   child: CachedNetworkImage(
//                     imageUrl: p.image!,
//                     width: 86,
//                     height: 70,
//                     fit: BoxFit.cover,
//                     placeholder: (_, _) =>
//                         Container(width: 86, height: 70, color: _T.cream),
//                     errorWidget: (_, _, _) =>
//                         Container(width: 86, height: 70, color: _T.cream),
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
// //  GRID CARD
// // ─────────────────────────────────────────────────────────────
// class _GridCard extends StatefulWidget {
//   final BlogSummary post;
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
//         onTap: () => context.go('/${p.slug}'),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           color: _hover ? _T.cream : _T.paper,
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (p.image != null)
//                 CachedNetworkImage(
//                   imageUrl: p.image!,
//                   height: 120,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   placeholder: (_, _) =>
//                       Container(height: 120, color: _T.cream),
//                   errorWidget: (_, _, _) =>
//                       Container(height: 120, color: _T.cream),
//                 )
//               else
//                 Container(height: 120, width: double.infinity, color: _T.cream),

//               const SizedBox(height: 14),
//               _TagPill(label: p.category ?? 'Article'),
//               const SizedBox(height: 10),

//               Expanded(
//                 child: AnimatedDefaultTextStyle(
//                   duration: const Duration(milliseconds: 180),
//                   style: _T.serif(15,
//                       color: _hover ? _T.red : _T.ink,
//                       height: 1.3,
//                       letterSpacing: 0),
//                   child: Text(p.title,
//                       maxLines: 3, overflow: TextOverflow.ellipsis),
//                 ),
//               ),

//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(formatDate(p.date),
//                       style: _T.syne(8, color: _T.border)),
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 180),
//                     width: 24,
//                     height: 24,
//                     color: _hover ? _T.red : Colors.transparent,
//                     alignment: Alignment.center,
//                     child: Text('→',
//                         style: _T.body(10,
//                             color: _hover ? Colors.white : _T.muted)),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  SEARCH DIALOG
// // ─────────────────────────────────────────────────────────────
// class _SearchDialog extends StatefulWidget {
//   final TextEditingController controller;
//   final ValueChanged<String> onSearch;
//   final List<BlogSummary> allPosts;

//   const _SearchDialog({
//     required this.controller,
//     required this.onSearch,
//     required this.allPosts,
//   });

//   @override
//   State<_SearchDialog> createState() => _SearchDialogState();
// }

// class _SearchDialogState extends State<_SearchDialog> {
//   List<BlogSummary> _results = [];

//   @override
//   void initState() {
//     super.initState();
//     _results = widget.allPosts;
//   }

//   void _filter(String query) {
//     final q = query.toLowerCase();
//     setState(() {
//       _results = widget.allPosts.where((p) =>
//         p.title.toLowerCase().contains(q) ||
//         p.summary.toLowerCase().contains(q),
//       ).toList();
//     });
//     widget.onSearch(query);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
//       backgroundColor: _T.paper,
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 580, maxHeight: 480),
//         child: Column(children: [
//           // Search input
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//             decoration: const BoxDecoration(
//               border: Border(bottom: BorderSide(color: _T.border, width: 0.5)),
//             ),
//             child: Row(children: [
//               Icon(Icons.search_rounded, size: 16, color: _T.muted),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: TextField(
//                   controller: widget.controller,
//                   autofocus: true,
//                   onChanged: _filter,
//                   style: _T.body(14),
//                   decoration: InputDecoration(
//                     hintText: 'Search articles, topics…',
//                     hintStyle: _T.body(14, color: _T.border),
//                     border: InputBorder.none,
//                     isDense: true,
//                     contentPadding: EdgeInsets.zero,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: _T.border, width: 0.5),
//                   ),
//                   child: Text('ESC',
//                       style: _T.syne(8, w: FontWeight.w600, color: _T.muted)),
//                 ),
//               ),
//             ]),
//           ),

//           // Results
//           Expanded(
//             child: _results.isEmpty
//                 ? Center(child: Text('No results found',
//                     style: _T.body(13, color: _T.muted)))
//                 : ListView.separated(
//                     itemCount: _results.length,
//                     separatorBuilder: (_, _) =>
//                         const Divider(color: _T.border, height: 1, thickness: 0.5),
//                     itemBuilder: (_, i) {
//                       final p = _results[i];
//                       return ListTile(
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 6),
//                         title: Text(p.title,
//                             style: _T.serif(15, letterSpacing: 0),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis),
//                         subtitle: Text(p.summary,
//                             style: _T.body(11, color: _T.muted),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis),
//                         trailing: Text('→',
//                             style: _T.body(14, color: _T.border)),
//                         onTap: () {
//                           Navigator.pop(context);
//                           context.go('/${p.slug}');
//                         },
//                       );
//                     },
//                   ),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  SHARED WIDGETS
// // ─────────────────────────────────────────────────────────────
// class _TagPill extends StatelessWidget {
//   final String label;
//   const _TagPill({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       color: _T.red,
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Container(
//           width: 4, height: 4,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.white.withValues(alpha: 0.5),
//           ),
//         ),
//         const SizedBox(width: 5),
//         Text(label.toUpperCase(),
//             style: _T.syne(7.5, w: FontWeight.w700, color: Colors.white)),
//       ]),
//     );
//   }
// }

// class _MetaRow extends StatelessWidget {
//   final DateTime date;
//   const _MetaRow({required this.date});

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Text(formatDate(date), style: _T.syne(8, color: _T.border)),
//       Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: Container(
//             width: 2, height: 2,
//             decoration: BoxDecoration(
//                 shape: BoxShape.circle, color: _T.border)),
//       ),
//       Text('5 min read', style: _T.body(11, color: _T.border)),
//     ]);
//   }
// }

// class _ReadMore extends StatefulWidget {
//   const _ReadMore();
//   @override
//   State<_ReadMore> createState() => _ReadMoreState();
// }

// class _ReadMoreState extends State<_ReadMore> {
//   bool _hover = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _hover = true),
//       onExit: (_) => setState(() => _hover = false),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Text('CONTINUE READING',
//             style: _T.syne(8.5, w: FontWeight.w700, color: _T.red)),
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           margin: EdgeInsets.only(left: _hover ? 12 : 6),
//           child: Text('→', style: _T.body(13, color: _T.red)),
//         ),
//       ]),
//     );
//   }
// }

// class _PillButton extends StatefulWidget {
//   final String label;
//   final VoidCallback onTap;
//   const _PillButton({required this.label, required this.onTap});
//   @override
//   State<_PillButton> createState() => _PillButtonState();
// }

// class _PillButtonState extends State<_PillButton> {
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
//           padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
//           color: _hover ? _T.redDim : _T.red,
//           child: Text(widget.label.toUpperCase(),
//               style: _T.syne(9, w: FontWeight.w700, color: Colors.white)),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  UTILITIES
// // ─────────────────────────────────────────────────────────────
// String formatDate(DateTime date) {
//   const months = [
//     '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
//   ];
//   return '${months[date.month]} ${date.day}, ${date.year}';
// }