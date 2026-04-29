import 'package:flutter/material.dart';

class DailyPuzzleScreen extends StatelessWidget {
  const DailyPuzzleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Puzzle'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'TODAY\'S TARGET',
              style: TextStyle(color: Colors.white54, letterSpacing: 2),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
              ),
              child: const Text('🐉', style: TextStyle(fontSize: 80)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dragon',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const Text(
              'Reach the target using only these ingredients:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🔥', style: TextStyle(fontSize: 40)),
                SizedBox(width: 8),
                Text('💧', style: TextStyle(fontSize: 40)),
                SizedBox(width: 8),
                Text('🌍', style: TextStyle(fontSize: 40)),
                SizedBox(width: 8),
                Text('💨', style: TextStyle(fontSize: 40)),
                SizedBox(width: 8),
                Text('🌱', style: TextStyle(fontSize: 40)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Future Implementation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!'))
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('START PUZZLE', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
