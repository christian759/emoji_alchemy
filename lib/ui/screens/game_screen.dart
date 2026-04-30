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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A3726)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Column(
                    children: [
                      Text(
                        'The Lab',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${gameState.discoveriesCount} discovered',
                        style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7A5D42)),
                      ),
                    ],
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).pushNamed('/hints'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B382E),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.white, size: 18),
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFB89672), width: 1.2),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Starting Elements', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFD2B692), letterSpacing: 1.2)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        _StarterChip(label: 'Fire', icon: '🔥'),
                        _StarterChip(label: 'Water', icon: '💧'),
                        _StarterChip(label: 'Earth', icon: '🌍'),
                        _StarterChip(label: 'Wood', icon: '🪵'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.canvasColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFD7B78E), width: 1.2),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: CanvasArea(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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

class _StarterChip extends StatelessWidget {
  final String label;
  final String icon;

  const _StarterChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7B78E), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A3726), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
