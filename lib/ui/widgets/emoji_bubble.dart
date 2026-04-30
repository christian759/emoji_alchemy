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
    final borderColor = Theme.of(context).dividerColor;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            element.emoji,
            style: TextStyle(fontSize: size * 0.4),
          ),
          if (size >= 80)
            const SizedBox(height: 6),
          if (size >= 80)
            Text(
              element.name,
              style: const TextStyle(fontSize: 10, color: Color(0xFFF2E7D6)),
              overflow: TextOverflow.ellipsis,
            )
        ],
      ),
    );
  }
}
