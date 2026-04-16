import 'package:flutter/material.dart';

class EmojiItem {
  final String emoji;
  final String id;
  Offset position;

  EmojiItem({
    required this.emoji,
    required this.id,
    this.position = Offset.zero,
  });

  EmojiItem copyWith({Offset? position}) {
    return EmojiItem(
      emoji: emoji,
      id: id,
      position: position ?? this.position,
    );
  }
}
