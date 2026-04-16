import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logic/game_controller.dart';
import 'logic/ad_manager.dart';
import 'widgets/play_area.dart';
import 'widgets/inventory_bar.dart';
import 'widgets/progress_header.dart';

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
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<GameController, bool>((c) => c.isLoading);

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.purpleAccent),
        ),
      );
    }

    return const Scaffold(
      body: Column(
        children: [
          ProgressHeader(),
          Expanded(
            child: PlayArea(),
          ),
          InventoryBar(),
        ],
      ),
    );
  }
}
