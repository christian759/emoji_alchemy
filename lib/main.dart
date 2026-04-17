import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logic/game_controller.dart';
import 'logic/ad_manager.dart';
import 'widgets/play_area.dart';
import 'widgets/hud_header.dart';
import 'widgets/emoji_tray.dart';
import 'widgets/combo_display.dart';
import 'widgets/level_up_overlay.dart';
import 'widgets/achievement_overlay.dart';
import 'widgets/new_discovery_overlay.dart';
import 'screens/mode_select_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdManager.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameController(),
      child: const EmojiAlchemyApp(),
    ),
  );
}

class EmojiAlchemyApp extends StatelessWidget {
  const EmojiAlchemyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Alchemy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D14),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ModeSelectScreen(),
        '/game': (context) => const GameScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

// ── Game Screen ───────────────────────────────────────────────

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.purpleAccent),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen play area + bottom tray ────────────
          Column(
            children: const [
              Expanded(child: PlayArea()),
              EmojiTray(),
            ],
          ),

          // ── HUD overlay pinned to top ──────────────────────
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HudHeader(),
          ),

          // ── Combo badge (floats over play area) ────────────
          const ComboDisplay(),

          // ── Level-up full-screen overlay ───────────────────
          const LevelUpOverlay(),

          // ── Achievement toast ──────────────────────────────
          const AchievementOverlay(),

          // ── New discovery overlay ──────────────────────────
          if (controller.lastDiscoveredEmoji != null)
            NewDiscoveryOverlay(
              emoji: controller.lastDiscoveredEmoji!,
              onDismiss: () => controller.clearLastDiscovered(),
            ),

          // ── Challenge time's-up overlay ────────────────────
          if (controller.currentMode == GameMode.challenge &&
              controller.challengeTimedOut)
            const _TimeUpOverlay(),
        ],
      ),
    );
  }
}

// ── Time-up overlay ───────────────────────────────────────────

class _TimeUpOverlay extends StatelessWidget {
  const _TimeUpOverlay();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.92),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: const Color(0xFF180A2E),
              borderRadius: BorderRadius.circular(32),
              border:
                  Border.all(color: Colors.redAccent.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 48,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⏰', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text(
                  "TIME'S UP!",
                  style: GoogleFonts.outfit(
                    color: Colors.redAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 20),

                // Score row
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ResultStat(
                        label: 'SCORE',
                        value: '${controller.challengeScore}',
                      ),
                      Container(
                          width: 1, height: 40, color: Colors.white10),
                      _ResultStat(
                        label: 'BEST',
                        value: '${controller.challengeHighScore}',
                        highlight: controller.challengeScore >=
                            controller.challengeHighScore &&
                            controller.challengeScore > 0,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                _BigButton(
                  label: '🔄  PLAY AGAIN',
                  color: Colors.purpleAccent,
                  onTap: () => controller.restartChallenge(),
                ),
                const SizedBox(height: 12),
                _BigButton(
                  label: '🏠  MAIN MENU',
                  color: const Color(0xFF252535),
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ResultStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: highlight ? Colors.amber : Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (highlight)
          Text(
            '🏆 NEW BEST!',
            style: GoogleFonts.outfit(
              color: Colors.amber,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BigButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
