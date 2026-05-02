import 'package:flutter/material.dart';
import '../../models/emoji_element.dart';

class EmojiBubble extends StatelessWidget {
  final EmojiElement element;
  final double size;
  final bool highlighted;
  final bool compactLabel;
  final Color? accentColor;

  const EmojiBubble({
    super.key,
    required this.element,
    this.size = 60,
    this.highlighted = false,
    this.compactLabel = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final glowColor = accentColor ?? Theme.of(context).colorScheme.secondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFF3A2B20) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(
          color: highlighted ? glowColor : borderColor,
          width: highlighted ? 2.6 : 2,
        ),
        gradient: highlighted
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4C3726),
                  Color(0xFF2A1E15),
                ],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: highlighted ? glowColor.withOpacity(0.28) : const Color(0x1F000000),
            blurRadius: highlighted ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            element.emoji,
            style: TextStyle(fontSize: compactLabel ? size * 0.44 : size * 0.4),
          ),
          if (size >= 80) SizedBox(height: compactLabel ? 4 : 6),
          if (size >= 80)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                element.name,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compactLabel ? 9 : 10,
                  color: const Color(0xFFF2E7D6),
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: compactLabel ? 0.1 : 0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
