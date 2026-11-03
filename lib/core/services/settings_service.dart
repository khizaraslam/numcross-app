import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import 'storage_service.dart';

/// Single place that holds the live app settings and plays feedback
/// (sound / vibration) according to them.
///
/// Put this file in: lib/core/services/settings_service.dart
///
/// Needs packages: audioplayers, vibration
/// Needs in AndroidManifest.xml:
///   <uses-permission android:name="android.permission.VIBRATE"/>
class SettingsService {
  /// Listen to this to rebuild when any setting changes.
  static final ValueNotifier<AppSettings> notifier =
      ValueNotifier<AppSettings>(AppSettings());

  /// Call once at startup, after FlutterStorageService.init().
  static void load() {
    notifier.value = FlutterStorageService.getSettings();
  }

  static AppSettings get current => notifier.value;

  /// Change one or more settings, save them and notify listeners.
  static Future<void> update(void Function(AppSettings s) change) async {
    // copy, so the notifier sees a new object and notifies
    final s = AppSettings.fromJson(notifier.value.toJson());
    change(s);
    notifier.value = s;
    await FlutterStorageService.saveSettings(s);
  }

  // ---------------- Sound generation (no asset files needed) ----------------

  static const int _sampleRate = 22050;

  /// Builds a 16-bit mono WAV from a list of (frequencyHz, durationMs) notes.
  static Uint8List _buildWav(List<List<num>> notes, {double volume = 0.6}) {
    final samples = <int>[];
    for (final n in notes) {
      final freq = n[0].toDouble();
      final count = (_sampleRate * n[1] / 1000).round();
      for (int i = 0; i < count; i++) {
        // short fade in/out so there are no clicks/pops
        final fade = math.min(1.0, math.min(i, count - i) / (count * 0.15));
        final v = math.sin(2 * math.pi * freq * i / _sampleRate) * fade * volume;
        samples.add((v * 32767).round());
      }
    }

    final dataLen = samples.length * 2;
    final bd = ByteData(44 + dataLen);
    void str(int o, String s) {
      for (int i = 0; i < s.length; i++) {
        bd.setUint8(o + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    bd.setUint32(4, 36 + dataLen, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little); // PCM
    bd.setUint16(22, 1, Endian.little); // mono
    bd.setUint32(24, _sampleRate, Endian.little);
    bd.setUint32(28, _sampleRate * 2, Endian.little);
    bd.setUint16(32, 2, Endian.little);
    bd.setUint16(34, 16, Endian.little);
    str(36, 'data');
    bd.setUint32(40, dataLen, Endian.little);
    for (int i = 0; i < samples.length; i++) {
      bd.setInt16(44 + i * 2, samples[i], Endian.little);
    }
    return bd.buffer.asUint8List();
  }

  static final Uint8List _clickWav = _buildWav([
    [900, 45]
  ]);
  static final Uint8List _errorWav = _buildWav([
    [260, 110],
    [190, 160]
  ]);
  static final Uint8List _successWav = _buildWav([
    [523, 100],
    [659, 100],
    [784, 180]
  ]);

  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _errorPlayer = AudioPlayer();
  static final AudioPlayer _successPlayer = AudioPlayer();

  static Future<void> _play(AudioPlayer player, Uint8List bytes) async {
    try {
      await player.stop();
      await player.play(BytesSource(bytes), volume: 1.0);
    } catch (e, s) {
      debugPrint('SOUND ERROR: $e\n$s');
    }
  }

  // ---------------- Vibration ----------------

  static Future<void> _vibrate(int ms) async {
    try {
      final has = await Vibration.hasVibrator();
      if (has == true) {
        await Vibration.vibrate(duration: ms);
      } else {
        // fallback
        await HapticFeedback.mediumImpact();
      }
    } catch (e, s) {
      debugPrint('VIBRATION ERROR: $e\n$s');
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  // ---------------- Test buttons (used by the Settings screen) ----------------

  /// Plays a sound ignoring the toggle, and returns a message about what happened.
  static Future<String> testSound() async {
    try {
      await _successPlayer.stop();
      await _successPlayer.play(BytesSource(_successWav), volume: 1.0);
      return 'Sound play ho gayi. Agar awaaz nahi aayi to phone ka MEDIA volume check karein.';
    } catch (e) {
      return 'Sound error: $e\n\nApp ko Stop karke dobara Run karein (hot restart kaafi nahi).';
    }
  }

  /// Vibrates ignoring the toggle, and returns a message about what happened.
  static Future<String> testVibration() async {
    try {
      final has = await Vibration.hasVibrator();
      if (has != true) {
        return 'Is device mein vibration motor nahi mila (emulator par vibration nahi hoti).';
      }
      await Vibration.vibrate(duration: 400);
      return 'Vibration bheji gayi. Mehsoos na ho to AndroidManifest mein VIBRATE permission aur phone ki vibration settings check karein.';
    } catch (e) {
      return 'Vibration error: $e\n\nAndroidManifest mein VIBRATE permission check karein, phir app Stop karke dobara Run karein.';
    }
  }

  // ---------------- Feedback (same names as before) ----------------

  /// Soft click sound (only if Sound Effects is on).
  static void click() {
    if (current.sound) _play(_clickPlayer, _clickWav);
  }

  /// Light vibration (only if Vibration is on).
  static void haptic() {
    if (current.vibration) _vibrate(20);
  }

  /// Normal button press: click + light vibration.
  static void tap() {
    click();
    haptic();
  }

  /// Wrong answer: low buzz + strong vibration.
  static void error() {
    if (current.sound) _play(_errorPlayer, _errorWav);
    if (current.vibration) _vibrate(120);
  }

  /// Puzzle solved: happy tones + medium vibration.
  static void success() {
    if (current.sound) _play(_successPlayer, _successWav);
    if (current.vibration) _vibrate(60);
  }
}