import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/game_state.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/canvas_area.dart';
import '../widgets/collection_tray.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameState = context.select<GameState, _LabHeaderData>((game) {
      return _LabHeaderData(
        hintsRemaining: game.hintsRemaining,
        canvasIsEmpty: game.canvasElements.isEmpty,
        discoveriesCount: game.discoveriesCount,
      );
    });
    final notifier = context.read<GameState>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE LAB',
                          style: theme.textTheme.bodySmall?.copyWith(
                            letterSpacing: 1.6,
                            color: const Color(0xFF7A5D42),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${gameState.discoveriesCount} discovered',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      runAlignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TopChip(
                          label: '${gameState.hintsRemaining} hints',
                          onTap: () =>
                              Navigator.of(context).pushNamed('/hints'),
                        ),
                        _TopChip(
                          label: 'Clear',
                          enabled: !gameState.canvasIsEmpty,
                          onTap: gameState.canvasIsEmpty
                              ? null
                              : notifier.clearCanvas,
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 220.ms),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFD8BA91),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const CanvasArea(),
                ).animate().fadeIn(delay: 60.ms, duration: 260.ms),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 92, child: CollectionTray()),
            ],
          ),
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

class _LabHeaderData {
  final int hintsRemaining;
  final bool canvasIsEmpty;
  final int discoveriesCount;

  const _LabHeaderData({
    required this.hintsRemaining,
    required this.canvasIsEmpty,
    required this.discoveriesCount,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _LabHeaderData &&
            hintsRemaining == other.hintsRemaining &&
            canvasIsEmpty == other.canvasIsEmpty &&
            discoveriesCount == other.discoveriesCount;
  }

  @override
  int get hashCode =>
      Object.hash(hintsRemaining, canvasIsEmpty, discoveriesCount);
}

class _TopChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const _TopChip({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = enabled ? Colors.white : const Color(0xFFD0C0AD);
    final background = enabled
        ? const Color(0xFF2E241A)
        : const Color(0xFF8F7E6D);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
