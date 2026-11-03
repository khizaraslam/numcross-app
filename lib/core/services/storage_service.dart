import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LevelStatus {
  final int worldId;
  final int levelNum;
  bool isUnlocked;
  bool isCompleted;
  int stars;

  LevelStatus({
    required this.worldId,
    required this.levelNum,
    required this.isUnlocked,
    required this.isCompleted,
    this.stars = 0,
  });

  Map<String, dynamic> toJson() => {
        'worldId': worldId,
        'levelNum': levelNum,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
        'stars': stars,
      };

  factory LevelStatus.fromJson(Map<String, dynamic> json) => LevelStatus(
        worldId: json['worldId'] ?? 1,
        levelNum: json['levelNum'] ?? 1,
        isUnlocked: json['isUnlocked'] ?? false,
        isCompleted: json['isCompleted'] ?? false,
        stars: json['stars'] ?? 0,
      );
}

class PlayerProfile {
  String name;
  String avatar;
  int level;
  int xp;
  int totalStars;
  int currentStreak;
  int bestStreak;
  int completedCount;

  PlayerProfile({
    required this.name,
    required this.avatar,
    required this.level,
    required this.xp,
    required this.totalStars,
    required this.currentStreak,
    required this.bestStreak,
    required this.completedCount,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatar': avatar,
        'level': level,
        'xp': xp,
        'totalStars': totalStars,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'completedCount': completedCount,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
        name: json['name'] ?? 'SmartFox823',
        avatar: json['avatar'] ?? 'boy',
        level: json['level'] ?? 1,
        xp: json['xp'] ?? 0,
        totalStars: json['totalStars'] ?? 0,
        currentStreak: json['currentStreak'] ?? 0,
        bestStreak: json['bestStreak'] ?? 0,
        completedCount: json['completedCount'] ?? 0,
      );
}

class AppSettings {
  bool sound;
  bool vibration;
  bool timer;
  String mistakeChecking; // 'immediate' | 'on_check' | 'off'
  bool autoCheckEquations;
  String theme; // 'system' | 'light' | 'dark'
  String textSize; // 'normal' | 'large'
  bool onboardingCompleted;

  AppSettings({
    this.sound = true,
    this.vibration = true,
    this.timer = true,
    this.mistakeChecking = 'immediate',
    this.autoCheckEquations = true,
    this.theme = 'system',
    this.textSize = 'normal',
    this.onboardingCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'sound': sound,
        'vibration': vibration,
        'timer': timer,
        'mistakeChecking': mistakeChecking,
        'autoCheckEquations': autoCheckEquations,
        'theme': theme,
        'textSize': textSize,
        'onboardingCompleted': onboardingCompleted,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        sound: json['sound'] ?? true,
        vibration: json['vibration'] ?? true,
        timer: json['timer'] ?? true,
        mistakeChecking: json['mistakeChecking'] ?? 'immediate',
        autoCheckEquations: json['autoCheckEquations'] ?? true,
        theme: json['theme'] ?? 'system',
        textSize: json['textSize'] ?? 'normal',
        onboardingCompleted: json['onboardingCompleted'] ?? false,
      );
}

class FlutterStorageService {
  static const String _keyProfile = 'numcross_profile';
  static const String _keySettings = 'numcross_settings';
  static const String _keyLevels = 'numcross_levels';
  static const String _keyDaily = 'numcross_daily';
  static const String _keySavedGame = 'numcross_saved_game';

  static SharedPreferences? _prefs;

  /// Bumps every time levels are saved, so screens can refresh themselves.
  static final ValueNotifier<int> levelsRevision = ValueNotifier<int>(0);

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Safety net: makes sure saves never silently do nothing
  /// if init() was not called (or not finished) yet.
  static Future<void> _ensureInit() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Profile ---
  static PlayerProfile getProfile() {
    final str = _prefs?.getString(_keyProfile);
    if (str != null) {
      try {
        return PlayerProfile.fromJson(jsonDecode(str));
      } catch (_) {}
    }
    // Fresh player defaults
    return PlayerProfile(
      name: 'SmartFox823',
      avatar: 'boy',
      level: 1,
      xp: 0,
      totalStars: 0,
      currentStreak: 0,
      bestStreak: 0,
      completedCount: 0,
    );
  }

  static Future<void> saveProfile(PlayerProfile profile) async {
    await _ensureInit();
    await _prefs?.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  static Future<void> addXP(int amount) async {
    await _ensureInit();
    final profile = getProfile();
    profile.xp += amount;
    while (profile.xp >= (profile.level * 100 + 400)) {
      profile.xp -= (profile.level * 100 + 400);
      profile.level++;
    }
    await saveProfile(profile);
  }

  // --- Settings ---
  static AppSettings getSettings() {
    final str = _prefs?.getString(_keySettings);
    if (str != null) {
      try {
        return AppSettings.fromJson(jsonDecode(str));
      } catch (_) {}
    }
    return AppSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await _ensureInit();
    await _prefs?.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  // --- Levels Progression ---
  static Map<String, LevelStatus> getLevels() {
    final str = _prefs?.getString(_keyLevels);
    if (str != null) {
      try {
        final decoded = jsonDecode(str) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(k, LevelStatus.fromJson(v)));
      } catch (_) {}
    }

    // Fresh game: only World 1, Level 1 is unlocked. Nothing completed.
    final Map<String, LevelStatus> initialMap = {};
    for (int w = 1; w <= 5; w++) {
      for (int l = 1; l <= 20; l++) {
        final key = 'w${w}_l$l';
        initialMap[key] = LevelStatus(
          worldId: w,
          levelNum: l,
          isUnlocked: w == 1 && l == 1,
          isCompleted: false,
          stars: 0,
        );
      }
    }
    return initialMap;
  }

  static Future<void> saveLevels(Map<String, LevelStatus> map) async {
    await _ensureInit();
    final encoded = map.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs?.setString(_keyLevels, jsonEncode(encoded));
    levelsRevision.value++;
  }

  static Future<void> completeLevel(
      int worldId, int levelNum, int starsEarned) async {
    await _ensureInit();
    final map = getLevels();
    final currentKey = 'w${worldId}_l$levelNum';

    if (map.containsKey(currentKey)) {
      final current = map[currentKey]!;
      final prevStars = current.stars;
      current.isCompleted = true;
      if (starsEarned > current.stars) {
        current.stars = starsEarned;
      }

      // Unlock next level in current world
      if (levelNum < 20) {
        final nextKey = 'w${worldId}_l${levelNum + 1}';
        if (map.containsKey(nextKey)) {
          map[nextKey]!.isUnlocked = true;
        }
      } else if (worldId < 5) {
        // Unlock first level of next world
        final nextWorldKey = 'w${worldId + 1}_l1';
        if (map.containsKey(nextWorldKey)) {
          map[nextWorldKey]!.isUnlocked = true;
        }
      }

      await saveLevels(map);

      // Update player profile
      final profile = getProfile();
      profile.completedCount++;
      if (starsEarned > prevStars) {
        profile.totalStars += (starsEarned - prevStars);
      }
      await saveProfile(profile);
    }
  }

  /// Get the currently saved game, if one exists.
  static Map<String, dynamic>? getSavedGame() {
    final str = _prefs?.getString(_keySavedGame);

    if (str == null || str.isEmpty) return null;

    try {
      final decoded = jsonDecode(str);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      debugPrint('Failed to read saved game: $e');
    }

    return null;
  }

  /// Save the current game so the player can continue later.
  static Future<void> saveGame(Map<String, dynamic> game) async {
    await _ensureInit();
    await _prefs?.setString(_keySavedGame, jsonEncode(game));
  }

  /// Clear the saved game after it is no longer needed.
  static Future<void> clearSavedGame() async {
    await _ensureInit();
    await _prefs?.remove(_keySavedGame);
  }

  // --- Daily Progress ---
  static Map<String, dynamic> getDailyProgress() {
    final str = _prefs?.getString(_keyDaily);
    if (str != null) {
      try {
        return Map<String, dynamic>.from(jsonDecode(str));
      } catch (_) {}
    }
    return <String, dynamic>{}; // new player: nothing completed yet
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<void> setDailyCompleted(String dateStr) async {
    await _ensureInit();
    final map = getDailyProgress();

    // Already counted for this day -> do nothing (no double streak)
    if (map[dateStr] == true) return;

    // Was the day before completed? Then the streak continues,
    // otherwise it restarts at 1.
    final p = dateStr.split('-');
    final day = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    final yesterday = DateTime(day.year, day.month, day.day - 1);
    final continues = map[_dateKey(yesterday)] == true;

    map[dateStr] = true;
    await _prefs?.setString(_keyDaily, jsonEncode(map));

    final profile = getProfile();
    profile.currentStreak = continues ? profile.currentStreak + 1 : 1;
    if (profile.currentStreak > profile.bestStreak) {
      profile.bestStreak = profile.currentStreak;
    }
    await saveProfile(profile);
  }
}