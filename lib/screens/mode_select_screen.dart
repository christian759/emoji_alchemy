import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/game_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: Stack(
        children: [
          // Rotating emoji backdrop
          Positioned.fill(
            child: Opacity(
              opacity: 0.07,
              child: Center(
                child: Wrap(
                  spacing: 48,
                  runSpacing: 48,
                  children: [
                    '🔥', '💧', '🌍', '💨', '🧬', '🧪',
                    '🪄', '🤖', '🐉', '🚀', '⚡', '🌊',
                  ]
                      .map((e) =>
                          Text(e, style: const TextStyle(fontSize: 64)))
                      .toList(),
                ),
              ).animate(onPlay: (c) => c.repeat()).rotate(duration: 90.seconds),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),

                  // Title
                  Text(
                    'EMOJI',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                  Text(
                    'ALCHEMY',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.purpleAccent,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // Player stats row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatChip(
                          label: 'LEVEL',
                          value: '${controller.level}',
                          emoji: '⚡',
                        ),
                        _StatDivider(),
                        _StatChip(
                          label: 'DISCOVERED',
                          value: '${controller.discoveredEmojis.length}',
                          emoji: '🔬',
                        ),
                        _StatDivider(),
                        _StatChip(
                          label: 'HIGH SCORE',
                          value: '${controller.highScore}',
                          emoji: '🏆',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 350.ms),

                  const Spacer(),

                  // Mode buttons
                  _ModeButton(
                    icon: '🏖️',
                    title: 'SANDBOX',
                    subtitle: 'Unlimited creativity — combine anything',
                    color: Colors.blueAccent,
                    onTap: () {
                      controller.setMode(GameMode.sandbox);
                      Navigator.pushReplacementNamed(context, '/game');
                    },
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),

                  const SizedBox(height: 14),

                  _ModeButton(
                    icon: '🗺️',
                    title: 'ADVENTURE',
                    subtitle: 'Discover elements from 4 seeds',
                    color: Colors.greenAccent,
                    onTap: () {
                      controller.setMode(GameMode.adventure);
                      Navigator.pushReplacementNamed(context, '/game');
                    },
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2),

                  const SizedBox(height: 14),

                  _ModeButton(
                    icon: '🧩',
                    title: 'CHALLENGE',
                    subtitle: 'Solve cryptic riddles against the clock',
                    color: Colors.purpleAccent,
                    onTap: () {
                      controller.setMode(GameMode.challenge);
                      Navigator.pushReplacementNamed(context, '/game');
                    },
                  ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2),

                  const SizedBox(height: 14),

                  _ModeButton(
                    icon: '📅',
                    title: 'DAILY PUZZLE',
                    subtitle: 'A unique riddle seeded to today\'s date',
                    color: Colors.amber,
                    onTap: () {
                      controller.setDailyChallenge();
                      Navigator.pushReplacementNamed(context, '/game');
                    },
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _StatChip(
      {required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: Colors.white10);
}

// ── Mode button ───────────────────────────────────────────────

class _ModeButton extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF151520),
          borderRadius: BorderRadius.circular(20),
          border: Border(
            bottom: BorderSide(color: color.withOpacity(0.6), width: 4),
            left: BorderSide(color: color.withOpacity(0.14), width: 1),
            right: BorderSide(color: color.withOpacity(0.14), width: 1),
            top: BorderSide(color: color.withOpacity(0.08), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 26),
          ],
        ),
      ),
    );
  }
}
