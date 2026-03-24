import 'content_item.dart';

abstract class BlogContentBlock {
  final String type;
  BlogContentBlock(this.type);
}

class IntroBlock extends BlogContentBlock {
  final String title;
  final String description;

  IntroBlock({required this.title, required this.description})
      : super('intro');
}

class SectionBlock extends BlogContentBlock {
  final String title;
  final String image;
  final String keyword;
  final String emoji;
  final List<ContentItem> content;

  SectionBlock({
    required this.title,
    required this.image,
    required this.keyword,
    required this.emoji,
    required this.content,
  }) : super('section');
}

class CTABlock extends BlogContentBlock {
  final String title;
  final String description;
  final String buttonText;
  final String link;

  CTABlock({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.link,
  }) : super('cta');
}

class ConclusionBlock extends BlogContentBlock {
  final String title;
  final String description;

  ConclusionBlock({required this.title, required this.description})
      : super('conclusion');
}