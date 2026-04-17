import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../models/emoji_item.dart';
import 'recipe_manager.dart';
import 'ad_manager.dart';
import 'achievement_manager.dart';

enum GameMode { sandbox, adventure, challenge }

class GameController extends ChangeNotifier {
  // ─── Discovery state ──────────────────────────────────────
  Set<String> _discoveredEmojis = {};
  List<EmojiItem> _canvasEmojis = [];
  bool _isLoading = true;
  String? _selectedCategory = 'All';
  String _searchQuery = '';
  String? _lastDiscoveredEmoji;
  String? _selectedInventoryEmoji;
  bool _vibrationEnabled = true;
  GameMode _currentMode = GameMode.sandbox;
  String? _challengeTarget;

  // ─── Gamification ─────────────────────────────────────────
  int _xp = 0;
  int _level = 1;
  int _score = 0;
  int _highScore = 0;
  int _comboCount = 0;
  int _totalCombines = 0;
  bool _leveledUp = false;
  Achievement? _newAchievement;
  Set<String> _unlockedAchievements = {};
  Timer? _comboTimer;

  // ─── Challenge mode ────────────────────────────────────────
  int _challengeTimeLeft = 60;
  Timer? _challengeTimer;
  bool _challengeTimedOut = false;
  int _challengeScore = 0;
  int _challengeHighScore = 0;

  // ─── Particle trigger ─────────────────────────────────────
  Offset? _lastMergePosition;
  int _mergeParticleTrigger = 0;

  // ─── Getters ──────────────────────────────────────────────
  Set<String> get discoveredEmojis => _discoveredEmojis;
  List<EmojiItem> get canvasEmojis => _canvasEmojis;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory ?? 'All';
  String get searchQuery => _searchQuery;
  String? get lastDiscoveredEmoji => _lastDiscoveredEmoji;
  String? get selectedInventoryEmoji => _selectedInventoryEmoji;
  bool get vibrationEnabled => _vibrationEnabled;
  GameMode get currentMode => _currentMode;
  String? get challengeTarget => _challengeTarget;
  int get xp => _xp;
  int get level => _level;
  int get score => _score;
  int get highScore => _highScore;
  int get comboCount => _comboCount;
  bool get leveledUp => _leveledUp;
  Achievement? get newAchievement => _newAchievement;
  int get challengeTimeLeft => _challengeTimeLeft;
  bool get challengeTimedOut => _challengeTimedOut;
  int get challengeScore => _challengeScore;
  int get challengeHighScore => _challengeHighScore;
  Offset? get lastMergePosition => _lastMergePosition;
  int get mergeParticleTrigger => _mergeParticleTrigger;
  int get totalCombines => _totalCombines;

  int xpForLevel(int l) => 100 * l;
  double get xpProgress => (_xp / xpForLevel(_level)).clamp(0.0, 1.0);

  int get comboMultiplier {
    if (_comboCount >= 10) return 5;
    if (_comboCount >= 5) return 3;
    if (_comboCount >= 3) return 2;
    return 1;
  }

  int get totalPossible => {
    ...RecipeManager.allRecipeResults,
    ...RecipeManager.getStartingEmojis(),
  }.length;

  List<String> get filteredInventory {
    Iterable<String> base;
    if (_currentMode == GameMode.sandbox ||
        _currentMode == GameMode.challenge) {
      base = Set<String>.from(RecipeManager.allRecipeResults)
        ..addAll(RecipeManager.getStartingEmojis());
    } else {
      base = _discoveredEmojis;
    }

    if (_selectedCategory != 'All') {
      base = base.where(
        (e) => RecipeManager.getEmojiCategory(e) == _selectedCategory,
      );
    }

    if (_searchQuery.isNotEmpty) {
      base = base.where((e) {
        final meaning = RecipeManager.meanings[e]?.toLowerCase() ?? '';
        return e.contains(_searchQuery) ||
            meaning.contains(_searchQuery.toLowerCase());
      });
    }

    return base.toList()..sort();
  }

  GameController() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('discovered_emojis');
    _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    _xp = prefs.getInt('xp') ?? 0;
    _level = prefs.getInt('level') ?? 1;
    _highScore = prefs.getInt('high_score') ?? 0;
    _challengeHighScore = prefs.getInt('challenge_high_score') ?? 0;
    _unlockedAchievements = (prefs.getStringList('achievements') ?? []).toSet();

    if (saved != null && saved.isNotEmpty) {
      _discoveredEmojis = saved.toSet();
    } else {
      _discoveredEmojis = RecipeManager.getStartingEmojis().toSet();
    }
    _isLoading = false;
    notifyListeners();
  }

  // ─── Settings ─────────────────────────────────────────────

  void toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectInventoryEmoji(String? emoji) {
    _selectedInventoryEmoji = emoji;
    notifyListeners();
  }

  Future<void> resetProgress() async {
    _comboTimer?.cancel();
    _challengeTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _discoveredEmojis = RecipeManager.getStartingEmojis().toSet();
    _xp = 0;
    _level = 1;
    _score = 0;
    _highScore = 0;
    _comboCount = 0;
    _totalCombines = 0;
    _unlockedAchievements = {};
    _challengeScore = 0;
    _challengeHighScore = 0;
    clearCanvas();
    _init();
  }

  // ─── Mode ──────────────────────────────────────────────────

  void setMode(GameMode mode) {
    _comboTimer?.cancel();
    _challengeTimer?.cancel();
    _currentMode = mode;
    _score = 0;
    _comboCount = 0;
    _challengeTimedOut = false;
    clearCanvas();
    if (mode == GameMode.challenge) {
      _pickNewChallenge();
      _startChallengeTimer();
    }
    notifyListeners();
  }

  void setDailyChallenge() {
    _comboTimer?.cancel();
    _challengeTimer?.cancel();
    _currentMode = GameMode.challenge;
    _score = 0;
    _comboCount = 0;
    _challengeTimedOut = false;
    clearCanvas();

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final possibleWithClues = RecipeManager.clues.keys.toList()..sort();
    _challengeTarget = possibleWithClues[dayOfYear % possibleWithClues.length];

    _startChallengeTimer();
    notifyListeners();
  }

  void _pickNewChallenge() {
    final possibleWithClues = RecipeManager.clues.keys.toList();
    _challengeTarget = (possibleWithClues..shuffle()).first;
  }

  void _startChallengeTimer() {
    _challengeTimeLeft = 60;
    _challengeTimedOut = false;
    _challengeTimer?.cancel();
    _challengeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_challengeTimeLeft > 0) {
        _challengeTimeLeft--;
        notifyListeners();
      } else {
        timer.cancel();
        _onChallengeTimedOut();
      }
    });
  }

  void _onChallengeTimedOut() {
    _challengeTimedOut = true;
    if (_challengeScore > _challengeHighScore) {
      _challengeHighScore = _challengeScore;
      _saveHighScore();
    }
    _vibrate(intensity: 300);
    notifyListeners();
  }

  void restartChallenge() {
    _challengeScore = 0;
    _pickNewChallenge();
    _startChallengeTimer();
    clearCanvas();
    notifyListeners();
  }

  // ─── Canvas ────────────────────────────────────────────────

  void addEmojiToCanvas(String emoji, Offset position) {
    final newItem = EmojiItem(
      emoji: emoji,
      position: position,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _canvasEmojis.add(newItem);
    notifyListeners();
  }

  void updateEmojiPosition(String id, Offset newPosition) {
    final index = _canvasEmojis.indexWhere((e) => e.id == id);
    if (index != -1) {
      _canvasEmojis[index] = _canvasEmojis[index].copyWith(
        position: newPosition,
      );
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

  // ─── Collision & merge ────────────────────────────────────

  bool checkCollision(EmojiItem dragged) {
    for (var other in _canvasEmojis) {
      if (other.id == dragged.id) continue;
      final distance = (dragged.position - other.position).distance;
      if (distance < 50) {
        final result = RecipeManager.combine(dragged.emoji, other.emoji);
        if (result != null) {
          _handleMerge(dragged, other, result);
          return true;
        }
        return false;
      }
    }
    return false;
  }

  void _handleMerge(EmojiItem e1, EmojiItem e2, String result) {
    final mergePosition = Offset(
      (e1.position.dx + e2.position.dx) / 2,
      (e1.position.dy + e2.position.dy) / 2,
    );

    _lastMergePosition = mergePosition;
    _mergeParticleTrigger++;

    removeEmoji(e1.id);
    removeEmoji(e2.id);
    addEmojiToCanvas(result, mergePosition);

    _totalCombines++;
    _updateCombo();

    final bool isNewDiscovery = !_discoveredEmojis.contains(result);
    bool challengeCompleted = false;

    if (isNewDiscovery) {
      _discoveredEmojis.add(result);
      _save();
      _vibrate(intensity: 100);
      _lastDiscoveredEmoji = result;
      if (_currentMode == GameMode.adventure) {
        AdManager.showDiscoveryAd();
      }
    } else {
      _vibrate(intensity: 30);
    }

    if (_currentMode == GameMode.challenge &&
        result == _challengeTarget &&
        !_challengeTimedOut) {
      _vibrate(intensity: 200);
      final bonusScore = _challengeTimeLeft * 3;
      _challengeScore += 100 + bonusScore;
      // Add time bonus
      _challengeTimeLeft = (_challengeTimeLeft + 15).clamp(0, 90);
      challengeCompleted = true;
      _pickNewChallenge();
    }

    _awardXP(
      isNewDiscovery: isNewDiscovery,
      challengeCompleted: challengeCompleted,
    );
    _checkAchievements(
      isNewDiscovery: isNewDiscovery,
      challengeCompleted: challengeCompleted,
    );

    notifyListeners();
  }

  void _updateCombo() {
    _comboTimer?.cancel();
    _comboCount++;
    _comboTimer = Timer(const Duration(seconds: 3), () {
      _comboCount = 0;
      notifyListeners();
    });
  }

  void _awardXP({
    required bool isNewDiscovery,
    required bool challengeCompleted,
  }) {
    int earned = 10 * comboMultiplier;
    if (isNewDiscovery) earned += 50;
    if (challengeCompleted) earned += 100;

    _xp += earned;
    _score += earned;

    // Level up loop
    while (_xp >= xpForLevel(_level)) {
      _xp -= xpForLevel(_level);
      _level++;
      _leveledUp = true;
    }

    if (_score > _highScore) {
      _highScore = _score;
      _saveHighScore();
    }
  }

  Future<void> _checkAchievements({
    required bool isNewDiscovery,
    required bool challengeCompleted,
  }) async {
    final achievement = await AchievementManager.checkAndAward(
      unlocked: _unlockedAchievements,
      totalCombines: _totalCombines,
      comboCount: _comboCount,
      level: _level,
      discoveries: _discoveredEmojis.length,
      discoveredEmojis: _discoveredEmojis,
      justDiscoveredNew: isNewDiscovery,
      justCompletedChallenge: challengeCompleted,
    );

    if (achievement != null) {
      _newAchievement = achievement;
      notifyListeners();
    }
  }

  // ─── Overlay dismissal ─────────────────────────────────────

  void clearLevelUp() {
    _leveledUp = false;
    notifyListeners();
  }

  void clearNewAchievement() {
    _newAchievement = null;
    notifyListeners();
  }

  void clearLastDiscovered() {
    _lastDiscoveredEmoji = null;
    notifyListeners();
  }

  // ─── Hints / rewards ──────────────────────────────────────

  String? getHint() => RecipeManager.getHint(_discoveredEmojis);

  void unlockRandom() {
    final allPossibleResult = RecipeManager.allRecipeResults;
    final locked = allPossibleResult.difference(_discoveredEmojis);
    if (locked.isNotEmpty) {
      final randomEmoji = (locked.toList()..shuffle()).first;
      _discoveredEmojis.add(randomEmoji);
      _save();
      notifyListeners();
    }
  }

  // ─── Persistence ──────────────────────────────────────────

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('discovered_emojis', _discoveredEmojis.toList());
    await prefs.setInt('xp', _xp);
    await prefs.setInt('level', _level);
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', _highScore);
    await prefs.setInt('challenge_high_score', _challengeHighScore);
  }

  Future<void> _vibrate({int intensity = 50}) async {
    if (!_vibrationEnabled) return;
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: intensity);
    }
  }

  @override
  void dispose() {
    _comboTimer?.cancel();
    _challengeTimer?.cancel();
    super.dispose();
  }
}
