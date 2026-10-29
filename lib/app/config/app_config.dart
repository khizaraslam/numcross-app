class AppConfig {
  static const String appName = 'NumCross – Math Puzzle';
  static const String packageName = 'com.company.numcross';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // Supabase (Optional for local-only, required for online sync)
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // Legal & Support
  static const String supportEmail = 'support@numcross.game';
  static const String privacyPolicyUrl = 'https://numcross.game/privacy';
  static const String termsUrl = 'https://numcross.game/terms';
}
