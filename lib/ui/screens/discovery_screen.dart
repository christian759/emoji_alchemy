import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../data/element_data.dart';
import '../../models/emoji_element.dart';
import '../../providers/game_state.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/emoji_bubble.dart';

class DiscoveryScreen extends StatelessWidget {
  final EmojiElement element;
  final CombinationOutcome? outcome;

  const DiscoveryScreen({super.key, required this.element, this.outcome});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameState = context.watch<GameState>();
    final recipes = gameState.recipesForResult(element.id);
    final followUpHints = gameState.buildDiscoveryHints(element, limit: 3);
    final seenUnlocks = <String>{};
    final unlocks = ElementData.combinations
        .where(
          (combo) =>
              combo.element1 == element.id || combo.element2 == element.id,
        )
        .where((combo) {
          final ordered = [combo.element1, combo.element2]..sort();
          return seenUnlocks.add(
            '${ordered.first}:${ordered.last}:${combo.result}',
          );
        })
        .where((combo) => !gameState.discoveredElements.contains(combo.result))
        .take(4)
        .toList();

    final recipeUsed = outcome != null
        ? '${outcome!.ingredientA.emoji} ${outcome!.ingredientA.name} + ${outcome!.ingredientB.emoji} ${outcome!.ingredientB.name} = ${element.emoji} ${element.name}'
        : (recipes.isNotEmpty
              ? gameState.recipeText(recipes.first)
              : 'This discovery has no stored recipe yet.');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Discovery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            Text(
              '- DISCOVERY -',
              style: theme.textTheme.bodySmall?.copyWith(
                letterSpacing: 1.7,
                color: const Color(0xFF7A5D42),
              ),
            ).animate().fadeIn(duration: 250.ms),
            const SizedBox(height: 16),
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFB89672),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4B382E),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          element.category.name.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFF7E8D2),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      EmojiBubble(
                        element: element,
                        size: 124,
                        highlighted: true,
                        accentColor: const Color(0xFFE1B26C),
                      ).animate().scale(
                        begin: const Offset(0.88, 0.88),
                        duration: 420.ms,
                        curve: Curves.easeOutBack,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        element.name,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 34,
                          color: const Color(0xFFF6ECDD),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You discovered a new ingredient for the lab.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFE6D7C3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.08, duration: 350.ms),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Recipe Used',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipeUsed,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF3F2E21),
                    ),
                  ),
                  if (recipes.length > 1) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${recipes.length} different recipes can create ${element.name}.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF7A5D42),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 120.ms, duration: 280.ms),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Next Best Hints',
              child: Column(
                children: followUpHints.map((hint) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E9D5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD7B78E),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hint.badge,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8A4F2B),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hint.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF2E241A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hint.detail,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF4A3726),
                          ),
                        ),
                        if (hint.recipe != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            hint.recipe!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF7A5D42),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(delay: 180.ms, duration: 280.ms),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'What This Unlocks',
              child: Column(
                children: unlocks.isEmpty
                    ? [
                        Text(
                          'You have already explored the obvious follow-ups for ${element.name}. Try pairing it with rarer items from other categories.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF4A3726),
                          ),
                        ),
                      ]
                    : unlocks.map((combo) {
                        final otherId = combo.element1 == element.id
                            ? combo.element2
                            : combo.element1;
                        final other = ElementData.elements[otherId]!;
                        final result = ElementData.elements[combo.result]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${element.emoji} + ${other.emoji} = ${result.emoji}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF2E241A),
                                  ),
                                ),
                              ),
                              Text(
                                result.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF7A5D42),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
              ),
            ).animate().fadeIn(delay: 240.ms, duration: 280.ms),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/lab');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E241A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Keep Exploring'),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7B78E), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              letterSpacing: 1.4,
              color: const Color(0xFF7A5D42),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
