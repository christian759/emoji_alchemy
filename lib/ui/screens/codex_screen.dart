import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/element_data.dart';
import '../../models/element_category.dart';
import '../../providers/game_state.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/emoji_bubble.dart';

class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  ElementCategory? selectedCategory;

  final List<Map<String, dynamic>> _filters = [
    {'label': 'All', 'category': null},
    {'label': 'Nature', 'category': ElementCategory.nature},
    {'label': 'Tech', 'category': ElementCategory.technology},
    {'label': 'Magic', 'category': ElementCategory.magic},
    {'label': 'Space', 'category': ElementCategory.space},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Codex', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          final discovered = gameState.discoveredElementList
              .where((element) => selectedCategory == null || element.category == selectedCategory)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All',
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7A5D42), letterSpacing: 1.5),
                    ),
                    Text(
                      '${gameState.discoveriesCount} / ${gameState.maxDiscoveries}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _filters.map((filter) {
                    final isSelected = selectedCategory == filter['category'];
                    return ChoiceChip(
                      label: Text(filter['label']),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.secondary.withOpacity(0.16),
                      backgroundColor: theme.canvasColor,
                      labelStyle: TextStyle(
                        color: isSelected ? theme.colorScheme.secondary : const Color(0xFF5E4A3D),
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = filter['category'];
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: discovered.isEmpty
                      ? Center(
                          child: Text(
                            'No discoveries yet in this category.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF7A5D42)),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : GridView.count(
                          crossAxisCount: 3,
                          childAspectRatio: 0.88,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          children: discovered.map((element) {
                            return Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: theme.dividerColor, width: 1.2),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  EmojiBubble(element: element, size: 72),
                                  const SizedBox(height: 12),
                                  Text(
                                    element.name,
                                    style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFF2E7D6)),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
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
