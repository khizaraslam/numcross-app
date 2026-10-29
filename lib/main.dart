import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/config/app_config.dart';
import 'app/theme/app_theme.dart';
import 'core/services/settings_service.dart';
import 'core/services/storage_service.dart';
import 'features/home/presentation/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterStorageService.init();
  SettingsService.load(); // read saved settings
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
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode(settings.theme),
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
          home: const NumCrossHomeScreen(),
        );
      },
    );
  }
}