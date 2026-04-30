import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/emoji_element.dart';
import '../screens/discovery_screen.dart';
import 'emoji_bubble.dart';

class DiscoveryOverlay extends StatelessWidget {
  final EmojiElement element;

  const DiscoveryOverlay({
    super.key,
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'NEW DISCOVERY!',
              style: TextStyle(
                color: Colors.amber, 
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 4
              ),
            ).animate().slideY(begin: -2, duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
            const SizedBox(height: 40),
            
            EmojiBubble(element: element, size: 150)
                .animate()
                .scale(begin: const Offset(0.2, 0.2), duration: 600.ms, curve: Curves.elasticOut),
                
            const SizedBox(height: 24),
            Text(
              element.name,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 48, 
                fontWeight: FontWeight.bold
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 1),
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                element.category.name.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ).animate().fadeIn(delay: 800.ms).slideX(begin: 1),
            
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('CONTINUE', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future.microtask(() {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DiscoveryScreen(element: element)),
                      );
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('VIEW DISCOVERY', style: TextStyle(color: Colors.white)),
                ),
              ],
            ).animate().fadeIn(delay: 1.5.seconds),
          ],
        ),
      ),
    );
  }
}
