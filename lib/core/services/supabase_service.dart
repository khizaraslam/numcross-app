import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/config/app_config.dart';

/// Optional cloud layer. Gameplay never depends on this succeeding.
class SupabaseService {
  static bool _ready = false;

  static bool get isReady => _ready;

  static SupabaseClient? get client => _ready ? Supabase.instance.client : null;

  static Future<void> init() async {
    if (!AppConfig.hasSupabase) {
      if (kDebugMode) {
        debugPrint('Supabase: skipped (no keys in .env) — offline mode');
      }
      return;
    }

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      _ready = true;
      if (kDebugMode) {
        debugPrint('Supabase: initialized');
      }
    } catch (e, s) {
      _ready = false;
      if (kDebugMode) {
        debugPrint('Supabase: init failed, continuing offline\n$e\n$s');
      }
    }
  }
}
