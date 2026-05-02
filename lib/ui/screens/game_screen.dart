import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../data/element_data.dart';
import '../../providers/game_state.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/canvas_area.dart';
import '../widgets/collection_tray.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameState = context.select<GameState, _LabViewData>((game) {
      final discovered = game.discoveredElementList;
      final baseIds = discovered
          .where((e) => e.isBase)
          .map((e) => e.id)
          .toList();
      final recentIds = discovered.reversed.take(5).map((e) => e.id).toList();
      final topHint = game.hintSuggestions.first;
      return _LabViewData(
        discoveriesCount: game.discoveriesCount,
        completionPercent: game.completionPercent,
        hintsRemaining: game.hintsRemaining,
        rarestElementName: game.rarestElement.name,
        canvasIsEmpty: game.canvasElements.isEmpty,
        maxDiscoveries: game.maxDiscoveries,
        topHintDetail: topHint.detail,
        topHintRecipe: topHint.recipe,
        baseIds: baseIds,
        recentIds: recentIds,
      );
    });
    final notifier = context.read<GameState>();
    final baseElements = gameState.baseIds
        .map((id) => ElementData.elements[id]!)
        .toList();
    final recentElements = gameState.recentIds
        .map((id) => ElementData.elements[id]!)
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x32D79C55), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x1F8A4F2B), Colors.transparent],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    children: [
                      Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'THE GREAT LAB',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            letterSpacing: 1.7,
                                            color: const Color(0xFF7A5D42),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Emoji\nAlchemy',
                                      style: theme.textTheme.displayLarge
                                          ?.copyWith(fontSize: 40, height: 1),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () =>
                                    Navigator.of(context).pushNamed('/hints'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E241A),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.lightbulb_outline_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${gameState.hintsRemaining} hints',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(duration: 260.ms)
                          .slideY(begin: -0.08, duration: 260.ms),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: _InfoCard(
                              title: 'Today',
                              headline:
                                  '${gameState.discoveriesCount} discovered',
                              body: gameState.topHintDetail,
                              footer:
                                  gameState.topHintRecipe ??
                                  'Open hints for a guided recipe.',
                              dark: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _StatCard(
                              value: '${gameState.completionPercent}%',
                              label: 'Codex filled',
                              sublabel:
                                  '${gameState.maxDiscoveries - gameState.discoveriesCount} left',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStat(
                              icon: Icons.auto_awesome,
                              label: 'Recent',
                              value: recentElements.isNotEmpty
                                  ? recentElements.first.name
                                  : 'Base set',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniStat(
                              icon: Icons.local_fire_department_outlined,
                              label: 'Rarest',
                              value: gameState.rarestElementName,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: gameState.canvasIsEmpty
                                  ? null
                                  : notifier.clearCanvas,
                              child: _MiniStat(
                                icon: Icons.layers_clear_outlined,
                                label: 'Workspace',
                                value: gameState.canvasIsEmpty
                                    ? 'Clean'
                                    : 'Clear',
                                emphasized: !gameState.canvasIsEmpty,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 80.ms, duration: 260.ms),
                      const SizedBox(height: 16),
                      Container(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFD8BA91),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'LAB WORKSPACE',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  letterSpacing: 1.4,
                                                  color: const Color(
                                                    0xFF7A5D42,
                                                  ),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Loose overlap mixing with live combine previews',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: const Color(
                                                    0xFF5D4634,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: baseElements.take(4).map((
                                        base,
                                      ) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF9F0E2),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFD7B78E),
                                              width: 1.1,
                                            ),
                                          ),
                                          child: Text(
                                            base.emoji,
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.43,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(26),
                                      border: Border.all(
                                        color: const Color(0xFFD7B78E),
                                        width: 1.1,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x14000000),
                                          blurRadius: 18,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: const CanvasArea(),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Recently discovered',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    letterSpacing: 1.3,
                                    color: const Color(0xFF7A5D42),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 86,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: recentElements.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 10),
                                    itemBuilder: (context, index) {
                                      final element = recentElements[index];
                                      return Container(
                                        width: 86,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8EDDD),
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFD7B78E),
                                            width: 1.1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              element.emoji,
                                              style: const TextStyle(
                                                fontSize: 26,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              element.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: const Color(
                                                      0xFF4A3726,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ).animate().fadeIn(
                                        delay: Duration(
                                          milliseconds: 100 * index,
                                        ),
                                        duration: 220.ms,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 120.ms, duration: 280.ms)
                          .slideY(begin: 0.04, duration: 280.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 116, child: CollectionTray()),
              ],
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

class _LabViewData {
  final int discoveriesCount;
  final int completionPercent;
  final int hintsRemaining;
  final String rarestElementName;
  final bool canvasIsEmpty;
  final int maxDiscoveries;
  final String topHintDetail;
  final String? topHintRecipe;
  final List<String> baseIds;
  final List<String> recentIds;

  const _LabViewData({
    required this.discoveriesCount,
    required this.completionPercent,
    required this.hintsRemaining,
    required this.rarestElementName,
    required this.canvasIsEmpty,
    required this.maxDiscoveries,
    required this.topHintDetail,
    required this.topHintRecipe,
    required this.baseIds,
    required this.recentIds,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _LabViewData &&
            discoveriesCount == other.discoveriesCount &&
            completionPercent == other.completionPercent &&
            hintsRemaining == other.hintsRemaining &&
            rarestElementName == other.rarestElementName &&
            canvasIsEmpty == other.canvasIsEmpty &&
            maxDiscoveries == other.maxDiscoveries &&
            topHintDetail == other.topHintDetail &&
            topHintRecipe == other.topHintRecipe &&
            listEquals(baseIds, other.baseIds) &&
            listEquals(recentIds, other.recentIds);
  }

  @override
  int get hashCode => Object.hash(
    discoveriesCount,
    completionPercent,
    hintsRemaining,
    rarestElementName,
    canvasIsEmpty,
    maxDiscoveries,
    topHintDetail,
    topHintRecipe,
    Object.hashAll(baseIds),
    Object.hashAll(recentIds),
  );
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String headline;
  final String body;
  final String footer;
  final bool dark;

  const _InfoCard({
    required this.title,
    required this.headline,
    required this.body,
    required this.footer,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = dark
        ? const Color(0xFF2E241A)
        : Colors.white.withValues(alpha: 0.7);
    final primaryText = dark ? Colors.white : const Color(0xFF2E241A);
    final secondaryText = dark
        ? const Color(0xFFE7D8C4)
        : const Color(0xFF6B523D);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: dark ? const Color(0xFFB89672) : const Color(0xFFD7B78E),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryText,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            headline,
            style: theme.textTheme.titleLarge?.copyWith(
              color: primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            footer,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: dark ? const Color(0xFFF1C27D) : const Color(0xFF8A4F2B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String sublabel;

  const _StatCard({
    required this.value,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 156,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8EDDD),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD7B78E), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 38,
              color: const Color(0xFF8A4F2B),
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF2E241A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sublabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7A5D42),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasized;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: emphasized
            ? const Color(0xFFF0DFC8)
            : Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: emphasized ? const Color(0xFFD79C55) : const Color(0xFFD7B78E),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8A4F2B)),
          const SizedBox(height: 10),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7A5D42),
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF2E241A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
