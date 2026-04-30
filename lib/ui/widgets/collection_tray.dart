import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_state.dart';
import '../../data/element_data.dart';
import 'emoji_bubble.dart';

class CollectionTray extends StatelessWidget {
  const CollectionTray({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: const Color(0xFFD7B78E), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Consumer<GameState>(
        builder: (context, gameState, child) {
          final discoveredElements = gameState.discoveredElements
              .map((id) => ElementData.elements[id]!)
              .toList();
          discoveredElements.sort((a, b) => a.category.index.compareTo(b.category.index));

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: discoveredElements.length,
            itemBuilder: (context, index) {
              final element = discoveredElements[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Draggable<String>(
                  data: element.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: EmojiBubble(element: element, size: 80),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: EmojiBubble(element: element, size: 80),
                  ),
                  child: EmojiBubble(element: element, size: 80),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
