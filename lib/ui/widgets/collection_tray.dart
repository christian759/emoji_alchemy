import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_state.dart';
import '../../data/element_data.dart';
import 'emoji_bubble.dart';

class CollectionTray extends StatelessWidget {
  const CollectionTray({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(color: Colors.white24, width: 2),
        ),
      ),
      child: Consumer<GameState>(
        builder: (context, gameState, child) {
          final discoveredElements = gameState.discoveredElements
              .map((id) => ElementData.elements[id]!)
              .toList();
          
          // Sort or group by category if desired
          discoveredElements.sort((a, b) => a.category.index.compareTo(b.category.index));

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    opacity: 0.3,
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
