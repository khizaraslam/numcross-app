import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/config/app_config.dart';
import 'app/theme/app_theme.dart';
import 'core/services/analytics_service.dart';
import 'core/services/monetization_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/supabase_service.dart';
import 'features/splash/presentation/splash_screen.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Status bar follows the phone theme (not a branded color).
  final dark = widgetsBinding.platformDispatcher.platformBrightness ==
      Brightness.dark;
  SystemChrome.setSystemUIOverlayStyle(
    dark ? AppTheme.darkOverlay : AppTheme.lightOverlay,
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await AppConfig.load(); // reads SUPABASE_* from `.env`
  await FlutterStorageService.init();
  SettingsService.load();
  await SupabaseService.init();
  await Monetization.instance.init();
  Analytics.event('app_open', {
    'version': AppConfig.appVersion,
    'build': AppConfig.buildNumber,
    'supabase': AppConfig.hasSupabase,
  });
  runApp(const ProviderScope(child: NumCrossApp()));
}

class NumCrossApp extends StatelessWidget {
  const NumCrossApp({super.key});

  ThemeMode _themeMode(String t) {
    switch (t) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds the whole app instantly whenever a setting changes.
    return ValueListenableBuilder<AppSettings>(
      valueListenable: SettingsService.notifier,
      builder: (context, settings, _) {
        final mode = _themeMode(settings.theme);
        final dark = mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark);
        SystemChrome.setSystemUIOverlayStyle(
          dark ? AppTheme.darkOverlay : AppTheme.lightOverlay,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: dark ? AppTheme.darkOverlay : AppTheme.lightOverlay,
          child: MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: TextScaler.linear(
                      settings.textSize == 'large' ? 1.15 : 1.0),
                ),
                child: child!,
              );
            },
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}