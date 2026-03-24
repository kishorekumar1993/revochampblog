// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../services/blog_service.dart';
// import '../models/blog_post.dart';

// class BlogListPage extends StatefulWidget {
//   const BlogListPage({Key? key}) : super(key: key);

//   @override
//   State<BlogListPage> createState() => _BlogListPageState();
// }

// class _BlogListPageState extends State<BlogListPage> {
//   List<BlogPost> _allPosts = [];
//   List<BlogPost> _filteredPosts = [];
//   List<String> _categories = [];
//   String? _selectedCategory;
//   String _searchQuery = '';

//   bool _isLoading = true;
//   String? _error;

//   final ScrollController _scrollController = ScrollController();
//   final BlogService _blogService = BlogService();

//   @override
//   void initState() {
//     super.initState();
//     _fetchPosts();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // ================= FETCH =================

//   Future<void> _fetchPosts() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final posts = await _blogService.fetchAllBlogPosts();

//       _allPosts = posts;
//       _updateCategories();
//       _applyFilter();

//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = "Failed to load posts";
//         _isLoading = false;
//       });
//     }
//   }

//   void _updateCategories() {
//     final set = <String>{};
//     for (final p in _allPosts) {
//       set.addAll(p.categories);
//     }
//     _categories = set.toList()..sort();
//   }

//   void _applyFilter() {
//     List<BlogPost> temp = _allPosts;

//     if (_selectedCategory != null) {
//       temp = temp
//           .where((p) => p.categories.contains(_selectedCategory))
//           .toList();
//     }

//     if (_searchQuery.isNotEmpty) {
//       temp = temp
//           .where((p) =>
//               p.title.toLowerCase().contains(_searchQuery.toLowerCase()))
//           .toList();
//     }

//     _filteredPosts = temp;
//   }

//   // ================= BUILD =================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: RefreshIndicator(
//         onRefresh: _fetchPosts,
//         child: _buildBody(),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_error != null) {
//       return _buildError();
//     }

//     if (_filteredPosts.isEmpty) {
//       return _buildEmpty();
//     }

//     return _buildPostList();
//   }

//   // ================= APPBAR =================
// AppBar _buildAppBar() {
//   return AppBar(
//     automaticallyImplyLeading: false,
//     elevation: 0,
//     backgroundColor: const Color(0xFF0B0F1A),
//     toolbarHeight: 70,
//     titleSpacing: 16,

//     // 🔹 BRAND (Neutral for multi-category blog)
//     title: const Text(
//       "Revochamp Blog",
//       style: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.w700,
//         letterSpacing: 0.3,
//         color: Colors.white,
//       ),
//     ),

//     actions: [
//       IconButton(
//         icon: const Icon(Icons.trending_up_rounded, color: Colors.white70),
//         onPressed: () {}, // trending section
//       ),
//       IconButton(
//         icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white70),
//         onPressed: () {}, // saved blogs
//       ),
//       const SizedBox(width: 8),
//     ],

//     // 🔹 DISCOVERY SECTION
//     bottom: PreferredSize(
//       preferredSize: const Size.fromHeight(120),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         decoration: const BoxDecoration(
//           border: Border(
//             bottom: BorderSide(color: Colors.white10),
//           ),
//         ),
//         child: Column(
//           children: [
//             const SizedBox(height: 10),

//             // 🔍 SEARCH (Primary for combined blog)
//             _buildSearch(),

//             const SizedBox(height: 12),

//             // 🏷 CATEGORY (Horizontal filter)
//             _buildCategoryFilter(),

//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     ),
//   );
// }


// // ================= SEARCH =================

//   Widget _buildSearch() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: TextField(
//         onChanged: (value) {
//           _searchQuery = value;
//           _applyFilter();
//           setState(() {});
//         },
//         decoration: InputDecoration(
//           hintText: "Search blogs...",
//           prefixIcon: const Icon(Icons.search),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(vertical: 0),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }

//   // ================= CATEGORY =================
// Widget _buildCategoryFilter() {
//   final theme = Theme.of(context);

//   return SizedBox(
//     height: 36,
//     child: ListView.separated(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       scrollDirection: Axis.horizontal,
//       itemCount: _categories.length + 1,
//       separatorBuilder: (_, __) => const SizedBox(width: 16),
//       itemBuilder: (context, index) {
//         final isAll = index == 0;
//         final category = isAll ? "All" : _categories[index - 1];

//         final isSelected = isAll
//             ? _selectedCategory == null
//             : _selectedCategory == category;

//         return GestureDetector(
//           onTap: () {
//             _selectedCategory = isAll ? null : category;
//             _applyFilter();
//             setState(() {});
//           },
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // 🔹 TEXT
//               AnimatedDefaultTextStyle(
//                 duration: const Duration(milliseconds: 200),
//                 style: theme.textTheme.bodyMedium!.copyWith(
//                   fontWeight:
//                       isSelected ? FontWeight.w600 : FontWeight.normal,
//                   color: isSelected
//                       ? Colors.white
//                       : Colors.white.withOpacity(0.6),
//                 ),
//                 child: Text(category),
//               ),

//               const SizedBox(height: 4),

//               // 🔹 UNDERLINE INDICATOR
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 height: 2,
//                 width: isSelected ? 20 : 0,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     ),
//   );
// }


//   // ================= LIST / GRID =================

//   Widget _buildPostList() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isDesktop = constraints.maxWidth > 900;

//         if (isDesktop) {
//           return GridView.builder(
//             controller: _scrollController,
//             padding: const EdgeInsets.all(20),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: _getColumns(constraints.maxWidth),
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 1.0,
//             ),
//             itemCount: _filteredPosts.length,
//             itemBuilder: (_, i) => BlogCard(post: _filteredPosts[i]),
//           );
//         }

//         return ListView.builder(
//           controller: _scrollController,
//           padding: const EdgeInsets.all(16),
//           itemCount: _filteredPosts.length,
//           itemBuilder: (_, i) => Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: BlogCard(post: _filteredPosts[i]),
//           ),
//         );
//       },
//     );
//   }

//   int _getColumns(double width) {
//     if (width > 1200) return 4;
//     if (width > 800) return 3;
//     return 2;
//   }

//   // ================= EMPTY =================

//   Widget _buildEmpty() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.search_off, size: 50),
//           SizedBox(height: 10),
//           Text("No results found"),
//         ],
//       ),
//     );
//   }

//   // ================= ERROR =================

//   Widget _buildError() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error, size: 50, color: Colors.red),
//           const SizedBox(height: 10),
//           Text(_error!),
//           const SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: _fetchPosts,
//             child: const Text("Retry"),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ================= BLOG CARD =================

// class BlogCard extends StatefulWidget {
//   final BlogPost post;

//   const BlogCard({Key? key, required this.post}) : super(key: key);

//   @override
//   State<BlogCard> createState() => _BlogCardState();
// }

// class _BlogCardState extends State<BlogCard> {
//   bool isHover = false;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return MouseRegion(
//       onEnter: (_) => setState(() => isHover = true),
//       onExit: (_) => setState(() => isHover = false),
//       child: GestureDetector(
//         onTap: () {
//   //         Navigator.push(
//   //   context,
//   //   MaterialPageRoute(
//   //     builder: (_) => MagazineBlogDetailPage(post: widget.post),
//   //   ),
//   // );
//           Navigator.pushNamed(context, '/blog/${widget.post.slug}');
//           // 👉 Replace with go_router:
//           // context.go('/blog/${widget.post.slug}');
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           transform: isHover
//               ? (Matrix4.identity()..scale(1.02))
//               : Matrix4.identity(),
//           decoration: BoxDecoration(
//             color: theme.cardColor,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(isHover ? 0.15 : 0.08),
//                 blurRadius: isHover ? 20 : 10,
//               )
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (widget.post.featuredImage != null)
//                 ClipRRect(
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(16)),
//                   child: CachedNetworkImage(
//                     imageUrl: widget.post.featuredImage!,
//                     height: 180,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     fadeInDuration: const Duration(milliseconds: 300),
//                   ),
//                 ),

//               Padding(
//                 padding: const EdgeInsets.all(14),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.post.title,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     if (widget.post.subtitle.isNotEmpty)
//                       Text(
//                         widget.post.subtitle,
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: theme.textTheme.bodySmall,
//                       ),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         const Icon(Icons.access_time, size: 14),
//                         const SizedBox(width: 4),
//                         Text(widget.post.readTime),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

