import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../../app/config/app_config.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/storage_service.dart';
import '../../home/presentation/home_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';

/// Brand blue used by the native splash / app icon background.
const Color _splashBg = Color(0xFF002C92);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.15;
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    _startLoading();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  Future<void> _startLoading() async {
    for (int i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      setState(() => _progress = (_progress + 0.2).clamp(0.0, 1.0));
    }

    if (!mounted) return;
    final settings = FlutterStorageService.getSettings();
    final next = settings.onboardingCompleted
        ? const NumCrossHomeScreen()
        : const OnboardingScreen();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Status bar follows the phone theme (light/dark), not brand blue.
    final systemDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final overlay =
        systemDark ? AppTheme.darkOverlay : AppTheme.lightOverlay;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: _splashBg,
        body: FadeTransition(
          opacity: _fade,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // True optical center — independent of bottom loader.
              Center(
                child: Image.asset(
                  AppConfig.splashLogoAsset,
                  width: MediaQuery.sizeOf(context).width * 0.58,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    AppConfig.logoAsset,
                    width: MediaQuery.sizeOf(context).width * 0.5,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const _LogoFallback(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 200,
                            height: 8,
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.grid_4x4_rounded, size: 80, color: Colors.white),
        SizedBox(height: 12),
        Text(
          'NumCross',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          'MATH PUZZLE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
