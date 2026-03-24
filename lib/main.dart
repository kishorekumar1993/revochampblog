import 'package:flutter/material.dart';
import 'package:revochampblog/pages/blog_list_page.dart';
import 'package:revochampblog/pages/blog_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revochamp Blog',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      // home handles the root route "/"
      home: const BlogListPage(),
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/blog/') ?? false) {
          final slug = settings.name!.substring('/blog/'.length);
          return MaterialPageRoute(
            
            builder: (context) => BlogPage(slug: slug),
            // builder: (context) => BlogPage(slug: slug),
          );
        }
        // For any other route, return null (will show error, but we won't use them)
        return null;
      },
    );
  }
}