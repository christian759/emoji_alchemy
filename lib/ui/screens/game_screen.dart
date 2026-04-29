import 'package:flutter/material.dart';
import '../widgets/canvas_area.dart';
import '../widgets/collection_tray.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Hints and Back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text('Lab Workspace', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.lightbulb_outline),
                    color: Colors.yellow,
                    onPressed: () {
                      // Show hint logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hint: Try combining two basic elements!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            // The Main Workspace Canvas
            const Expanded(
              flex: 3,
              child: CanvasArea(),
            ),
            // The Collection Tray
            const Expanded(
              flex: 1,
              child: CollectionTray(),
            ),
          ],
        ),
      ),
    );
  }
}
