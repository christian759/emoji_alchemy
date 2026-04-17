import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../models/emoji_item.dart';
import 'recipe_manager.dart';
import 'ad_manager.dart';

enum GameMode { sandbox, adventure, challenge }

class GameController extends ChangeNotifier {
  Set<String> _discoveredEmojis = {};
  List<EmojiItem> _canvasEmojis = [];
  bool _isLoading = true;
  String _selectedCategory = "All";
  String? _lastDiscoveredEmoji;
  
  GameMode _currentMode = GameMode.sandbox;
  String? _challengeTarget;

  Set<String> get discoveredEmojis => _discoveredEmojis;
  List<EmojiItem> get canvasEmojis => _canvasEmojis;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String? get lastDiscoveredEmoji => _lastDiscoveredEmoji;
  GameMode get currentMode => _currentMode;
  String? get challengeTarget => _challengeTarget;

  List<String> get filteredInventory {
    if (_currentMode == GameMode.sandbox) {
      final all = RecipeManager.recipes.values.toSet()..addAll(RecipeManager.getStartingEmojis());
      if (_selectedCategory == "All") return all.toList()..sort();
      return all.where((e) => RecipeManager.getEmojiCategory(e) == _selectedCategory).toList()..sort();
    }
    
    if (_selectedCategory == "All") return _discoveredEmojis.toList()..sort();
    return _discoveredEmojis.where((e) => RecipeManager.getEmojiCategory(e) == _selectedCategory).toList()..sort();
  }

  int get totalPossible => RecipeManager.recipes.values.toSet().length + RecipeManager.getStartingEmojis().length;

  GameController() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('discovered_emojis');
    if (saved != null && saved.isNotEmpty) {
      _discoveredEmojis = saved.toSet();
    } else {
      _discoveredEmojis = RecipeManager.getStartingEmojis().toSet();
    }
    _isLoading = false;
    notifyListeners();
  }

  void setMode(GameMode mode) {
    _currentMode = mode;
    _canvasEmojis.clear();
    if (mode == GameMode.challenge) {
      _pickNewChallenge();
    }
    notifyListeners();
  }

  void _pickNewChallenge() {
    final allPossible = RecipeManager.recipes.values.toList();
    _challengeTarget = (allPossible..shuffle()).first;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('discovered_emojis', _discoveredEmojis.toList());
  }

  void addEmojiToCanvas(String emoji, Offset position) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _canvasEmojis.add(EmojiItem(emoji: emoji, id: id, position: position));
    notifyListeners();
  }

  void updateEmojiPosition(String id, Offset newPosition) {
    final index = _canvasEmojis.indexWhere((e) => e.id == id);
    if (index != -1) {
      _canvasEmojis[index].position = newPosition;
      notifyListeners();
    }
  }

  void removeEmoji(String id) {
    _canvasEmojis.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void clearCanvas() {
    _canvasEmojis.clear();
    notifyListeners();
  }

  bool checkCollision(EmojiItem dragged) {
    for (var other in _canvasEmojis) {
      if (other.id == dragged.id) continue;

      final distance = (dragged.position - other.position).distance;
      if (distance < 60) { // Collision threshold
        final result = RecipeManager.combine(dragged.emoji, other.emoji);
        if (result != null) {
          _handleMerge(dragged, other, result);
          return true;
        } else {
          // Subtle shake feedback for invalid combination
          _vibrate(intensity: 30);
          return false;
        }
      }
    }
    return false;
  }

  void _handleMerge(EmojiItem e1, EmojiItem e2, String result) {
    final mergePosition = (e1.position + e2.position) / 2;
    removeEmoji(e1.id);
    removeEmoji(e2.id);
    
    addEmojiToCanvas(result, mergePosition);

    if (!_discoveredEmojis.contains(result)) {
      _discoveredEmojis.add(result);
      _save();
      _vibrate(intensity: 100);
      _lastDiscoveredEmoji = result; // Trigger UI event in Adventure Mode
      if (_currentMode == GameMode.adventure) {
        AdManager.showDiscoveryAd();
      }
    } else {
      _vibrate(intensity: 50);
    }

    if (_currentMode == GameMode.challenge && result == _challengeTarget) {
      _vibrate(intensity: 150);
      _pickNewChallenge();
      // We'll handle the 'Success' UI in the widget layer
    }
    
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearLastDiscovered() {
    _lastDiscoveredEmoji = null;
    notifyListeners();
  }

  void _vibrate({int intensity = 50}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: intensity);
    }
  }

  String? getHint() {
    return RecipeManager.getHint(_discoveredEmojis);
  }

  void unlockRandom() {
    final allPossibleResult = RecipeManager.recipes.values.toSet();
    final locked = allPossibleResult.difference(_discoveredEmojis);
    if (locked.isNotEmpty) {
      final randomEmoji = (locked.toList()..shuffle()).first;
      _discoveredEmojis.add(randomEmoji);
      _save();
      notifyListeners();
    }
  }
}
