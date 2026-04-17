import 'package:flutter_test/flutter_test.dart';

import 'package:emoji_alchemy/logic/recipe_manager.dart';

void main() {
  group('RecipeManager.combine', () {
    test('builds a large exact recipe map', () {
      expect(RecipeManager.allRecipes.length, greaterThanOrEqualTo(10000));
      expect(RecipeManager.allRecipeResults.length, greaterThanOrEqualTo(120));
    });

    test('keeps existing exact recipes working', () {
      expect(RecipeManager.combine('🔥', '💧'), '🌫️');
      expect(RecipeManager.combine('💧', '🔥'), '🌫️');
    });

    test('uses newly added explicit recipes', () {
      expect(RecipeManager.combine('🌊', '🌍'), '🏝️');
      expect(RecipeManager.combine('🌳', '🪓'), '🪵');
      expect(RecipeManager.combine('💻', '📱'), '📲');
      expect(RecipeManager.combine('🪄', '💎'), '👑');
    });

    test('generates exact recipes across the wider emoji catalog', () {
      final lionBatteryPair = ['🦁', '🔋']..sort();

      expect(RecipeManager.combine('🦁', '🔋'), isNotNull);
      expect(RecipeManager.combine('🎂', '🛸'), isNotNull);
      expect(RecipeManager.combine('🧱', '🎵'), isNotNull);
      expect(
        RecipeManager.allRecipes.containsKey(lionBatteryPair.join(',')),
        isTrue,
      );
    });
  });
}
