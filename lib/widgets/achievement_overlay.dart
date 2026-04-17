import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../logic/achievement_manager.dart';

class AchievementOverlay extends StatefulWidget {
  const AchievementOverlay({Key? key}) : super(key: key);

  @override
  State<AchievementOverlay> createState() => _AchievementOverlayState();
}

class _AchievementOverlayState extends State<AchievementOverlay> {
  Achievement? _shown;
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final achievement = controller.newAchievement;

    if (achievement != null && achievement != _shown) {
      _shown = achievement;
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(milliseconds: 3200), () {
        if (mounted) context.read<GameController>().clearNewAchievement();
      });
    }

    if (controller.newAchievement == null) return const SizedBox.shrink();

    final a = controller.newAchievement!;
    return Positioned(
      bottom: 76,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () => context.read<GameController>().clearNewAchievement(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1020), Color(0xFF2A1550)],
            ),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.2),
                blurRadius: 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Center(
                  child:
                      Text(a.emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACHIEVEMENT UNLOCKED',
                      style: GoogleFonts.outfit(
                        color: Colors.amber,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      a.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      a.description,
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
            ],
          ),
        )
            .animate()
            .slideY(
              begin: 1.5,
              end: 0.0,
              duration: 450.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 300.ms),
      ),
    );
  }
}
