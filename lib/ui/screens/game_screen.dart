import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/canvas_area.dart';
import '../widgets/collection_tray.dart';
import '../../providers/game_state.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameState = Provider.of<GameState>(context);
    final baseElements = gameState.discoveredElementList.where((e) => e.isBase).toList();
    final recentElements = gameState.discoveredElementList.take(6).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFB89672), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DISCOVERED', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7A5D42), letterSpacing: 1.4)),
                          const SizedBox(height: 8),
                          Text(
                            '${gameState.discoveriesCount}',
                            style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.of(context).pushNamed('/hints'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B382E),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('${gameState.hintsRemaining} hints', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('THE LAB', style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.5, color: const Color(0xFF7A5D42))),
                        const SizedBox(height: 6),
                        Text('Emoji Alchemy', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (baseElements.isNotEmpty)
                    Row(
                      children: baseElements.map((base) {
                        return Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: theme.canvasColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFD7B78E), width: 1.1),
                          ),
                          child: Text(base.emoji, style: const TextStyle(fontSize: 22)),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFB89672), width: 1.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('LAB WORKSPACE', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7A5D42), letterSpacing: 1.4)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.canvasColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFD7B78E), width: 1.1),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(14.0),
                            child: CanvasArea(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('YOUR ELEMENTS', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7A5D42), letterSpacing: 1.4)),
                      const SizedBox(height: 12),
                      if (recentElements.isNotEmpty)
                        SizedBox(
                          height: 82,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: recentElements.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final element = recentElements[index];
                              return Container(
                                width: 82,
                                decoration: BoxDecoration(
                                  color: theme.canvasColor,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: const Color(0xFFD7B78E), width: 1.1),
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(element.emoji, style: const TextStyle(fontSize: 26)),
                                    const SizedBox(height: 6),
                                    Text(element.name, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF4A3726))),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Expanded(
              flex: 1,
              child: CollectionTray(),
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
