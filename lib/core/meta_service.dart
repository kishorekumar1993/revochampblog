// lib/core/meta_service.dart
import 'package:flutter/foundation.dart';

class MetaService {
  static void setCanonical(String url) {
    if (kIsWeb) {
      // For web, you can inject a <link rel="canonical"> using html package
      // or rely on server-side. Here we just print.
    }
  }

  static void updateMetaTags({
    required String title,
    required String description,
    required String slug,
  }) {
    if (kIsWeb) {
      // Use html package to update meta tags
      // Example: html.document.title = title;
    }
  }

  static void setStructuredData(Map<String, dynamic> data) {
    if (kIsWeb) {
      // Inject JSON-LD script tag
    }
  }

  static void setBreadcrumbData({
    required String title,
    required String slug,
    required List<Map<String, String>> parents,
  }) {
    if (kIsWeb) {
    }
  }
}