import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/game_controller.dart';
import '../logic/recipe_manager.dart';

class HudHeader extends StatelessWidget {
  const HudHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _HudButton(
                  icon: Icons.home_rounded,
                  onTap: () => Navigator.pushReplacementNamed(context, '/'),
                ),
                const SizedBox(width: 8),
                Expanded(child: _XpBar(controller: controller)),
                const SizedBox(width: 8),
                _ScoreBadge(controller: controller),
                const SizedBox(width: 8),
                _HudButton(
                  icon: Icons.settings_rounded,
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
                const SizedBox(width: 8),
                _HudButton(
                  icon: Icons.refresh_rounded,
                  onTap: controller.clearCanvas,
                  danger: true,
                ),
              ],
            ),
            if (controller.currentMode == GameMode.challenge &&
                !controller.challengeTimedOut) ...[
              const SizedBox(height: 8),
              _ChallengeBar(controller: controller),
            ],
          ],
        ),
      ),
    );
  }
}

// ── XP Bar ────────────────────────────────────────────────────

class _XpBar extends StatelessWidget {
  final GameController controller;
  const _XpBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFAA00), Color(0xFFFF6600)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.orange.withOpacity(0.4), blurRadius: 6),
              ],
            ),
            child: Text(
              'LVL ${controller.level}',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // XP progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: controller.xpProgress,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      controller.level >= 20
                          ? Colors.amber
                          : Colors.purpleAccent,
                    ),
                    minHeight: 7,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${controller.xp} / ${controller.xpForLevel(controller.level)} XP',
                  style: GoogleFonts.outfit(
                      color: Colors.white30, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Score Badge ──────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  final GameController controller;
  const _ScoreBadge({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SCORE',
            style: GoogleFonts.outfit(
              color: Colors.white30,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          Text(
            controller.score.toString(),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Challenge Bar ─────────────────────────────────────────────

class _ChallengeBar extends StatelessWidget {
  final GameController controller;
  const _ChallengeBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final timeLeft = controller.challengeTimeLeft;
    final isUrgent = timeLeft <= 10;
    final progress = (timeLeft / 90).clamp(0.0, 1.0);
    final clue = RecipeManager.clues[controller.challengeTarget] ??
        'Find the mystery combination!';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? Colors.red.withOpacity(0.6)
              : Colors.purpleAccent.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '"$clue"',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? Colors.red.withOpacity(0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: isUrgent ? Colors.red : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_rounded,
                        size: 13,
                        color: isUrgent ? Colors.red : Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      '${timeLeft}s',
                      style: GoogleFonts.outfit(
                        color: isUrgent ? Colors.red : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${controller.challengeScore} pts',
                style: GoogleFonts.outfit(
                  color: Colors.amber,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUrgent ? Colors.red : Colors.greenAccent,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Icon Button ───────────────────────────────────────────────

class _HudButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const _HudButton({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: danger
              ? Colors.red.withOpacity(0.14)
              : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                danger ? Colors.redAccent.withOpacity(0.4) : Colors.white12,
          ),
        ),
        child: Icon(
          icon,
          color: danger ? Colors.redAccent : Colors.white70,
          size: 20,
        ),
      ),
    );
  }
}
