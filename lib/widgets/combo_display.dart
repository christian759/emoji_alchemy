import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';

class ComboDisplay extends StatelessWidget {
  const ComboDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final combo = controller.comboCount;

    if (combo < 2) return const SizedBox.shrink();

    final multiplier = controller.comboMultiplier;
    final List<Color> gradientColors = combo >= 10
        ? [const Color(0xFF9B59B6), const Color(0xFFE91E63)]
        : combo >= 5
            ? [const Color(0xFFFF6B00), const Color(0xFFFF0055)]
            : [const Color(0xFFFFAA00), const Color(0xFFFF6600)];

    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withOpacity(0.55),
                blurRadius: 24,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'x$combo COMBO!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  letterSpacing: 0.5,
                ),
              ),
              if (multiplier > 1) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${multiplier}x XP',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        )
            .animate(key: ValueKey(combo))
            .scale(
              duration: 380.ms,
              curve: Curves.elasticOut,
              begin: const Offset(0.4, 0.4),
            )
            .fadeIn(duration: 200.ms),
      ),
    );
  }
}
