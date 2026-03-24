import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/blog_content_block.dart';
import '../models/content_item.dart';
import 'content_widget.dart';

mixin ContentBuilder {
  // Extract all headings from sections (used for TOC)
  List<ContentItem> extractHeadings(List<BlogContentBlock> blocks) {
    final headings = <ContentItem>[];
    for (var block in blocks) {
      if (block is SectionBlock) {
        for (var item in block.content) {
          if (item.type == ContentType.heading) {
            headings.add(item);
          }
        }
      }
    }
    return headings;
  }

  // Build all content blocks (intro, sections, CTA, conclusion)
  List<Widget> buildBlocks(
    BuildContext context,
    List<BlogContentBlock> blocks, {
    required Function(String) onCopyCode,
    List<GlobalKey>? headingKeys,
    required int Function() getHeadingIndex,
  }) {
    final widgets = <Widget>[];
    for (var block in blocks) {
      if (block is IntroBlock) {
        widgets.add(_buildIntro(block));
      } else if (block is SectionBlock) {
        widgets.add(_buildSection(
          context,
          block,
          onCopyCode: onCopyCode,
          headingKeys: headingKeys,
          getHeadingIndex: getHeadingIndex,
        ));
      } else if (block is CTABlock) {
        widgets.add(_buildCTA(block, context));
      } else if (block is ConclusionBlock) {
        widgets.add(_buildConclusion(block));
      }
    }
    return widgets;
  }

  Widget _buildIntro(IntroBlock intro) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        intro.description,
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    SectionBlock section, {
    required Function(String) onCopyCode,
    List<GlobalKey>? headingKeys,
    required int Function() getHeadingIndex,
  }) {
    final children = <Widget>[];

    // Header with emoji
    children.add(
      Row(
        children: [
          Text(
            section.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              section.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
    );
    children.add(const SizedBox(height: 16));

    // Section image
    if (section.image.isNotEmpty) {
      children.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: section.image,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      );
      children.add(const SizedBox(height: 16));
    }

    // Section content (text, list, headings, etc.)
    for (var item in section.content) {
      if (item.type == ContentType.heading) {
        final idx = getHeadingIndex();
        final key = headingKeys != null && idx < headingKeys.length ? headingKeys[idx] : null;
        children.add(
          Container(
            key: key,
            margin: const EdgeInsets.only(top: 24, bottom: 12),
            child: ContentItemWidget(item: item, onCopy: onCopyCode),
          ),
        );
      } else {
        children.add(
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ContentItemWidget(item: item, onCopy: onCopyCode),
          ),
        );
      }
    }

    // Keyword tag
    children.add(
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            section.keyword,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
    children.add(const SizedBox(height: 32));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildCTA(CTABlock cta, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            cta.title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            cta.description,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: handle navigation
            },
            child: Text(cta.buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildConclusion(ConclusionBlock conclusion) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            conclusion.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            conclusion.description,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }
}