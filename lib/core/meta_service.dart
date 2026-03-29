import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

class MetaService {
  // 🔁 Changed from '/tech' to '/blog'
  static const String baseUrl = 'https://revochamp.site/blog';
  static const String _baseUrl = 'https://revochamp.site/blog';
  static const String _siteUrl = 'https://revochamp.site';
  static const String _defaultOgImage = '$_baseUrl/default-og-image.png';
  static const String _logoUrl = '$_siteUrl/logo.png';

  static void updateMetaTags({
    required String title,
    required String description,
    String? imageUrl,
    String? slug,
    String? articleType,
    DateTime? publishedDate,
    DateTime? modifiedDate,
  }) {
    if (!kIsWeb) return;

    // Build clean canonical URL (no query params, no fragments)
    final rawUrl = slug != null
        ? '$_baseUrl/flutter/$slug'   // e.g., /blog/flutter/your-article
        : html.window.location.href;
    final uri = Uri.parse(rawUrl);
    final cleanUrl = uri.replace(query: null, fragment: null).toString();

    html.document.title = '$title | Revochamp';

    // Basic meta tags
    _updateNameMeta('description', description);
    _updateNameMeta('keywords', 'flutter, dart, tutorial, blog, ${title.toLowerCase()}');
    _updateNameMeta('robots', 'index, follow');
    _updateNameMeta('author', 'Revochamp');
    _updateNameMeta('theme-color', '#0f172a');
    _updateNameMeta('viewport', 'width=device-width, initial-scale=1, maximum-scale=5');
    _updateNameMeta('application-name', 'Revochamp');

    // Open Graph
    final ogImage = imageUrl ?? _defaultOgImage;
    _updatePropertyMeta('og:title', title);
    _updatePropertyMeta('og:description', description);
    _updatePropertyMeta('og:image', ogImage);
    _updatePropertyMeta('og:image:width', '1200');
    _updatePropertyMeta('og:image:height', '630');
    _updatePropertyMeta('og:url', cleanUrl);
    _updatePropertyMeta('og:type', articleType == 'website' ? 'website' : 'article');
    _updatePropertyMeta('og:site_name', 'Revochamp');
    _updatePropertyMeta('og:locale', 'en_US');

    // Twitter
    _updateNameMeta('twitter:card', 'summary_large_image');
    _updateNameMeta('twitter:title', title);
    _updateNameMeta('twitter:description', description);
    _updateNameMeta('twitter:image', ogImage);
    _updateNameMeta('twitter:site', '@Revochamp');
    _updateNameMeta('twitter:creator', '@Revochamp');

    // Canonical
    setCanonical(cleanUrl);

    // Article schema for blog posts
    if (articleType == 'article' && publishedDate != null) {
      setArticleSchema(
        title: title,
        description: description,
        imageUrl: ogImage,
        url: cleanUrl,
        publishedDate: publishedDate,
        modifiedDate: modifiedDate ?? publishedDate,
      );
    }
  }

  static void setArticleSchema({
    required String title,
    required String description,
    required String imageUrl,
    required String url,
    required DateTime publishedDate,
    required DateTime modifiedDate,
  }) {
    final articleData = {
      "@context": "https://schema.org",
      "@type": "Article",
      "headline": title,
      "description": description,
      "image": imageUrl,
      "url": url,
      "datePublished": publishedDate.toIso8601String(),
      "dateModified": modifiedDate.toIso8601String(),
      "author": {
        "@type": "Organization",
        "name": "Revochamp",
        "url": _siteUrl,
      },
      "publisher": {
        "@type": "Organization",
        "name": "Revochamp",
        "logo": {
          "@type": "ImageObject",
          "url": _logoUrl,
        },
      },
      "mainEntityOfPage": url,
    };
    setStructuredData(articleData, id: 'article-schema');
  }

  static void setOrganizationSchema() {
    setStructuredData({
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": "Revochamp",
      "url": _siteUrl,
      "logo": _logoUrl,
      "sameAs": [
        "https://twitter.com/Revochamp",
        // Add other social profiles
      ],
    }, id: 'organization-schema');
  }

  static void setWebsiteSchema() {
    if (!kIsWeb) return;
    final existing = html.document.querySelector('#website-schema');
    if (existing != null) return;
    final script = html.ScriptElement()
      ..id = 'website-schema'
      ..type = 'application/ld+json'
      ..text = jsonEncode({
        "@context": "https://schema.org",
        "@type": "WebSite",
        "name": "Revochamp",
        "url": _baseUrl,
      });
    html.document.head?.append(script);
  }

  static void setBreadcrumbData({
    required String title,
    required String slug,
    List<Map<String, String>>? parents,
  }) {
    final itemListElement = <Map<String, dynamic>>[];
    var position = 1;

    if (parents != null) {
      for (final parent in parents) {
        itemListElement.add({
          '@type': 'ListItem',
          'position': position++,
          'name': parent['name'],
          'item': parent['url'],
        });
      }
    }
    itemListElement.add({
      '@type': 'ListItem',
      'position': position,
      'name': title,
      'item': '$_baseUrl/flutter/$slug',
    });
    setStructuredData({
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      'itemListElement': itemListElement,
    }, id: 'breadcrumb-schema');
  }

  static void setStructuredData(Map<String, dynamic> data, {String? id}) {
    if (!kIsWeb) return;
    if (id != null) {
      final existing = html.document.querySelector('#${id}');
      existing?.remove();
    } else {
      final allScripts = html.document.querySelectorAll('script[type="application/ld+json"]');
      allScripts.forEach((script) => script.remove());
    }
    final script = html.ScriptElement()
      ..type = 'application/ld+json'
      ..text = jsonEncode(data);
    if (id != null) script.id = id;
    html.document.head?.append(script);
  }

  static void setCanonical(String url) {
    if (!kIsWeb) return;
    var link = html.document.querySelector('link[rel="canonical"]') as html.LinkElement?;
    if (link == null) {
      link = html.LinkElement()..rel = 'canonical';
      html.document.head?.append(link);
    }
    link.href = url;
  }

  static void _updateNameMeta(String name, String content) {
    var tag = html.document.querySelector('meta[name="$name"]') as html.MetaElement?;
    if (tag == null) {
      tag = html.MetaElement()..name = name;
      html.document.head?.append(tag);
    }
    tag.content = content;
  }

  static void _updatePropertyMeta(String property, String content) {
    var tag = html.document.querySelector('meta[property="$property"]') as html.MetaElement?;
    if (tag == null) {
      tag = html.MetaElement()..setAttribute('property', property);
      html.document.head?.append(tag);
    }
    tag.setAttribute('content', content);
  }

  @visibleForTesting
  static void clearAll() {
    if (!kIsWeb) return;
    final head = html.document.head;
    if (head != null) {
      head
          .querySelectorAll('meta[name], meta[property], script[type="application/ld+json"], link[rel="canonical"]')
          .forEach((element) => element.remove());
    }
  }
}