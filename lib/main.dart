import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:revochampblog/core/meta_service.dart';
import 'package:revochampblog/pages/blog_list_page.dart';
import 'package:revochampblog/pages/blog_page.dart';
import 'package:revochampblog/pages/news/news_list_page.dart';
import 'package:revochampblog/pages/news/newsdetail.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Removes the '#' from URLs – enables clean paths like /blog/my-article
  usePathUrlStrategy();

  // Global SEO schemas (web only)
  if (kIsWeb) {
    MetaService.setOrganizationSchema();
    MetaService.setWebsiteSchema();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Revochamp Blog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    // Home → redirect or show blog
    GoRoute(
      path: '/',
      builder: (context, state) => const BlogListPage(),
    ),

    // ---------------- BLOG ----------------
    GoRoute(
      path: '/blog',
      builder: (context, state) => const BlogListPage(),
    ),
    GoRoute(
      path: '/blog/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return BlogPage(slug: slug);
      },
    ),

    // ---------------- NEWS ----------------
    GoRoute(
      path: '/news',
      builder: (context, state) => const NewListPage(),
    ),
   GoRoute(
  path: '/news/:slug',
  builder: (context, state) {
    final slug = state.pathParameters['slug']!;
    return NewsDetailPageWrapper(
      key: ValueKey(slug), // ✅ IMPORTANT
      slug: slug,
    );
  },
),

  ],

  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('Page not found')),
  ),
);

// // ✅ GoRouter configuration – clean, maintainable, and handles deep links
// final GoRouter _router = GoRouter(
//   routes: [
//     // Blog list – root path
//     GoRoute(
//       path: '/',
//       name: 'blog-list',
//       builder: (context, state) => const BlogListPage(),
//     ),
//     // Blog list – also handles /blog for consistency
//     GoRoute(
//       path: '/blog',
//       name: 'blog-list-alt',
//       builder: (context, state) => const BlogListPage(),
//     ),
//     // Blog detail – dynamic slug
//     GoRoute(
//       path: '/:slug',
//       name: 'blog-detail',
//       builder: (context, state) {
//         final slug = state.pathParameters['slug']!;
//         return BlogPage(slug: slug);
//       },
//     ),
//        // News
//     GoRoute(
//       path: '/news',
//       builder: (context, state) => const NewListPage(),
//     ),
//     // GoRoute(
//     //   path: '/news/:slug',
//     //   builder: (context, state) {
//     //     final slug = state.pathParameters['slug']!;
//     //     return NewsPage(slug: slug);
//     //   },
//     // ),
//   ],
//   // Optional: 404 page (if user goes to an unknown route)
//   errorBuilder: (context, state) => const Scaffold(
//     body: Center(
//       child: Text(
//         'Page not found',
//         style: TextStyle(fontFamily: 'Georgia', fontSize: 18),
//       ),
//     ),
//   ),
// );