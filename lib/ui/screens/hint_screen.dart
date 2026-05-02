import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          final activeHint = gameState.activeHint;

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            children: [
              Text(
                'Your Lab Hints',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 10),
              Text(
                'Use a hint to reveal an actionable recipe based on what you have already discovered.',
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF7A5D42)),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E241A),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFB89672), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HINT TOKENS',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFE5D2B8),
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${gameState.hintsRemaining}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 42,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: gameState.hintsRemaining > 0
                              ? () {
                                  final hint = gameState.useHint();
                                  if (hint == null) return;
                                  showModalBottomSheet<void>(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => _HintRevealSheet(hint: hint),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD79C55),
                            foregroundColor: const Color(0xFF2E241A),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Reveal Hint'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Each hint now reveals a recipe you can act on, not just a generic clue.',
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFE5D2B8)),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.06, duration: 280.ms),
              if (activeHint != null) ...[
                const SizedBox(height: 18),
                _HintCard(
                  hint: activeHint,
                  emphasized: true,
                ).animate().fadeIn(duration: 240.ms),
              ],
              const SizedBox(height: 20),
              Text(
                'Suggested Paths',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...suggestions.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _HintCard(
                    hint: entry.value,
                    emphasized: entry.key == 0 && activeHint == null,
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: 80 * entry.key),
                        duration: 220.ms,
                      ),
                );
              }),
            ],
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

class _HintCard extends StatelessWidget {
  final LabHint hint;
  final bool emphasized;

  const _HintCard({
    required this.hint,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: emphasized ? const Color(0xFFF7EDDD) : theme.canvasColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: emphasized ? const Color(0xFFD79C55) : const Color(0xFFD7B78E),
          width: emphasized ? 1.3 : 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hint.badge,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF8A4F2B),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hint.title,
            style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF2E241A)),
          ),
          const SizedBox(height: 8),
          Text(
            hint.detail,
            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A3726)),
          ),
          if (hint.recipe != null) ...[
            const SizedBox(height: 10),
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
  }
}

class _HintRevealSheet extends StatelessWidget {
  final LabHint hint;

  const _HintRevealSheet({required this.hint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF2E241A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFB89672), width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hint.badge,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFF1C27D),
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hint.title,
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                hint.detail,
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFFEBDCC7)),
              ),
              if (hint.recipe != null) ...[
                const SizedBox(height: 12),
                Text(
                  hint.recipe!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFF1C27D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD79C55),
                    foregroundColor: const Color(0xFF2E241A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Back to Hints'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
