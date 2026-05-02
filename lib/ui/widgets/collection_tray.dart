import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/game_state.dart';
import '../../data/element_data.dart';
import 'emoji_bubble.dart';

class CollectionTray extends StatelessWidget {
  const CollectionTray({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discoveredIds = context.select<GameState, List<String>>((gameState) {
      final ids = gameState.discoveredElements.toList();
      ids.sort((a, b) {
        final elementA = ElementData.elements[a]!;
        final elementB = ElementData.elements[b]!;
        final categoryCompare = elementA.category.index.compareTo(
          elementB.category.index,
        );
        if (categoryCompare != 0) return categoryCompare;
        return elementA.name.compareTo(elementB.name);
      });
      return ids;
    });
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: const Color(0xFFD7B78E), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: discoveredIds.length,
        itemBuilder: (context, index) {
          final element = ElementData.elements[discoveredIds[index]]!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child:
                Draggable<String>(
                  data: element.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: EmojiBubble(
                      element: element,
                      size: 76,
                      highlighted: true,
                      compactLabel: true,
                      accentColor: const Color(0xFFE1B26C),
                      showLabel: false,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: EmojiBubble(
                      element: element,
                      size: 72,
                      compactLabel: true,
                      showLabel: false,
                    ),
                  ),
                  child: EmojiBubble(
                    element: element,
                    size: 72,
                    compactLabel: true,
                    showLabel: false,
                  ),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: (index % 6) * 55),
                  duration: 180.ms,
                ),
          );
        },
      ),
    );
  }
}
