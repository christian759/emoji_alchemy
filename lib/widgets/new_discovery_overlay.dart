import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/recipe_manager.dart';

class NewDiscoveryOverlay extends StatefulWidget {
  final String emoji;
  final VoidCallback onDismiss;

  const NewDiscoveryOverlay({
    Key? key,
    required this.emoji,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<NewDiscoveryOverlay> createState() => _NewDiscoveryOverlayState();
}

class _NewDiscoveryOverlayState extends State<NewDiscoveryOverlay> {
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _autoTimer =
        Timer(const Duration(milliseconds: 3800), widget.onDismiss);
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = RecipeManager.meanings[widget.emoji];

    return Material(
      color: Colors.black.withOpacity(0.88),
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 36),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1828),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                  color: Colors.purpleAccent.withOpacity(0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.15),
                  blurRadius: 48,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '✨  NEW DISCOVERY  ✨',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.purpleAccent,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 28),

                // Emoji hero
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.purpleAccent.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: Colors.purpleAccent.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 72),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      duration: 550.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 300.ms),

                if (name != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],

                const SizedBox(height: 16),

                // XP badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.greenAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    '+ 50 XP',
                    style: GoogleFonts.outfit(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

                const SizedBox(height: 28),

                // CTA button
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purpleAccent, Color(0xFF7B2FBE)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'AWESOME!',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
