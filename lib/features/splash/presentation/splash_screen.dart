import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/storage_service.dart';
import '../../home/presentation/home_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';

class _C {
  static const navy = Color(0xFF0F1F5C);
  static const blue = Color(0xFF1D6BF3);
  static const muted = Color(0xFF6B7A99);
  static const green = Color(0xFF2DD4A0);
  static const yellow = Color(0xFFFFC83D);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // logo pop-in + text fade
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));

  // gentle floating of the tiles
  late final AnimationController _float = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400))
    ..repeat(reverse: true);

  // loading bar (0 -> 1)
  late final AnimationController _progress = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600));

  @override
  void initState() {
    super.initState();
    _intro.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    _startLoading();
  }

  @override
  void dispose() {
    _intro.dispose();
    _float.dispose();
    _progress.dispose();
    super.dispose();
  }

  /// This is where "loading" happens.
  /// 1) real work: read the saved data once so Home opens instantly
  /// 2) the bar fills while that runs
  /// 3) when it is full, we go to the Home screen
  Future<void> _startLoading() async {
    final bar = _progress.forward(); // start the bar

    // ---- real warm-up work (add more here later: sounds, ads, login...) ----
    SettingsService.load();
    FlutterStorageService.getProfile();
    FlutterStorageService.getLevels();
    FlutterStorageService.getSavedGame();
    // -------------------------------------------------------------------------

    await bar.orCancel.catchError((_) {}); // wait until the bar is full
    if (!mounted) return;

    final Widget next = FlutterStorageService.getSettings().onboardingCompleted
        ? const NumCrossHomeScreen()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightOverlay,
      child: Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF1F7FF)],
          ),
        ),
        child: Stack(
          children: [
            _background(),
            _centerContent(),
            _bottomTiles(),
            _loadingBar(),
          ],
        ),
      ),
    ));
  }

  // ---------------- Background ----------------
  Widget _background() {
    return Positioned.fill(
      child: Stack(
        children: [
          // soft blobs
          Positioned(
              top: -90,
              right: -70,
              child: _circle(230, const Color(0xFFE4EFFF))),
          Positioned(
              top: -40,
              left: -90,
              child: _circle(230, const Color(0xFFEFEAFF))),
          Positioned(
              bottom: -120,
              left: -80,
              child: _circle(420, const Color(0xFFE6F0FF))),
          Positioned(
              bottom: -150,
              right: -100,
              child: _circle(380, const Color(0xFFE8F6F3))),

          // faded decorative tiles
          Positioned(
              top: 50,
              left: 8,
              child: _faded('+', 78, const Color(0xFFB9B2F5), -0.2)),
          Positioned(
              top: 120,
              right: 18,
              child: _faded('3', 62, const Color(0xFFB3CCF7), 0.3)),
          Positioned(
              top: 300,
              left: -8,
              child: _faded('7', 58, const Color(0xFFB3CCF7), -0.2)),
          Positioned(
              top: 360,
              right: -14,
              child: _faded('2', 82, const Color(0xFFD2C4F3), 0.3)),
        ],
      ),
    );
  }

  Widget _circle(double d, Color c) => Container(
        width: d,
        height: d,
        decoration: BoxDecoration(color: c.withOpacity(0.7), shape: BoxShape.circle),
      );

  Widget _faded(String t, double size, Color c, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Opacity(
        opacity: 0.35,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.withOpacity(0.35),
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Text(t,
              style: TextStyle(
                  fontSize: size * 0.5,
                  fontWeight: FontWeight.w900,
                  color: c)),
        ),
      ),
    );
  }

  // ---------------- Center: logo + title ----------------
  Widget _centerContent() {
    final pop = CurvedAnimation(parent: _intro, curve: Curves.elasticOut);
    final fade = CurvedAnimation(
        parent: _intro, curve: const Interval(0.35, 1.0, curve: Curves.easeOut));

    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 190),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(scale: pop, child: _logo()),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: fade,
                  child: Column(
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              fontSize: 58,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.5),
                          children: [
                            TextSpan(
                                text: 'Num', style: TextStyle(color: _C.navy)),
                            TextSpan(
                                text: 'Cross',
                                style: TextStyle(color: _C.blue)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text('MATH PUZZLE',
                          style: TextStyle(
                              fontSize: 19,
                              letterSpacing: 7,
                              fontWeight: FontWeight.w500,
                              color: _C.navy)),
                      const SizedBox(height: 22),
                      const Text('Train Your Brain\nOne Equation at a Time',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17,
                              height: 1.35,
                              color: _C.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    Widget tile(String t,
        {Color bg = Colors.white,
        Color fg = _C.navy,
        double w = 62,
        double fs = 34,
        List<Color>? gradient}) {
      return Container(
        width: w,
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gradient == null ? bg : null,
          gradient: gradient == null
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradient),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 8, offset: Offset(0, 5))
          ],
        ),
        child: Text(t,
            style: TextStyle(
                fontSize: fs, fontWeight: FontWeight.w900, color: fg)),
      );
    }

    Widget spark(double angle) => Transform.rotate(
          angle: angle,
          child: Container(
            width: 30,
            height: 9,
            decoration: BoxDecoration(
              color: _C.yellow,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

    return SizedBox(
      width: 260,
      height: 240,
      child: Stack(
        children: [
          // blue blob
          Positioned(
            left: 18,
            top: 30,
            child: Container(
              width: 226,
              height: 196,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF63BFFF), Color(0xFF2B7CF5)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(70),
                  topRight: Radius.circular(110),
                  bottomLeft: Radius.circular(120),
                  bottomRight: Radius.circular(80),
                ),
              ),
            ),
          ),
          // sparkles
          Positioned(top: 18, left: 28, child: spark(0.45)),
          Positioned(top: 2, left: 68, child: spark(1.1)),
          Positioned(top: 4, right: 62, child: spark(-1.1)),
          Positioned(top: 22, right: 22, child: spark(-0.4)),
          // tiles
          Positioned(top: 38, left: 100, child: tile('8')),
          Positioned(
              top: 104,
              left: 30,
              child: tile('+', fg: _C.blue, fs: 40)),
          Positioned(
              top: 100,
              left: 92,
              child: tile('×',
                  fg: Colors.white,
                  fs: 36,
                  gradient: const [Color(0xFF3B8DF5), Color(0xFF1D6BF3)])),
          Positioned(
              top: 94,
              left: 148,
              child: tile('=',
                  fg: Colors.white,
                  fs: 36,
                  gradient: const [Color(0xFF4FE3B2), Color(0xFF1FC98E)])),
          Positioned(
              top: 88,
              left: 196,
              child: tile('12', w: 64, fs: 26)),
          Positioned(top: 160, left: 108, child: tile('3')),
        ],
      ),
    );
  }

  // ---------------- Bottom big tiles ----------------
  Widget _bottomTiles() {
    Widget big(String t, double size, Color fg, double angle,
        {List<Color>? gradient, Color bg = Colors.white}) {
      return Transform.rotate(
        angle: angle,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: gradient == null ? bg : null,
            gradient: gradient == null
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradient),
            borderRadius: BorderRadius.circular(size * 0.24),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 8))
            ],
          ),
          child: Text(t,
              style: TextStyle(
                  fontSize: size * 0.5,
                  fontWeight: FontWeight.w900,
                  color: fg)),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _float,
      builder: (context, _) {
        final dy = math.sin(_float.value * math.pi) * 8;
        return Stack(
          children: [
            // left: blue 4 + white +
            Positioned(
              left: -26,
              bottom: 112 + dy,
              child: big('4', 110, Colors.white, -0.12,
                  gradient: const [Color(0xFF3B8DF5), Color(0xFF1D6BF3)]),
            ),
            Positioned(
              left: 72,
              bottom: 100 - dy,
              child: big('+', 74, _C.blue, 0.18),
            ),
            // right: white 7 + green =
            Positioned(
              right: 78,
              bottom: 106 + dy,
              child: big('7', 76, _C.navy, 0.14),
            ),
            Positioned(
              right: -22,
              bottom: 116 - dy,
              child: big('=', 104, Colors.white, 0.1,
                  gradient: const [Color(0xFF4FE3B2), Color(0xFF1FC98E)]),
            ),
          ],
        );
      },
    );
  }

  // ---------------- Loading bar ----------------
  Widget _loadingBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 40,
      child: Column(
        children: [
          FractionallySizedBox(
            widthFactor: 0.62,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  final v = Curves.easeInOut.transform(_progress.value);
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: v.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF2B7CF5), Color(0xFF1D6BF3)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Loading...',
              style: TextStyle(fontSize: 14, color: _C.muted)),
        ],
      ),
    );
  }
}