import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../models/emoji_item.dart';
import 'emoji_widget.dart';

class PlayArea extends StatelessWidget {
  const PlayArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        final renderContent = context.findRenderObject() as RenderBox;
        final localPos = renderContent.globalToLocal(details.offset);
        controller.addEmojiToCanvas(details.data, localPos);
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            // Background Grid or gradient
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.blueGrey.shade900,
                    Colors.black,
                  ],
                  radius: 1.5,
                ),
              ),
            ),
            // Floating Emojis
            ...controller.canvasEmojis.map((item) {
              return Positioned(
                left: item.position.dx,
                top: item.position.dy,
                child: Draggable<EmojiItem>(
                  data: item,
                  feedback: Material(
                    color: Colors.transparent,
                    child: EmojiWidget(item: item),
                  ),
                  childWhenDragging: const SizedBox.shrink(),
                  onDragEnd: (details) {
                    final renderContent = context.findRenderObject() as RenderBox;
                    final localPos = renderContent.globalToLocal(details.offset);
                    
                    // Boundary check
                    final clampedPos = Offset(
                      localPos.dx.clamp(0.0, renderContent.size.width - 60),
                      localPos.dy.clamp(0.0, renderContent.size.height - 60),
                    );

                    controller.updateEmojiPosition(item.id, clampedPos);
                    controller.checkCollision(item.copyWith(position: clampedPos));
                  },
                  child: EmojiWidget(item: item),
                ),
              );
            }).toList(),
            
            if (controller.canvasEmojis.isEmpty)
              Center(
                child: Text(
                  "Drag emojis here to combine!",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
