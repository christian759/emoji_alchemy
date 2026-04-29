import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/emoji_element.dart';
import '../models/placed_element.dart';
import '../data/element_data.dart';

class GameState extends ChangeNotifier {
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  Set<String> _discoveredElements = {};
  List<PlacedElement> _canvasElements = [];
  
  // Stats
  int get discoveriesCount => _discoveredElements.length;
  int get maxDiscoveries => ElementData.elements.length;

  Set<String> get discoveredElements => _discoveredElements;
  List<PlacedElement> get canvasElements => _canvasElements;

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
    notifyListeners();
  }

  void _saveProgress() {
    _prefs.setStringList('discoveredElements', _discoveredElements.toList());
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

  // Returns the newly discovered item, or null if combination is invalid
  // If valid, removes the two ingredients and places the new one
  EmojiElement? attemptCombination(String id1, String id2, double spawnX, double spawnY) {
    final e1 = _canvasElements.firstWhere((e) => e.id == id1).element.id;
    final e2 = _canvasElements.firstWhere((e) => e.id == id2).element.id;

    for (var combo in ElementData.combinations) {
      if (combo.matches(e1, e2)) {
        // Success
        removeElement(id1);
        removeElement(id2);
        
        final resultElement = ElementData.elements[combo.result]!;
        addToCanvas(resultElement, spawnX, spawnY);

        if (!_discoveredElements.contains(resultElement.id)) {
          _discoveredElements.add(resultElement.id);
          _saveProgress();
          // Returning it signifies a NEW discovery that might trigger the UI pop-up
          return resultElement;
        }
        
        // Return null meaning it was successfully combined, but not NEW
        // Wait, the UI might want to know it succeeded either way to play sound.
        // Let's create a custom return type or just use an event stream for UI juice.
        return null;
      }
    }
    return null; // Failed to combine
  }
}
