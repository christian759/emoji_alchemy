import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/game_state.dart';
import '../widgets/app_bottom_navigation.dart';
import 'codex_screen.dart';
import 'game_screen.dart';
import 'daily_puzzle_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final accent = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'THE GREAT LAB',
                    style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.5, color: const Color(0xFF7A5D42)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 8,
                    children: [
                      Text(
                        'Emoji',
                        style: theme.textTheme.displayLarge,
                      ),
                      Text(
                        'Alchemy',
                        style: theme.textTheme.displayLarge?.copyWith(color: accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFB89672), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 14,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TODAY · DAY 142',
                              style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFD2B692), letterSpacing: 1.2),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A382C),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '3 hints',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Steam Engine Run',
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 28),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Reach 🔥 + 💧 in 6 steps',
                          style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFFCEB292)),
                        ),
                        const SizedBox(height: 26),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const GameScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: theme.canvasColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFD7B78E), width: 1.4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Chris_Alch · Sage',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF4A3726)),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: gameState.discoveriesCount / gameState.maxDiscoveries,
                          backgroundColor: Colors.white70,
                          color: accent,
                          minHeight: 10,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${gameState.discoveriesCount} / ${gameState.maxDiscoveries} discovered',
                          style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF5E4A3D)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _ActionTile(
                        icon: Icons.science,
                        label: 'Sandbox',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const GameScreen()),
                          );
                        },
                      ),
                      _ActionTile(
                        icon: Icons.calendar_today,
                        label: 'Daily',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const DailyPuzzleScreen()),
                          );
                        },
                      ),
                      _ActionTile(
                        icon: Icons.book,
                        label: 'Codex',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CodexScreen()),
                          );
                        },
                      ),
                      _ActionTile(
                        icon: Icons.person,
                        label: 'Profile',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          _navigateTo(context, index);
        },
      ),
    );
  }

  void _navigateTo(BuildContext context, int index) {
    final routes = [
      () => const HomeScreen(),
      () => const GameScreen(),
      () => const CodexScreen(),
      () => const ProfileScreen(),
    ];
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => routes[index]()!),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 88) / 2,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD7B78E), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF8A4F2B), size: 28),
            const SizedBox(height: 12),
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? theme.colorScheme.secondary : const Color(0xFF8A4F2B)),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: active ? theme.colorScheme.secondary : const Color(0xFF7A5D42),
          ),
        ),
      ],
    );
  }
}
