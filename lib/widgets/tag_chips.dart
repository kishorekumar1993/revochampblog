import 'package:flutter/material.dart';

class TagChips extends StatelessWidget {
  final List<String> tags;
  final Color? backgroundColor;
  final void Function(String)? onTagPressed;

  const TagChips({
    Key? key,
    required this.tags,
    this.backgroundColor,
    this.onTagPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: tags.map((tag) {
        return ActionChip(
          label: Text('#$tag'),
          backgroundColor: backgroundColor ?? Colors.blue[50],
          onPressed: onTagPressed != null ? () => onTagPressed!(tag) : null,
        );
      }).toList(),
    );
  }
}