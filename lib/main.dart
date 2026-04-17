import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logic/game_controller.dart';
import 'logic/ad_manager.dart';
import 'widgets/play_area.dart';
import 'widgets/inventory_bar.dart';
import 'widgets/progress_header.dart';
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
        scaffoldBackgroundColor: Colors.black,
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

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final isLoading = controller.isLoading;
    final lastDiscovered = controller.lastDiscoveredEmoji;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.purpleAccent),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Matte Dark Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0F0F12),
            ),
          ),
          Row(
            children: [
              const InventorySidebar(),
              Expanded(
                child: Column(
                  children: [
                    const ProgressHeader(),
                    const Expanded(
                      child: PlayArea(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (lastDiscovered != null)
            NewDiscoveryOverlay(
              emoji: lastDiscovered,
              onDismiss: () => controller.clearLastDiscovered(),
            ),
        ],
      ),
    );
  }
}
