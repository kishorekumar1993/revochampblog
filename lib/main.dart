import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:revochampblog/core/meta_service.dart';
import 'package:revochampblog/pages/blog_list_page.dart';
import 'package:revochampblog/pages/blog_page.dart';

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

// ✅ GoRouter configuration – clean, maintainable, and handles deep links
final GoRouter _router = GoRouter(
  routes: [
    // Blog list – root path
    GoRoute(
      path: '/',
      name: 'blog-list',
      builder: (context, state) => const BlogListPage(),
    ),
    // Blog list – also handles /blog for consistency
    GoRoute(
      path: '/blog',
      name: 'blog-list-alt',
      builder: (context, state) => const BlogListPage(),
    ),
    // Blog detail – dynamic slug
    GoRoute(
      path: '/:slug',
      name: 'blog-detail',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return BlogPage(slug: slug);
      },
    ),
  ],
  // Optional: 404 page (if user goes to an unknown route)
  errorBuilder: (context, state) => const Scaffold(
    body: Center(
      child: Text(
        'Page not found',
        style: TextStyle(fontFamily: 'Georgia', fontSize: 18),
      ),
    ),
  ),
);

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:revochampblog/core/meta_service.dart';
// import 'package:revochampblog/pages/blog_list_page.dart';
// import 'package:revochampblog/pages/blog_page.dart';

// void main() {
// WidgetsFlutterBinding.ensureInitialized(); // ADD THIS
//  if (kIsWeb) {
//     // Set global schemas once
//     MetaService.setOrganizationSchema();
//     MetaService.setWebsiteSchema();
//   }
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Revochamp Blog',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       debugShowCheckedModeBanner: false,
//       // home handles the root route "/"
//       home: const BlogListPage(),
//      onGenerateRoute: (settings) {
//     if (settings.name == '/') {
//       return MaterialPageRoute(builder: (_) => BlogListPage());
//     }
//     if (settings.name!.startsWith('/blog/')) {
//       final slug = settings.name!.substring(6); // remove '/blog/'
//       return MaterialPageRoute(
//         builder: (_) => BlogPage(slug: slug),
//       );
//     }
//     return null;
//   },
//       // onGenerateRoute: (settings) {
//       //   if (settings.name?.startsWith('/blog/') ?? false) {
//       //     final slug = settings.name!.substring('/blog/'.length);
//       //     return MaterialPageRoute(
            
//       //       builder: (context) => BlogPage(slug: slug),
//       //       // builder: (context) => BlogPage(slug: slug),
//       //     );
//       //   }
//       //   // For any other route, return null (will show error, but we won't use them)
//       //   return null;
//       // },
//     );
//   }
// }