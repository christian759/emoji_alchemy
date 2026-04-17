import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/game_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Stack(
        children: [
          // Background Elements
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Center(
                child: Wrap(
                  spacing: 40,
                  runSpacing: 40,
                  children: ["🔥", "💧", "🌍", "💨", "🧬", "🧪", "🪄", "🤖", "🐉", "🚀"]
                      .map((e) => Text(e, style: const TextStyle(fontSize: 64)))
                      .toList(),
                ),
              ).animate(onPlay: (c) => c.repeat()).rotate(duration: 60.seconds),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    "EMOJI",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                  Text(
                    "ALCHEMY",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.purpleAccent,
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2),
                  
                  const Spacer(),
                  
                  _ModeButton(
                    title: "SANDBOX",
                    subtitle: "Unleash infinite creativity",
                    color: Colors.blueAccent,
                    onTap: () {
                      controller.setMode(GameMode.sandbox);
                      Navigator.pushReplacementNamed(context, '/game');
                    },
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
                  
                  const SizedBox(height: 20),
                  
                  _ModeButton(
                    title: "ADVENTURE",
                    subtitle: "Discover from the 4 elements",
                    color: Colors.greenAccent,
                    onTap: () {
                      controller.setMode(GameMode.adventure);
                      Navigator.pushReplacementNamed(context, '/game');
                    },
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
                  
                  const SizedBox(height: 20),
                  
                  _ModeButton(
                    title: "CHALLENGE",
                    subtitle: "Solve the cryptic riddles",
                    color: Colors.purpleAccent,
                    onTap: () {
                      controller.setMode(GameMode.challenge);
                      Navigator.pushReplacementNamed(context, '/game');
                    },
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2),
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF16161C),
          borderRadius: BorderRadius.circular(20),
          border: Border(
            bottom: BorderSide(color: color.withOpacity(0.5), width: 6),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.play_arrow_rounded, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
