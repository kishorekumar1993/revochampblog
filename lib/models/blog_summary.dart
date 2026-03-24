class BlogSummary {
  final String slug;
  final String title;
  final String? image;      // matches 'image' from JSON
  final String summary;     // matches 'summary'
  final DateTime date;      // matches 'date'

  BlogSummary({
    required this.slug,
    required this.title,
    this.image,
    required this.summary,
    required this.date,
  });

  factory BlogSummary.fromJson(Map<String, dynamic> json) {
    return BlogSummary(
      slug: json['slug'] as String,
      title: json['title'] as String,
      image: json['image'] as String?,
      summary: json['summary'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}