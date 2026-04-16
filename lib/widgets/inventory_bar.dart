import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../models/emoji_item.dart';
import 'emoji_widget.dart';

class InventoryBar extends StatelessWidget {
  const InventoryBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final discovered = controller.discoveredEmojis.toList()..sort();

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: discovered.length,
              itemBuilder: (context, index) {
                final emoji = discovered[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Draggable<String>(
                    data: emoji,
                    feedback: Material(
                      color: Colors.transparent,
                      child: EmojiWidget(
                        item: EmojiItem(emoji: emoji, id: 'preview'),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EmojiWidget(
                          item: EmojiItem(emoji: emoji, id: 'inv_$index'),
                          isDraggable: false,
                        ),
                        const SizedBox(height: 4),
                        // Mini label could go here
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
