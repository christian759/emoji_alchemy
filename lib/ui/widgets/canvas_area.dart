import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/game_state.dart';
import '../../data/element_data.dart';
import 'emoji_bubble.dart';
import 'discovery_overlay.dart';

class CanvasArea extends StatefulWidget {
  const CanvasArea({super.key});

  @override
  State<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<CanvasArea> with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  final double _canvasSize = 5000;
  final double _bubbleSize = 80;

  @override
  void initState() {
    super.initState();
    // Center the initial view
    _transformationController.value = Matrix4.identity()
      ..translate(-(_canvasSize / 2) + 200, -(_canvasSize / 2) + 300);
  }

  void _checkCombinations(String dragId, double x, double y) {
    final gameState = Provider.of<GameState>(context, listen: false);
    
    // Find collisions
    for (var element in gameState.canvasElements) {
      if (element.id == dragId) continue;

      double dx = element.x - x;
      double dy = element.y - y;
      double distance = sqrt(dx * dx + dy * dy);

      if (distance < _bubbleSize * 0.8) { // Collision threshold
        final result = gameState.attemptCombination(dragId, element.id, (x + element.x)/2, (y + element.y)/2);
        if (result != null) {
          // Play discovery overlay!
          showDialog(
            context: context,
            barrierColor: Colors.black87,
            builder: (_) => DiscoveryOverlay(element: result),
          );
        } else {
          // If result is null but it merged successfully, it was already discovered.
          // Or it failed. We aren't returning distinct enums yet.
          // Let's rely on the state changing for basic logic.
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        final gameState = Provider.of<GameState>(context, listen: false);
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset localOffset = box.globalToLocal(details.offset);
        final Offset sceneOffset = _transformationController.toScene(localOffset);
        
        final elementId = details.data;
        if (ElementData.elements.containsKey(elementId)) {
          gameState.addToCanvas(
            ElementData.elements[elementId]!, 
            sceneOffset.dx, 
            sceneOffset.dy
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        return ClipRect(
          child: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'Inter'),
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: EdgeInsets.all(_canvasSize),
              minScale: 0.2,
              maxScale: 3.0,
              constrained: false,
              child: SizedBox(
                width: _canvasSize,
                height: _canvasSize,
                child: Stack(
                  children: [
                    // Grid background
                    Positioned.fill(
                      child: GridPaper(
                        color: Colors.white.withOpacity(0.05),
                        divisions: 1,
                        subdivisions: 1,
                        interval: 100,
                      ),
                    ),
                    // Current Elements on Canvas
                    Consumer<GameState>(
                      builder: (context, gameState, child) {
                        return Stack(
                          children: gameState.canvasElements.map((placed) {
                            return Positioned(
                              left: placed.x,
                              top: placed.y,
                              child: GestureDetector(
                                onPanUpdate: (dragDetails) {
                                  // Update position
                                  final double scale = _transformationController.value.getMaxScaleOnAxis();
                                  gameState.updateElementPosition(
                                    placed.id, 
                                    placed.x + dragDetails.delta.dx / scale, 
                                    placed.y + dragDetails.delta.dy / scale
                                  );
                                },
                                onPanEnd: (_) {
                                  _checkCombinations(placed.id, placed.x, placed.y);
                                },
                                child: EmojiBubble(
                                  element: placed.element, 
                                  size: _bubbleSize,
                                )
                                // Gentle idle bob animation
                                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                .moveY(begin: -3, end: 3, duration: 2.seconds, curve: Curves.easeInOut),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
