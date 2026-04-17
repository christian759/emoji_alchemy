import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';

class LevelUpOverlay extends StatefulWidget {
  const LevelUpOverlay({Key? key}) : super(key: key);

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay> {
  bool _scheduled = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    if (!controller.leveledUp) {
      _scheduled = false;
      return const SizedBox.shrink();
    }

    if (!_scheduled) {
      _scheduled = true;
      Future.delayed(const Duration(milliseconds: 2400), () {
        if (mounted) context.read<GameController>().clearLevelUp();
      });
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => context.read<GameController>().clearLevelUp(),
        child: Container(
          color: Colors.black.withOpacity(0.78),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '✨  LEVEL UP!  ✨',
                style: GoogleFonts.outfit(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.4, end: 0),
              const SizedBox(height: 28),
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.shade300,
                      Colors.orange.shade800,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.65),
                      blurRadius: 70,
                      spreadRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${controller.level}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      shadows: const [
                        Shadow(color: Colors.black26, blurRadius: 8)
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    duration: 750.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.1, 0.1),
                  )
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 32),
              Text(
                'TAP TO CONTINUE',
                style: GoogleFonts.outfit(
                  color: Colors.white30,
                  fontSize: 12,
                  letterSpacing: 2.5,
                ),
              ).animate().fadeIn(delay: 1400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
