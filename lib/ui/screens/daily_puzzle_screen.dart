import 'package:flutter/material.dart';

class DailyPuzzleScreen extends StatelessWidget {
  const DailyPuzzleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text('DAY 142', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                  ),
                  const Spacer(),
                  Text(
                    '04:32',
                    style: theme.textTheme.titleLarge?.copyWith(color: accent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFB89672), width: 1.4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'REACH THIS EMOJI',
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFD2B692), letterSpacing: 1.4),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Column(
                        children: [
                          const Text('🚂', style: TextStyle(fontSize: 72)),
                          const SizedBox(height: 16),
                          Text('Steam Train', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 26)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Starting Elements',
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFD2B692), letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        _ElementCard(icon: '🔥', label: 'Fire'),
                        _ElementCard(icon: '💧', label: 'Water'),
                        _ElementCard(icon: '🌍', label: 'Earth'),
                        _ElementCard(icon: '🪵', label: 'Wood'),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Progress — 3 of 6 steps',
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFFD8C3A5)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!'))
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text('CONTINUE IN LAB', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ElementCard extends StatelessWidget {
  final String icon;
  final String label;

  const _ElementCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7B78E), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
