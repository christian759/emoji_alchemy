import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/emoji_element.dart';
import '../models/element_category.dart';
import '../models/placed_element.dart';
import '../data/element_data.dart';

class CombinationOutcome {
  final EmojiElement result;
  final EmojiElement ingredientA;
  final EmojiElement ingredientB;
  final bool wasNewDiscovery;

  const CombinationOutcome({
    required this.result,
    required this.ingredientA,
    required this.ingredientB,
    required this.wasNewDiscovery,
  });
}

class GameState extends ChangeNotifier {
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  Set<String> _discoveredElements = {};
  final List<PlacedElement> _canvasElements = [];
  int _hintsRemaining = 3;
  
  // Stats
  int get discoveriesCount => _discoveredElements.length;
  int get maxDiscoveries => ElementData.elements.length;
  int get hintsRemaining => _hintsRemaining;

  Set<String> get discoveredElements => _discoveredElements;
  List<PlacedElement> get canvasElements => _canvasElements;

  List<EmojiElement> get discoveredElementList {
    final list = _discoveredElements
        .map((id) => ElementData.elements[id]!)
        .toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  int get completionPercent => ((discoveriesCount / maxDiscoveries) * 100).round();

  int get currentStreak => _prefs.getInt('dayStreak') ?? 14;

  Map<ElementCategory, int> get discoveredByCategory {
    final counts = <ElementCategory, int>{};
    for (var id in _discoveredElements) {
      final element = ElementData.elements[id];
      if (element == null) continue;
      counts[element.category] = (counts[element.category] ?? 0) + 1;
    }
    return counts;
  }

  EmojiElement get rarestElement {
    if (_discoveredElements.isEmpty) {
      return ElementData.elements.values.first;
    }
    final totalByCategory = <ElementCategory, int>{};
    for (var element in ElementData.elements.values) {
      totalByCategory[element.category] = (totalByCategory[element.category] ?? 0) + 1;
    }
    final entries = discoveredElementList.toList();
    entries.sort((a, b) {
      final remainingA = (totalByCategory[a.category] ?? 0) - (discoveredByCategory[a.category] ?? 0);
      final remainingB = (totalByCategory[b.category] ?? 0) - (discoveredByCategory[b.category] ?? 0);
      if (remainingA != remainingB) {
        return remainingA.compareTo(remainingB);
      }
      return a.name.compareTo(b.name);
    });
    return entries.first;
  }

  // Ranks (Adjusted for the current dataset size)
  String get currentRank {
    if (discoveriesCount >= 40) return 'Grand Alchemist 🐉';
    if (discoveriesCount >= 30) return 'Sage 🌟';
    if (discoveriesCount >= 20) return 'Scientist 🔬';
    if (discoveriesCount >= 10) return 'Chemist ⚗️';
    return 'Apprentice 🧪';
  }

  GameState(this._prefs) {
    _loadProgress();
  }

  void _loadProgress() {
    final saved = _prefs.getStringList('discoveredElements');
    if (saved != null && saved.isNotEmpty) {
      _discoveredElements = saved.toSet();
    } else {
      // Default unlocked base elements
      _discoveredElements = ElementData.elements.values
          .where((e) => e.isBase)
          .map((e) => e.id)
          .toSet();
      _saveProgress();
    }
    _hintsRemaining = _prefs.getInt('hintsRemaining') ?? 3;
    notifyListeners();
  }

  void _saveProgress() {
    _prefs.setStringList('discoveredElements', _discoveredElements.toList());
    _prefs.setInt('hintsRemaining', _hintsRemaining);
  }

  void resetProgress() {
    _discoveredElements.clear();
    _canvasElements.clear();
    _loadProgress(); // Reloads base elements
  }

  void clearCanvas() {
    _canvasElements.clear();
    notifyListeners();
  }

  void addToCanvas(EmojiElement element, double x, double y) {
    _canvasElements.add(PlacedElement(
      id: _uuid.v4(),
      element: element,
      x: x,
      y: y,
    ));
    notifyListeners();
  }

  void updateElementPosition(String topId, double x, double y) {
    var index = _canvasElements.indexWhere((e) => e.id == topId);
    if (index != -1) {
      _canvasElements[index].x = x;
      _canvasElements[index].y = y;
      notifyListeners();
    }
  }

  void removeElement(String id) {
    _canvasElements.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void consumeHint() {
    if (_hintsRemaining <= 0) return;
    _hintsRemaining--;
    _saveProgress();
    notifyListeners();
  }

  List<String> get hintSuggestions {
    final suggestions = <String>[];
    final discovered = _discoveredElements;

    final candidateCombos = ElementData.combinations.where((combo) {
      final result = ElementData.elements[combo.result];
      if (result == null || discovered.contains(result.id)) return false;
      final hasOne = discovered.contains(combo.element1);
      final hasTwo = discovered.contains(combo.element2);
      return hasOne || hasTwo;
    }).toList();

    candidateCombos.sort((a, b) {
      final matchA = (discovered.contains(a.element1) ? 1 : 0) + (discovered.contains(a.element2) ? 1 : 0);
      final matchB = (discovered.contains(b.element1) ? 1 : 0) + (discovered.contains(b.element2) ? 1 : 0);
      return matchB.compareTo(matchA);
    });

    for (var combo in candidateCombos.take(5)) {
      final result = ElementData.elements[combo.result]!;
      final element1 = ElementData.elements[combo.element1]!;
      final element2 = ElementData.elements[combo.element2]!;
      final hasOne = discovered.contains(combo.element1);
      final hasTwo = discovered.contains(combo.element2);

      if (hasOne && hasTwo) {
        suggestions.add('Combine ${element1.name} and ${element2.name} to discover ${result.name}.');
      } else if (hasOne) {
        final missing = hasOne ? element2 : element1;
        final known = hasOne ? element1 : element2;
        suggestions.add('Pair ${known.name} with ${missing.name} to unlock ${result.name}.');
      } else {
        suggestions.add('Look for ${element1.name} or ${element2.name} to make ${result.name}.');
      }
    }

    if (suggestions.isEmpty) {
      if (discoveriesCount < 8) {
        suggestions.add('Start by combining basic elements like Fire, Water, Earth, or Wood to grow your repertoire.');
        suggestions.add('Try pairing elements from the same category to reveal hidden formations.');
      } else if (discoveriesCount < 18) {
        suggestions.add('Search for combinations that use what you already know — one new item is often enough.');
        suggestions.add('Every new discovery makes the next one easier to find. Keep experimenting.');
      } else {
        suggestions.add('You are close to mastery — focus on rare categories like Magic and Space.');
        suggestions.add('Revisit older discoveries and try combining them with new elements to unveil deeper secrets.');
      }
    }

    return suggestions;
  }

  String unlockHintFor(EmojiElement element) {
    final relatedCombos = ElementData.combinations.where((combo) =>
      combo.element1 == element.id || combo.element2 == element.id
    ).toList();

    for (var combo in relatedCombos) {
      final otherId = combo.element1 == element.id ? combo.element2 : combo.element1;
      final otherElement = ElementData.elements[otherId]!;
      final result = ElementData.elements[combo.result]!;
      if (!_discoveredElements.contains(result.id)) {
        return 'Try pairing ${element.name} with ${otherElement.name} to discover ${result.name}.';
      }
    }

    switch (element.category) {
      case ElementCategory.nature:
        return 'Nature elements thrive when mixed with water, light, or earth-based forms.';
      case ElementCategory.technology:
        return 'Technology often unlocks stronger constructs when combined with energy or crafted materials.';
      case ElementCategory.magic:
        return 'Magic likes to mingle with ancient or elemental forces; experiment freely.';
      case ElementCategory.space:
        return 'Space elements open cosmic paths when paired with lightning or charged matter.';
    }
  }

  CombinationOutcome? attemptCombination(String id1, String id2, double spawnX, double spawnY) {
    final e1 = _canvasElements.firstWhere((e) => e.id == id1).element.id;
    final e2 = _canvasElements.firstWhere((e) => e.id == id2).element.id;

    for (var combo in ElementData.combinations) {
      if (combo.matches(e1, e2)) {
        removeElement(id1);
        removeElement(id2);

        final resultElement = ElementData.elements[combo.result]!;
        addToCanvas(resultElement, spawnX, spawnY);

        final wasNew = !_discoveredElements.contains(resultElement.id);
        if (wasNew) {
          _discoveredElements.add(resultElement.id);
          _saveProgress();
        }

        return CombinationOutcome(
          result: resultElement,
          ingredientA: ElementData.elements[combo.element1]!,
          ingredientB: ElementData.elements[combo.element2]!,
          wasNewDiscovery: wasNew,
        );
      }
    }
    return null;
  }
}
