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
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: Colors.white10),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Emoji Alchemy",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => controller.clearCanvas(),
                icon: const Icon(Icons.refresh, color: Colors.white70),
                tooltip: "Clear Canvas",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Discovered: $discoveredCount/$total",
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          HSLColor.fromAHSL(1.0, (progress * 120), 0.7, 0.5).toColor(),
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _HintButton(controller: controller),
            ],
          ),
        ],
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
