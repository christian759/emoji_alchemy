import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/game_state.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // App Title
                  Text(
                    'Emoji Alchemy',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                  const SizedBox(height: 16),
                  
                  // Rank Badge
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Current Rank',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gameState.currentRank,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 40),
                  
                  // Discovery Progress
                  Text(
                    'Discoveries',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: gameState.discoveriesCount / gameState.maxDiscoveries,
                    backgroundColor: Colors.white12,
                    color: Theme.of(context).primaryColor,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${gameState.discoveriesCount} / ${gameState.maxDiscoveries} Elements Found',
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  
                  const Spacer(),
                  
                  // Play Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GameScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'ENTER LAB',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scaleXY(end: 1.05, duration: 1.seconds, curve: Curves.easeInOut),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
