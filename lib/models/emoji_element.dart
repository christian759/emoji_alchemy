import 'package:flutter/foundation.dart';
import 'element_category.dart';

class EmojiElement {
  final String id;
  final String emoji;
  final String name;
  final ElementCategory category;
  final bool isBase;

  const EmojiElement({
    required this.id,
    required this.emoji,
    required this.name,
    required this.category,
    this.isBase = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmojiElement && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
