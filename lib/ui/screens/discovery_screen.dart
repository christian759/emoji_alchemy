import 'package:flutter/material.dart';
import '../../data/element_data.dart';
import '../../models/emoji_element.dart';
import '../widgets/emoji_bubble.dart';
import '../widgets/app_bottom_navigation.dart';

class DiscoveryScreen extends StatelessWidget {
  final EmojiElement element;

  const DiscoveryScreen({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final combos = ElementData.combinations
        .where((combo) => combo.element1 == element.id || combo.element2 == element.id)
        .take(5)
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Discovery', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('- DISCOVERY -', style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.5, color: const Color(0xFF7A5D42))),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: theme.dividerColor, width: 1.2),
              ),
              child: Column(
                children: [
                  EmojiBubble(element: element, size: 120),
                  const SizedBox(height: 20),
                  Text(element.name, style: theme.textTheme.titleLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('You discovered', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7A5D42))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('UNLOCKS COMBINATIONS', style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.4, color: const Color(0xFF7A5D42))),
            const SizedBox(height: 16),
            ...combos.map((combo) {
              final otherId = combo.element1 == element.id ? combo.element2 : combo.element1;
              final otherElement = ElementData.elements[otherId]!;
              final result = ElementData.elements[combo.result]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('${element.emoji} + ${otherElement.emoji}', style: theme.textTheme.titleLarge),
                          const SizedBox(width: 10),
                          Text('=', style: theme.textTheme.bodyLarge),
                          const SizedBox(width: 10),
                          Text(result.emoji, style: theme.textTheme.titleLarge),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(result.name, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF4A3726))),
                  ],
                ),
              );
            }),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/lab');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('KEEP EXPLORING'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          _navigateTo(context, index);
        },
      ),
    );
  }

  void _navigateTo(BuildContext context, int index) {
    final routeNames = ['/', '/lab', '/codex', '/profile'];
    Navigator.of(context).pushReplacementNamed(routeNames[index]);
  }
}
