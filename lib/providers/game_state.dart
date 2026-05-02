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

class LabHint {
  final String title;
  final String detail;
  final String badge;
  final String? recipe;
  final String? targetElementId;

  const LabHint({
    required this.title,
    required this.detail,
    required this.badge,
    this.recipe,
    this.targetElementId,
  });
}

class GameState extends ChangeNotifier {
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  Set<String> _discoveredElements = {};
  final List<PlacedElement> _canvasElements = [];
  int _hintsRemaining = 3;
  LabHint? _activeHint;
  
  // Stats
  int get discoveriesCount => _discoveredElements.length;
  int get maxDiscoveries => ElementData.elements.length;
  int get hintsRemaining => _hintsRemaining;

  Set<String> get discoveredElements => _discoveredElements;
  List<PlacedElement> get canvasElements => _canvasElements;
  LabHint? get activeHint => _activeHint;

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

  LabHint? useHint() {
    if (_hintsRemaining <= 0) return null;
    _hintsRemaining--;
    final hints = _buildHints(limit: 1);
    _activeHint = hints.isNotEmpty ? hints.first : _fallbackHint();
    _saveProgress();
    notifyListeners();
    return _activeHint;
  }

  List<LabHint> get hintSuggestions {
    return _buildHints(limit: 5);
  }

  String unlockHintFor(EmojiElement element) {
    return buildDiscoveryHints(element, limit: 1).first.detail;
  }

  List<Combination> recipesForResult(String resultId) {
    return ElementData.combinations
        .where((combo) => combo.result == resultId)
        .toList();
  }

  Combination? combinationForElements(String elementId1, String elementId2) {
    for (final combo in ElementData.combinations) {
      if (combo.matches(elementId1, elementId2)) {
        return combo;
      }
    }
    return null;
  }

  String recipeText(Combination combo) {
    final element1 = ElementData.elements[combo.element1]!;
    final element2 = ElementData.elements[combo.element2]!;
    final result = ElementData.elements[combo.result]!;
    return '${element1.emoji} ${element1.name} + ${element2.emoji} ${element2.name} = ${result.emoji} ${result.name}';
  }

  List<LabHint> buildDiscoveryHints(EmojiElement element, {int limit = 3}) {
    final exactMatches = <LabHint>[];
    final almostMatches = <LabHint>[];

    for (final combo in ElementData.combinations) {
      if (combo.element1 != element.id && combo.element2 != element.id) continue;
      final otherId = combo.element1 == element.id ? combo.element2 : combo.element1;
      final otherElement = ElementData.elements[otherId]!;
      final result = ElementData.elements[combo.result]!;

      if (_discoveredElements.contains(result.id)) continue;

      final knowsOther = _discoveredElements.contains(otherId);
      final recipe = recipeText(combo);
      if (knowsOther) {
        exactMatches.add(LabHint(
          title: '${result.name} is ready',
          detail: 'You already own ${element.name} and ${otherElement.name}, so try this mix next.',
          badge: 'CAN MAKE NOW',
          recipe: recipe,
          targetElementId: result.id,
        ));
      } else {
        almostMatches.add(LabHint(
          title: 'Use ${element.name} again',
          detail: 'Find ${otherElement.name} and pair it with ${element.name} to discover ${result.name}.',
          badge: 'ONE MORE INGREDIENT',
          recipe: recipe,
          targetElementId: result.id,
        ));
      }
    }

    final hints = <LabHint>[
      ...exactMatches,
      ...almostMatches,
    ];

    if (hints.isEmpty) {
      hints.add(_categoryHintFor(element));
    }

    return hints.take(limit).toList();
  }

  CombinationOutcome? attemptCombination(String id1, String id2, double spawnX, double spawnY) {
    final e1 = _canvasElements.firstWhere((e) => e.id == id1).element.id;
    final e2 = _canvasElements.firstWhere((e) => e.id == id2).element.id;

    final combo = combinationForElements(e1, e2);
    if (combo != null) {
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
    return null;
  }

  List<LabHint> _buildHints({int limit = 5}) {
    final ready = <LabHint>[];
    final almost = <LabHint>[];
    final discovered = _discoveredElements;

    for (final combo in ElementData.combinations) {
      final result = ElementData.elements[combo.result];
      if (result == null || discovered.contains(result.id)) continue;

      final hasOne = discovered.contains(combo.element1);
      final hasTwo = discovered.contains(combo.element2);
      if (!hasOne && !hasTwo) continue;

      final element1 = ElementData.elements[combo.element1]!;
      final element2 = ElementData.elements[combo.element2]!;
      final recipe = recipeText(combo);

      if (hasOne && hasTwo) {
        ready.add(LabHint(
          title: '${result.name} is waiting',
          detail: 'Drop ${element1.name} onto ${element2.name} in the lab right now.',
          badge: 'READY NOW',
          recipe: recipe,
          targetElementId: result.id,
        ));
      } else {
        final known = hasOne ? element1 : element2;
        final missing = hasOne ? element2 : element1;
        almost.add(LabHint(
          title: 'One piece missing',
          detail: 'You already have ${known.name}. Find ${missing.name} to unlock ${result.name}.',
          badge: 'SETUP HINT',
          recipe: recipe,
          targetElementId: result.id,
        ));
      }
    }

    ready.sort((a, b) => a.title.compareTo(b.title));
    almost.sort((a, b) => a.title.compareTo(b.title));

    final hints = <LabHint>[
      ...ready,
      ...almost,
    ];

    if (hints.isEmpty) {
      hints.add(_fallbackHint());
    }

    return hints.take(limit).toList();
  }

  LabHint _fallbackHint() {
    if (discoveriesCount < 8) {
      return const LabHint(
        title: 'Start with the basics',
        detail: 'Mix your base elements together first. Fire, Water, Earth, and Wind still hide several early discoveries.',
        badge: 'EARLY GAME',
      );
    }
    if (discoveriesCount < 18) {
      return const LabHint(
        title: 'Chain your discoveries',
        detail: 'Try your newest discoveries with the elements you already trust. One fresh ingredient often unlocks several more.',
        badge: 'MID GAME',
      );
    }
    return const LabHint(
      title: 'Hunt rare branches',
      detail: 'You are deep into the codex now. Revisit Space and Magic ingredients to uncover the harder late-game recipes.',
      badge: 'LATE GAME',
    );
  }

  LabHint _categoryHintFor(EmojiElement element) {
    switch (element.category) {
      case ElementCategory.nature:
        return const LabHint(
          title: 'Nature likes growth',
          detail: 'Nature discoveries usually branch with water, sunlight, and fertile earth. Keep trying soft elemental pairs.',
          badge: 'CATEGORY CLUE',
        );
      case ElementCategory.technology:
        return const LabHint(
          title: 'Power it up',
          detail: 'Technology tends to expand once you add electricity, metal, or crafted tools.',
          badge: 'CATEGORY CLUE',
        );
      case ElementCategory.magic:
        return const LabHint(
          title: 'Magic needs catalysts',
          detail: 'Magical items often wake up when mixed with rare gems, moonlight, or human-made knowledge.',
          badge: 'CATEGORY CLUE',
        );
      case ElementCategory.space:
        return const LabHint(
          title: 'Think bigger',
          detail: 'Space discoveries usually evolve through storms, stars, and powerful energy sources.',
          badge: 'CATEGORY CLUE',
        );
      case ElementCategory.base:
      case ElementCategory.weather:
      case ElementCategory.animals:
      case ElementCategory.human:
      case ElementCategory.food:
      case ElementCategory.mythology:
      case ElementCategory.other:
        return const LabHint(
          title: 'Keep exploring',
          detail: 'This discovery still connects to more recipes. Try it with both old basics and your newest unlocked elements.',
          badge: 'CATEGORY CLUE',
        );
    }
  }
}
