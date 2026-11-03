import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'NumCross – Math Puzzle';
  static const String appShortName = 'NumCross';
  static const String packageName = 'com.company.numcross';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
  static const int generatorVersion = 1;
  static const int localSchemaVersion = 1;

  // Branding assets (production names)
  static const String logoAsset = 'assets/branding/logo.png';
  static const String splashAsset = 'assets/branding/splash.png';
  static const String splashLogoAsset =
      'assets/branding/splash_logo_centered.png';
  static const String appIconAsset = 'assets/branding/app_icon.png';
  static const String onboardingSolveAsset =
      'assets/branding/onboarding_solve.png';
  static const String onboardingLevelsAsset =
      'assets/branding/onboarding_levels.png';
  static const String onboardingChallengeAsset =
      'assets/branding/onboarding_challenge.png';

  // Filled by [load] from `.env` (dart-define wins if set).
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('YOUR_PROJECT') &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';

  // Legal & Support
  static const String supportEmail = 'support@numcross.game';
  static const String privacyPolicyUrl = 'https://numcross.game/privacy';
  static const String termsUrl = 'https://numcross.game/terms';

  /// Loads Supabase keys from `.env`. Safe if the file is missing or empty.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env', isOptional: true);
      if (!dotenv.isInitialized ||
          (dotenv.env['SUPABASE_URL'] ?? '').isEmpty) {
        await dotenv.load(fileName: '.env.example', isOptional: true);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppConfig: no .env found — offline mode ($e)');
      }
    }

    const defineUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const defineKey =
        String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    supabaseUrl = defineUrl.isNotEmpty
        ? defineUrl
        : (dotenv.isInitialized ? dotenv.env['SUPABASE_URL'] ?? '' : '');
    supabaseAnonKey = defineKey.isNotEmpty
        ? defineKey
        : (dotenv.isInitialized ? dotenv.env['SUPABASE_ANON_KEY'] ?? '' : '');

    supabaseUrl = supabaseUrl.trim();
    supabaseAnonKey = supabaseAnonKey.trim();
  }
}
