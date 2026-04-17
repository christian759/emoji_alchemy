import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../models/emoji_item.dart';
import 'emoji_widget.dart';

import '../logic/recipe_manager.dart';

class InventoryBar extends StatelessWidget {
  const InventoryBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final discovered = controller.filteredInventory;
    final categories = ["All", ...RecipeManager.categories.keys];

    return Container(
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E26),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: categories.map((cat) {
                final isSelected = controller.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => controller.setCategory(cat),
                    backgroundColor: Colors.white10,
                    selectedColor: Colors.purple.withOpacity(0.5),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: discovered.length,
              itemBuilder: (context, index) {
                final emoji = discovered[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Draggable<String>(
                    data: emoji,
                    feedback: Material(
                      color: Colors.transparent,
                      child: EmojiWidget(
                        item: EmojiItem(emoji: emoji, id: 'preview'),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // Spawn in center area with slight random offset
                        final offset = Offset(100.0 + (index % 5) * 20, 100.0 + (index % 3) * 20);
                        controller.addEmojiToCanvas(emoji, offset);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EmojiWidget(
                            item: EmojiItem(emoji: emoji, id: 'inv_$index'),
                            isDraggable: false,
                          ),
                        ],
                      ),
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
