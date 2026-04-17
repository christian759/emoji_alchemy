import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/game_controller.dart';
import '../logic/recipe_manager.dart';

class EmojiTray extends StatefulWidget {
  const EmojiTray({Key? key}) : super(key: key);

  @override
  State<EmojiTray> createState() => _EmojiTrayState();
}

class _EmojiTrayState extends State<EmojiTray>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animController;
  late Animation<double> _sizeFactor;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _sizeFactor = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final categories = ['All', ...RecipeManager.categories.keys];
    final discovered = controller.filteredInventory;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13131A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Peek bar (always visible) ──────────────────────
          GestureDetector(
            onTap: _toggle,
            onVerticalDragUpdate: (d) {
              if (d.delta.dy < -6 && !_expanded) _toggle();
              if (d.delta.dy > 6 && _expanded) _toggle();
            },
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.white38,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PeekEmojis(emojis: discovered.take(8).toList()),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${discovered.length}',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Slide-up grid ──────────────────────────────────
          SizeTransition(
            sizeFactor: _sizeFactor,
            child: SizedBox(
              height: 370,
              child: _TrayGrid(
                controller: controller,
                categories: categories,
                discovered: discovered,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Peek emoji row ─────────────────────────────────────────────

class _PeekEmojis extends StatelessWidget {
  final List<String> emojis;
  const _PeekEmojis({required this.emojis});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameController>();
    return Row(
      children: emojis
          .map(
            (emoji) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Draggable<String>(
                data: emoji,
                feedback: Material(
                  color: Colors.transparent,
                  child: Text(emoji, style: const TextStyle(fontSize: 42)),
                ),
                child: GestureDetector(
                  onTap: () =>
                      controller.addEmojiToCanvas(emoji, const Offset(160, 260)),
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Expanded tray grid ────────────────────────────────────────

class _TrayGrid extends StatelessWidget {
  final GameController controller;
  final List<String> categories;
  final List<String> discovered;

  const _TrayGrid({
    required this.controller,
    required this.categories,
    required this.discovered,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: TextField(
              onChanged: controller.setSearchQuery,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search elements...',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                prefixIcon:
                    Icon(Icons.search, color: Colors.white24, size: 18),
              ),
            ),
          ),
        ),

        // Category chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final cat = categories[i];
              final selected = controller.selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => controller.setCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.purpleAccent
                          : Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.3),
                                blurRadius: 8,
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.outfit(
                        color: selected ? Colors.white : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Emoji grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: discovered.length,
            itemBuilder: (context, i) {
              final emoji = discovered[i];
              return Draggable<String>(
                data: emoji,
                feedback: Material(
                  color: Colors.transparent,
                  child: Text(emoji, style: const TextStyle(fontSize: 42)),
                ),
                childWhenDragging: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => controller.addEmojiToCanvas(
                      emoji, const Offset(160, 260)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2A),
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        bottom:
                            BorderSide(color: Color(0xFF0A0A10), width: 2),
                      ),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
