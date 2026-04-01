enum ContentType { heading, text, code, list, image,table,highlight,tip,warning,cta,featureBox  }

class ContentItem {
  final ContentType type;
  final String value;
  final String? language;
  final String? imageUrl;
  final String? caption;
    final String? title; // ✅ ADD THIS
  // ✅ ADD THESE
  final List<String>? headers;
  final List<List<String>>? rows;

  ContentItem({
    required this.type,
    required this.value,
    this.language,
    this.imageUrl,
    this.caption,
    this.title,
        this.headers,
    this.rows,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      type: _parseContentType(json['type']),
      value: json['value'] ?? '',
      language: json['language'],
      imageUrl: json['imageUrl'],
      caption: json['caption'],
      title:json['title'],
         // ✅ PARSE TABLE
      headers: json['headers'] != null
          ? List<String>.from(json['headers'])
          : null,

      rows: json['rows'] != null
          ? (json['rows'] as List)
              .map((row) => List<String>.from(row))
              .toList()
          : null,
    );
  }

  static ContentType _parseContentType(String type) {
    switch (type) {
      case 'heading':
        return ContentType.heading;
      case 'text':
        return ContentType.text;
      case 'code':
        return ContentType.code;
      case 'list':
        return ContentType.list;
      case 'image':
        return ContentType.image;
      case 'table':
        return ContentType.table;
      default:
        return ContentType.text;
    }
  }
}

class TableContent {
  final List<String> headers;
  final List<List<String>> rows;

  TableContent({required this.headers, required this.rows});
}