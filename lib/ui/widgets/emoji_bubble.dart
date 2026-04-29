import 'package:flutter/material.dart';
import '../../models/emoji_element.dart';

class EmojiBubble extends StatelessWidget {
  final EmojiElement element;
  final double size;
  final bool isAnimated;

  const EmojiBubble({
    super.key,
    required this.element,
    this.size = 60,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 3,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            element.emoji,
            style: TextStyle(fontSize: size * 0.4),
          ),
          if (size >= 80) // Only show text if it's large enough (e.g. in tray)
            Text(
              element.name,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            )
        ],
      ),
    );
  }
}
