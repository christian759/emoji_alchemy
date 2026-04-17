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
      color: const Color(0xFF0F0F12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emoji Alchemy",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    controller.currentMode.name.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      letterSpacing: 1.5,
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showModePicker(context, controller),
                    icon: const Icon(Icons.tune, color: Colors.white70),
                    tooltip: "Change Mode",
                  ),
                  IconButton(
                    onPressed: () => controller.clearCanvas(),
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    tooltip: "Clear Canvas",
                  ),
                ],
              ),
            ],
          ),
          if (controller.currentMode == GameMode.challenge) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "FIND THE RECIPE: ",
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.challengeTarget ?? "?",
                    style: const TextStyle(fontSize: 32),
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
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Game Mode",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _ModeTile(
                title: "Sandbox",
                subtitle: "Unlimited creativity. Everything is unlocked.",
                icon: Icons.auto_awesome,
                selected: controller.currentMode == GameMode.sandbox,
                onTap: () {
                  controller.setMode(GameMode.sandbox);
                  Navigator.pop(context);
                },
              ),
              _ModeTile(
                title: "Adventure",
                subtitle: "Standard discovery. Start from nothing.",
                icon: Icons.explore,
                selected: controller.currentMode == GameMode.adventure,
                onTap: () {
                  controller.setMode(GameMode.adventure);
                  Navigator.pop(context);
                },
              ),
              _ModeTile(
                title: "Challenge",
                subtitle: "The ultimate test. Form the target emoji.",
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
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: selected ? Colors.purpleAccent : Colors.white30),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white30, fontSize: 12)),
      trailing: selected ? const Icon(Icons.check_circle, color: Colors.purpleAccent) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: selected ? Colors.purple.withOpacity(0.1) : Colors.transparent,
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
