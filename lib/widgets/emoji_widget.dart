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
    Widget content =
        Container(
              width: 68,
              height: 72, // Slightly taller for the 3D bottom border
              decoration: BoxDecoration(
                color: const Color(0xFF23232D),
                borderRadius: BorderRadius.circular(16),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFF121217), width: 6),
                ),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(item.emoji, style: const TextStyle(fontSize: 40)),
                ),
              ),
            )
            .animate()
            .scale(
              duration: 400.ms,
              curve: Curves.elasticOut,
              begin: const Offset(0.5, 0.5),
            )
            .fadeIn(duration: 200.ms);

    if (!isDraggable) return content;

    return content;
  }
}
