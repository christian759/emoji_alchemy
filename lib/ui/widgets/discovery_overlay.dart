import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/game_state.dart';
import '../screens/discovery_screen.dart';
import 'emoji_bubble.dart';

class DiscoveryOverlay extends StatelessWidget {
  final CombinationOutcome outcome;

  const DiscoveryOverlay({super.key, required this.outcome});

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final gameState = Provider.of<GameState>(context, listen: false);
    final hintText = gameState.unlockHintFor(outcome.result);
    final recipeText =
        '${outcome.ingredientA.emoji} ${outcome.ingredientA.name} + '
        '${outcome.ingredientB.emoji} ${outcome.ingredientB.name} = '
        '${outcome.result.emoji} ${outcome.result.name}';

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
                    letterSpacing: 4,
                  ),
                )
                .animate()
                .slideY(begin: -2, duration: 500.ms, curve: Curves.easeOutBack)
                .fadeIn(),
            const SizedBox(height: 40),
            EmojiBubble(element: outcome.result, size: 150).animate().scale(
              begin: const Offset(0.2, 0.2),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 24),
            Text(
              outcome.result.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
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
                outcome.result.category.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fadeIn(delay: 800.ms).slideX(begin: 1),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white30, width: 1.2),
              ),
              child: Column(
                children: [
                  Text(
                    recipeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hintText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1.seconds),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => navigator.pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    navigator.pop();
                    Future.microtask(() {
                      navigator.push(
                        MaterialPageRoute(
                          builder: (_) => DiscoveryScreen(
                            element: outcome.result,
                            outcome: outcome,
                          ),
                        ),
                      );
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'VIEW DISCOVERY',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1.5.seconds),
          ],
        ),
      ),
    );
  }
}
