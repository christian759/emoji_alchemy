import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String name;
  final String emoji;
  final String description;

  const Achievement({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
  });
}

class AchievementManager {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_spark',
      name: 'First Spark',
      emoji: '🔥',
      description: 'Make your very first combination',
    ),
    Achievement(
      id: 'first_discovery',
      name: 'Alchemist Awakens',
      emoji: '✨',
      description: 'Discover a brand new element for the first time',
    ),
    Achievement(
      id: 'chain_3',
      name: 'Chain Reaction',
      emoji: '⚡',
      description: 'Land 3 combos in a row',
    ),
    Achievement(
      id: 'chain_5',
      name: 'Unstoppable',
      emoji: '🌊',
      description: 'Land 5 combos in a row',
    ),
    Achievement(
      id: 'chain_10',
      name: 'Combo God',
      emoji: '👑',
      description: 'Land 10 combos in a row',
    ),
    Achievement(
      id: 'level_5',
      name: 'Apprentice',
      emoji: '🧪',
      description: 'Reach Level 5',
    ),
    Achievement(
      id: 'level_10',
      name: 'Journeyman',
      emoji: '🧙',
      description: 'Reach Level 10',
    ),
    Achievement(
      id: 'level_20',
      name: 'Grand Master',
      emoji: '🧙‍♂️',
      description: 'Reach Level 20',
    ),
    Achievement(
      id: 'discoveries_10',
      name: 'Explorer',
      emoji: '🗺️',
      description: 'Discover 10 unique elements',
    ),
    Achievement(
      id: 'discoveries_50',
      name: 'Scholar',
      emoji: '📚',
      description: 'Discover 50 unique elements',
    ),
    Achievement(
      id: 'discoveries_100',
      name: 'Century',
      emoji: '🏆',
      description: 'Discover 100 unique elements',
    ),
    Achievement(
      id: 'dragon',
      name: 'Dragon Tamer',
      emoji: '🐉',
      description: 'Discover the mighty Dragon',
    ),
    Achievement(
      id: 'robot',
      name: 'Singularity',
      emoji: '🤖',
      description: 'Birth artificial intelligence',
    ),
    Achievement(
      id: 'challenge_win',
      name: 'Riddle Solver',
      emoji: '🔮',
      description: 'Solve a Challenge puzzle',
    ),
  ];

  /// Checks all achievements and awards the first newly-earned one.
  /// Mutates [unlocked] in-place and persists to SharedPreferences.
  static Future<Achievement?> checkAndAward({
    required Set<String> unlocked,
    required int totalCombines,
    required int comboCount,
    required int level,
    required int discoveries,
    required Set<String> discoveredEmojis,
    required bool justDiscoveredNew,
    required bool justCompletedChallenge,
  }) async {
    for (final achievement in all) {
      if (unlocked.contains(achievement.id)) continue;

      bool earned = false;
      switch (achievement.id) {
        case 'first_spark':
          earned = totalCombines >= 1;
          break;
        case 'first_discovery':
          earned = justDiscoveredNew;
          break;
        case 'chain_3':
          earned = comboCount >= 3;
          break;
        case 'chain_5':
          earned = comboCount >= 5;
          break;
        case 'chain_10':
          earned = comboCount >= 10;
          break;
        case 'level_5':
          earned = level >= 5;
          break;
        case 'level_10':
          earned = level >= 10;
          break;
        case 'level_20':
          earned = level >= 20;
          break;
        case 'discoveries_10':
          earned = discoveries >= 10;
          break;
        case 'discoveries_50':
          earned = discoveries >= 50;
          break;
        case 'discoveries_100':
          earned = discoveries >= 100;
          break;
        case 'dragon':
          earned = discoveredEmojis.contains('🐉');
          break;
        case 'robot':
          earned = discoveredEmojis.contains('🤖');
          break;
        case 'challenge_win':
          earned = justCompletedChallenge;
          break;
      }

      if (earned) {
        unlocked.add(achievement.id);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('achievements', unlocked.toList());
        return achievement;
      }
    }
    return null;
  }
}
