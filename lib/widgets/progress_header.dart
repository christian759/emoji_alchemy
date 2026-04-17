import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/game_controller.dart';
import '../logic/ad_manager.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final discoveredCount = controller.discoveredEmojis.length;
    final total = controller.totalPossible;
    final progress = discoveredCount / total;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      color: const Color(0xFF16161C),
      child: Column(
        children: [
          Row(
            children: [
              _GameIconButton(
                icon: Icons.home_rounded,
                color: const Color(0xFF23232D),
                onTap: () => Navigator.pushReplacementNamed(context, '/'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23232D),
                    borderRadius: BorderRadius.circular(16),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFF121217), width: 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "EMOJI ALCHEMY",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        controller.currentMode.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.purpleAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _GameIconButton(
                icon: Icons.settings_rounded,
                color: const Color(0xFF23232D),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              const SizedBox(width: 8),
              _GameIconButton(
                icon: Icons.refresh,
                color: Colors.redAccent.withOpacity(0.8),
                onTap: () => controller.clearCanvas(),
              ),
            ],
          ),
          if (controller.currentMode == GameMode.challenge) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF23232D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple.withOpacity(0.3), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    "RIDDLE:",
                    style: GoogleFonts.outfit(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "\"${RecipeManager.clues[controller.challengeTarget] ?? "Find the mystery combination!"}\"",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text("?", style: TextStyle(fontSize: 32, color: Colors.white24)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showModePicker(BuildContext context, GameController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "SELECT MODE",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _ModeTile(
                title: "SANDBOX",
                subtitle: "UNLIMITED CREATIVITY",
                icon: Icons.auto_awesome,
                selected: controller.currentMode == GameMode.sandbox,
                onTap: () {
                  controller.setMode(GameMode.sandbox);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _ModeTile(
                title: "ADVENTURE",
                subtitle: "DISCOVER THE RECIPES",
                icon: Icons.explore,
                selected: controller.currentMode == GameMode.adventure,
                onTap: () {
                  controller.setMode(GameMode.adventure);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _ModeTile(
                title: "CHALLENGE",
                subtitle: "COMPLETE THE TARGET",
                icon: Icons.psychology,
                selected: controller.currentMode == GameMode.challenge,
                onTap: () {
                  controller.setMode(GameMode.challenge);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GameIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            bottom: BorderSide(color: color.withOpacity(0.5), width: 4),
          ),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = selected ? Colors.purpleAccent : const Color(0xFF23232D);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            bottom: BorderSide(
              color: selected ? Colors.purple.shade900 : const Color(0xFF121217),
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  final GameController controller;
  const _HintButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AdManager.showRewardedAd(() {
          final hint = controller.getHint();
          if (hint != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(hint),
                backgroundColor: Colors.deepPurple,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            // If No hints (everything discovered?), unlock random emoji or something
            controller.unlockRandom();
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Bonus: Unlocked a random emoji!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.pinkAccent],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              "Hint",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
