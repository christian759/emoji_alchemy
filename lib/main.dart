import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/game_state.dart';
import 'theme/app_theme.dart';
import 'ui/screens/codex_screen.dart';
import 'ui/screens/daily_puzzle_screen.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/hint_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(EmojiAlchemyApp(prefs: prefs));
}

class EmojiAlchemyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const EmojiAlchemyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(prefs),
      child: MaterialApp(
        title: 'Emoji Alchemy',
        theme: AppTheme.parchmentTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/lab': (_) => const GameScreen(),
          '/codex': (_) => const CodexScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/daily': (_) => const DailyPuzzleScreen(),
          '/hints': (_) => const HintScreen(),
        },
      ),
    );
  }
}
