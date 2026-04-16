import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/emoji_item.dart';

class EmojiWidget extends StatelessWidget {
  final EmojiItem item;
  final VoidCallback? onTap;
  final bool isDraggable;

  const EmojiWidget({
    Key? key,
    required this.item,
    this.onTap,
    this.isDraggable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          item.emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    )
        .animate()
        .scale(
          duration: 300.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn();

    if (!isDraggable) return content;

    return content;
  }
}
