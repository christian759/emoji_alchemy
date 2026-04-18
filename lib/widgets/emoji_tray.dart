import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/game_controller.dart';
import '../logic/recipe_manager.dart';

class EmojiTray extends StatefulWidget {
  final double maxHeight;

  const EmojiTray({Key? key, this.maxHeight = 434}) : super(key: key);

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
    FocusManager.instance.primaryFocus?.unfocus();
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
    final media = MediaQuery.of(context);
    final keyboardVisible = media.viewInsets.bottom > 0;
    final categories = ['All', ...RecipeManager.categories.keys];
    final discovered = controller.filteredInventory;
    const peekBarHeight = 64.0;
    const preferredExpandedHeight = 370.0;
    const preferredExpandedHeightWithKeyboard = 230.0;
    const minExpandedHeight = 132.0;
    final targetExpandedHeight = keyboardVisible
        ? preferredExpandedHeightWithKeyboard
        : preferredExpandedHeight;
    final availableForExpanded = math.max(
      0.0,
      widget.maxHeight - peekBarHeight,
    );
    final expandedHeight = math.min(targetExpandedHeight, availableForExpanded);
    final canExpand = expandedHeight >= minExpandedHeight;

    if (!canExpand && _expanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_expanded) return;
        setState(() => _expanded = false);
        _animController.reverse();
      });
    }

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF13131A),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Peek bar (always visible) ──────────────────────
            GestureDetector(
              onTap: canExpand ? _toggle : null,
              onVerticalDragUpdate: (d) {
                if (!canExpand) return;
                if (d.delta.dy < -6 && !_expanded) _toggle();
                if (d.delta.dy > 6 && _expanded) _toggle();
              },
              child: SizedBox(
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      AnimatedRotation(
                        turns: canExpand && _expanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: canExpand ? Colors.white38 : Colors.white12,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PeekEmojis(emojis: discovered.take(8).toList()),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
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
            ),

            // ── Slide-up grid ──────────────────────────────────
            if (canExpand)
              SizeTransition(
                sizeFactor: _sizeFactor,
                child: SizedBox(
                  height: expandedHeight,
                  child: _TrayGrid(
                    controller: controller,
                    categories: categories,
                    discovered: discovered,
                  ),
                ),
              ),
          ],
        ),
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
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemCount: emojis.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final emoji = emojis[index];
        return Draggable<String>(
          data: emoji,
          feedback: Material(
            color: Colors.transparent,
            child: Text(emoji, style: const TextStyle(fontSize: 42)),
          ),
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              controller.addEmojiFromTray(emoji);
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 52)
            .floor()
            .clamp(4, 8)
            .toInt();

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
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: const InputDecoration(
                    hintText: 'Search elements...',
                    hintStyle: TextStyle(color: Colors.white24),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white24,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),

            // Category chips
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final selected = controller.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        controller.setCategory(cat);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
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
                                  ),
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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
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
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        controller.addEmojiFromTray(emoji);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2A),
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                            bottom: BorderSide(
                              color: Color(0xFF0A0A10),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
