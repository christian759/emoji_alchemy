import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/game_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "SETTINGS",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SettingsSection(
            title: "PREFERENCES",
            children: [
              _SettingsToggle(
                title: "Vibration",
                subtitle: "Tactile haptic feedback",
                value: controller.vibrationEnabled,
                onChanged: (v) => controller.toggleVibration(),
                icon: Icons.vibration_rounded,
                activeColor: Colors.purpleAccent,
              ),
            ],
          ),
          const SizedBox(height: 32),
          _SettingsSection(
            title: "DATA MANAGEMENT",
            children: [
              _SettingsAction(
                title: "Reset Progress",
                subtitle: "Wipe all discovered emojis",
                onTap: () => _confirmReset(context, controller),
                icon: Icons.refresh_rounded,
                color: Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Text(
                  "EMOJI ALCHEMY",
                  style: GoogleFonts.outfit(
                    color: Colors.white24,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const Text(
                  "Version 2.0.0 (Pro)",
                  style: TextStyle(color: Colors.white10, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16161C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "WIPE PROGRESS?",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          "This will reset all your discoveries and the canvas. This action cannot be undone.",
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              controller.resetProgress();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text("RESET EVERYTHING", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white24,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16161C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final IconData icon;
  final Color activeColor;

  const _SettingsToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: activeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: activeColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        activeTrackColor: activeColor.withOpacity(0.3),
      ),
    );
  }
}

class _SettingsAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  const _SettingsAction({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white12),
    );
  }
}
