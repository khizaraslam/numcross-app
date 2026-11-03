import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';
import '../../home/presentation/home_screen.dart';

// Local colors (so this file works standalone)
class _C {
  static const navy = Color(0xFF0F1F5C);
  static const blue = Color(0xFF1D6BF3);
  static const blueLight = Color(0xFF5B9BFF);
  static const muted = Color(0xFF6B7A99);
  static const amber = Color(0xFFFBBF24);
}

class _Slide {
  final String lead;
  final String accent;
  final String desc;
  final Widget Function() art;
  const _Slide(this.lead, this.accent, this.desc, this.art);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // All illustrations are drawn in code: no images, no baked-in buttons
  // or top bars.
  late final List<_Slide> _slides = [
    _Slide(
      'Solve',
      'Smart',
      'Complete intersecting math equations and train your brain with original cross-math puzzles.',
      _solveArt,
    ),
    _Slide(
      'Play',
      'Anywhere',
      'Thousands of puzzles available even when you are completely offline. No connection needed.',
      _playArt,
    ),
    _Slide(
      'Challenge',
      'Yourself',
      'Build streaks, complete daily challenges, and climb the global leaderboards.',
      _challengeArt,
    ),
  ];

  Future<void> _finishOnboarding() async {
    SettingsService.tap();
    await SettingsService.update((s) => s.onboardingCompleted = true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const NumCrossHomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _next() {
    SettingsService.tap();
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _back() {
    SettingsService.tap();
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 4),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlueDark,
                    backgroundColor: const Color(0xFFE8F1FF),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${slide.lead} ',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textMain,
                                ),
                              ),
                              TextSpan(
                                text: slide.accent,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          slide.desc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: 340,
                              height: 340,
                              child: slide.art(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (idx) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: idx == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: idx == _currentPage
                              ? AppColors.primaryBlue
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _back,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textMuted,
                                side: const BorderSide(
                                    color: Color(0xFFD7E3F7)),
                                backgroundColor: const Color(0xFFF0F4FA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _next,
                            child: Text(
                              isLast ? 'Get Started →' : 'Next →',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  //  ILLUSTRATIONS (design size 340 x 340, scaled to fit automatically)
  // =====================================================================

  Widget _blob(double size) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFE3EEFF),
          shape: BoxShape.circle,
        ),
      );

  Widget _sparkle(double size) => Text('✦',
      style: TextStyle(color: _C.amber, fontSize: size, height: 1));

  Widget _leaf() => Container(
        width: 44,
        height: 92,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF34D399), Color(0xFF059669)],
          ),
          borderRadius: const BorderRadius.all(Radius.elliptical(22, 46)),
        ),
      );

  Widget _floatTile({
    required Widget child,
    required List<Color> colors,
    double size = 58,
    double angle = 0,
  }) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _symbol(String t, {Color color = Colors.white, double size = 30}) =>
      Text(t,
          style: TextStyle(
              color: color,
              fontSize: size,
              fontWeight: FontWeight.w900,
              height: 1));

  // ---------- Slide 1: Solve Smart (math grid) ----------
  Widget _solveArt() {
    // 0 = number, 1 = input box, 2 = empty
    Widget cell(String t, int kind) {
      Color bg;
      BoxBorder? border;
      switch (kind) {
        case 1:
          bg = const Color(0xFFCFE2FF);
          border = Border.all(color: _C.blue, width: 2);
          break;
        case 2:
          bg = const Color(0xFFE6EEFB);
          break;
        default:
          bg = Colors.white;
      }
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          border: border,
          borderRadius: BorderRadius.circular(10),
          boxShadow: kind == 0
              ? const [
                  BoxShadow(
                      color: Color(0x1A1D4ED8),
                      blurRadius: 3,
                      offset: Offset(0, 2))
                ]
              : null,
        ),
        child: Text(t,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: _C.navy)),
      );
    }

    const rows = [
      [('8', 0), ('+', 0), ('', 1), ('=', 0), ('14', 0)],
      [('', 2), ('−', 0), ('', 2), ('×', 0), ('', 2)],
      [('', 1), ('3', 0), ('4', 0), ('=', 0), ('', 1)],
      [('', 2), ('=', 0), ('', 2), ('=', 0), ('', 2)],
      [('11', 0), ('+', 0), ('', 1), ('=', 0), ('19', 0)],
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: Center(child: _blob(310))),
        Positioned(
            left: 4,
            top: 190,
            child: Transform.rotate(angle: -0.5, child: _leaf())),
        Positioned(
            right: 2,
            top: 120,
            child: Transform.rotate(angle: 0.5, child: _leaf())),
        // board
        Positioned(
          left: 50,
          top: 52,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8DBBFF), Color(0xFF4F8DF7)],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                    color: _C.blue.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int r = 0; r < rows.length; r++) ...[
                  if (r > 0) const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int c = 0; c < rows[r].length; c++) ...[
                        if (c > 0) const SizedBox(width: 5),
                        cell(rows[r][c].$1, rows[r][c].$2),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        // floating tiles
        Positioned(
          left: 0,
          top: 10,
          child: _floatTile(
            colors: const [Color(0xFF5B9BFF), Color(0xFF1D6BF3)],
            size: 62,
            angle: -0.15,
            child: _symbol('+', size: 36),
          ),
        ),
        Positioned(
          right: 6,
          top: 0,
          child: _floatTile(
            colors: const [Colors.white, Color(0xFFEFF5FF)],
            size: 54,
            angle: 0.2,
            child: _symbol('3', color: _C.blue, size: 28),
          ),
        ),
        Positioned(
          right: 0,
          top: 218,
          child: _floatTile(
            colors: const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
            size: 56,
            angle: 0.15,
            child: _symbol('÷', size: 30),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 6,
          child: _floatTile(
            colors: const [Color(0xFF4ADE80), Color(0xFF16A34A)],
            size: 62,
            angle: -0.1,
            child: _symbol('=', size: 34),
          ),
        ),
        Positioned(left: 18, top: 118, child: _sparkle(20)),
        Positioned(right: 78, top: 8, child: _sparkle(22)),
        Positioned(right: 18, bottom: 4, child: _sparkle(26)),
      ],
    );
  }

  // ---------- Slide 2: Play Anywhere (levels, offline) ----------
  Widget _playArt() {
    Widget doneTile(int n) => Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF5B9BFF), Color(0xFF1D6BF3)],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$n',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      height: 1.1)),
              const SizedBox(height: 2),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded, size: 9, color: _C.amber),
                  Icon(Icons.star_rounded, size: 9, color: _C.amber),
                  Icon(Icons.star_rounded, size: 9, color: _C.amber),
                ],
              ),
            ],
          ),
        );

    Widget currentTile(int n) => Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _C.blue, width: 2.5),
          ),
          child: Text('$n',
              style: const TextStyle(
                  color: _C.blue, fontSize: 17, fontWeight: FontWeight.w900)),
        );

    Widget lockedTile() => Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FA),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.lock_rounded,
              size: 18, color: Color(0xFFA8B5CE)),
        );

    final tiles = <Widget>[
      doneTile(1),
      doneTile(2),
      doneTile(3),
      currentTile(4),
      for (int i = 0; i < 8; i++) lockedTile(),
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: Center(child: _blob(310))),
        Positioned(
            left: 2,
            top: 200,
            child: Transform.rotate(angle: -0.5, child: _leaf())),
        Positioned(
            right: 0,
            top: 110,
            child: Transform.rotate(angle: 0.5, child: _leaf())),
        // levels card
        Positioned(
          left: 48,
          top: 62,
          child: Container(
            width: 244,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                    color: _C.blue.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('World 1',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: _C.navy)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF8E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Easy',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A))),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 8, children: tiles),
              ],
            ),
          ),
        ),
        // offline badge
        Positioned(
          right: 0,
          top: 18,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _C.navy,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: _C.navy.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('Works Offline',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 22,
          child: _floatTile(
            colors: const [Colors.white, Color(0xFFEFF5FF)],
            size: 56,
            angle: -0.15,
            child: const Icon(Icons.airplanemode_active_rounded,
                color: _C.blue, size: 30),
          ),
        ),
        Positioned(
          left: 2,
          bottom: 14,
          child: _floatTile(
            colors: const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
            size: 58,
            angle: -0.1,
            child: _symbol('×', size: 32),
          ),
        ),
        Positioned(
          right: 4,
          bottom: 22,
          child: _floatTile(
            colors: const [Color(0xFF5B9BFF), Color(0xFF1D6BF3)],
            size: 58,
            angle: 0.15,
            child: _symbol('7', size: 30),
          ),
        ),
        Positioned(left: 20, top: 130, child: _sparkle(20)),
        Positioned(right: 70, bottom: 4, child: _sparkle(22)),
        Positioned(right: 16, top: 150, child: _sparkle(18)),
      ],
    );
  }

  // ---------- Slide 3: Challenge Yourself ----------
  Widget _challengeArt() {
    Widget chip(String label, List<Color> colors, double angle) {
      return Transform.rotate(
        angle: angle,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: colors.last.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded,
                    size: 18, color: colors.last),
              ),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: Center(child: _blob(310))),
        // trophy
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 112,
              height: 112,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF3C4), Color(0xFFFDE68A)],
                ),
                boxShadow: [
                  BoxShadow(
                      color: _C.amber.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: const Text('🏆', style: TextStyle(fontSize: 64)),
            ),
          ),
        ),
        // checklist chips
        Positioned(
          left: 32,
          right: 32,
          top: 132,
          child: Column(
            children: [
              chip('Puzzles',
                  const [Color(0xFF34D399), Color(0xFF16A34A)], -0.025),
              const SizedBox(height: 9),
              chip('Daily Challenge',
                  const [Color(0xFF5B9BFF), Color(0xFF1D6BF3)], 0.025),
              const SizedBox(height: 9),
              chip('Build Streaks',
                  const [Color(0xFFA78BFA), Color(0xFF7C3AED)], -0.025),
              const SizedBox(height: 9),
              chip('Climb Leaderboard',
                  const [Color(0xFFFB7185), Color(0xFFE11D48)], 0.025),
            ],
          ),
        ),
        // floating tiles
        Positioned(
          left: 4,
          top: 34,
          child: _floatTile(
            colors: const [Color(0xFFFBBF24), Color(0xFFF97316)],
            size: 56,
            angle: -0.15,
            child: const Text('🔥', style: TextStyle(fontSize: 30)),
          ),
        ),
        Positioned(
          right: 4,
          top: 34,
          child: _floatTile(
            colors: const [Colors.white, Color(0xFFEFF5FF)],
            size: 56,
            angle: 0.15,
            child: const Text('⭐', style: TextStyle(fontSize: 30)),
          ),
        ),
        Positioned(left: 108, top: 2, child: _sparkle(18)),
        Positioned(right: 100, top: 10, child: _sparkle(22)),
        Positioned(right: 12, bottom: 12, child: _sparkle(24)),
        Positioned(left: 12, bottom: 20, child: _sparkle(18)),
      ],
    );
  }
}