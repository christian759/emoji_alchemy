import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/element_data.dart';
import '../../models/element_category.dart';
import '../../providers/game_state.dart';
import '../widgets/app_bottom_navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          final categories = [
            ElementCategory.nature,
            ElementCategory.technology,
            ElementCategory.magic,
            ElementCategory.space,
          ];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: theme.dividerColor, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A3726),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(child: Text('A', style: TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chris_Alch', style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFFF2E7D6))),
                          const SizedBox(height: 6),
                          Text('Sage Rank', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFFB89672))),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A382C),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text('EDIT', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatCard(title: 'FOUND', value: '${gameState.discoveriesCount}'),
                    _StatCard(title: 'COMPLETE', value: '${gameState.completionPercent}%'),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatCard(title: 'DAY STREAK', value: '${gameState.currentStreak}'),
                    _StatCard(title: 'RAREST', value: gameState.rarestElement.emoji),
                  ],
                ),
                const SizedBox(height: 22),
                Text('CATEGORY PROGRESS', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7A5D42), letterSpacing: 1.4)),
                const SizedBox(height: 16),
                ...categories.map((category) {
                  final discovered = gameState.discoveredByCategory[category] ?? 0;
                  final total = ElementData.elements.values.where((element) => element.category == category).length;
                  final percent = total == 0 ? 0.0 : discovered / total;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_categoryLabel(category), style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A3726), fontWeight: FontWeight.w600)),
                            Text('${(percent * 100).round()}%', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7A5D42))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFEEE0D2),
                            color: category == ElementCategory.nature
                                ? const Color(0xFF6A8C44)
                                : category == ElementCategory.technology
                                    ? const Color(0xFF4A6F8C)
                                    : category == ElementCategory.magic
                                        ? const Color(0xFFB06B33)
                                        : const Color(0xFF8B5B8A),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Spacer(),
                Text('THIS WEEK', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7A5D42), letterSpacing: 1.4)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: 'MTWTFSS'.split('').map((day) {
                    return Container(
                      width: 32,
                      height: 42,
                      decoration: BoxDecoration(
                        color: day == 'S' ? const Color(0xFF4A382C) : theme.canvasColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(day, style: theme.textTheme.bodyMedium?.copyWith(color: day == 'S' ? Colors.white : const Color(0xFF4A3726))),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          _navigateTo(context, index);
        },
      ),
    );
  }

  String _categoryLabel(ElementCategory category) {
    switch (category) {
      case ElementCategory.nature:
        return 'Nature';
      case ElementCategory.technology:
        return 'Technology';
      case ElementCategory.magic:
        return 'Magic';
      case ElementCategory.space:
        return 'Space';
      default:
        return category.name;
    }
  }

  void _navigateTo(BuildContext context, int index) {
    final routeNames = ['/', '/lab', '/codex', '/profile'];
    Navigator.of(context).pushReplacementNamed(routeNames[index]);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.dividerColor, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7A5D42), letterSpacing: 1.1)),
            const SizedBox(height: 10),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF3C2E24))),
          ],
        ),
      ),
    );
  }
}
