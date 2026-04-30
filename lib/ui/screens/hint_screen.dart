import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_state.dart';
import '../widgets/app_bottom_navigation.dart';

class HintScreen extends StatelessWidget {
  const HintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Hints', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          final suggestions = gameState.hintSuggestions;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your Lab Hints',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'These clues refresh based on your current discoveries and progress.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF7A5D42)),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.dividerColor, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hints remaining', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7A5D42), letterSpacing: 1.2)),
                          const SizedBox(height: 6),
                          Text('${gameState.hintsRemaining}', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: gameState.hintsRemaining > 0
                            ? () {
                                gameState.consumeHint();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Hint used. ${gameState.hintSuggestions.first}'),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Use a Hint'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: suggestions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: theme.canvasColor,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFD7B78E), width: 1.1),
                        ),
                        child: Text(
                          suggestions[index],
                          style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A3726)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          final routeNames = ['/', '/lab', '/codex', '/profile'];
          Navigator.of(context).pushReplacementNamed(routeNames[index]);
        },
      ),
    );
  }
}
