import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../../levels/presentation/levels_screen.dart';

class _C {
  static const navy = Color(0xFF0F1F5C);
  static const blue = Color(0xFF1D6BF3);
  static const muted = Color(0xFF6B7A99);
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  // ---- Data that the app does not track yet (shows empty until you add tracking) ----
  static const int _minutesPlayed = 0;
  static const List<int> _weeklyMinutes = [0, 0, 0, 0, 0, 0, 0]; // Mon..Sun
  static const int _correct = 0;
  static const int _incorrect = 0;
  static const int _skipped = 0;

  static const _worldColors = [
    Color(0xFF1D6BF3),
    Color(0xFF22C55E),
    Color(0xFFF97316),
    Color(0xFF7C3AED),
    Color(0xFFEC4899),
  ];

  String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final profile = FlutterStorageService.getProfile();
    final levels = FlutterStorageService.getLevels();

    // per-world completed count + overall numbers
    final worldDone = List<int>.filled(5, 0);
    int completed = 0;
    int starsSum = 0;
    for (final l in levels.values) {
      if (l.isCompleted) {
        completed++;
        starsSum += l.stars;
        if (l.worldId >= 1 && l.worldId <= 5) worldDone[l.worldId - 1]++;
      }
    }

    // Total XP earned (same formula as storage_service.addXP)
    int totalXp = profile.xp;
    for (int l = 1; l < profile.level; l++) {
      totalXp += l * 100 + 400;
    }

    // Accuracy = how many of the possible stars were earned
    final accuracy =
        completed > 0 ? ((starsSum / (completed * 3)) * 100).round() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F0FF), Color(0xFFF7FAFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                _topBar(context),
                const SizedBox(height: 14),
                _scoreBanner(totalXp, profile.level),
                const SizedBox(height: 14),
                _statTiles(profile.totalStars, completed, accuracy,
                    profile.currentStreak),
                const SizedBox(height: 14),
                _levelProgress(context, worldDone),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _timeCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _performanceCard(accuracy)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Top bar ----------------
Widget _topBar(BuildContext context) {
  return Stack(
    alignment: Alignment.center,
    children: [
      if (Navigator.of(context).canPop())
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _shadow,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _C.blue, size: 20),
            ),
          ),
        ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 56),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Statistics',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _C.navy)),
            ),
            Text('Track your progress and see how you\'re doing!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: _C.muted)),
          ],
        ),
      ),
    ],
  );
}

  // ---------------- Score banner ----------------
  Widget _scoreBanner(int totalXp, int level) {
    return Container(
      height: 130,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B8CFF), Color(0xFF5BB6FF)],
        ),
        boxShadow: [
          BoxShadow(
              color: _C.blue.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.bar_chart_rounded,
                color: Color(0xFF3B9BFF), size: 44),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Score',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(_fmt(totalXp),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          height: 1.1,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFF7DD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_upward_rounded,
                          size: 14, color: Color(0xFF15803D)),
                      const SizedBox(width: 3),
                      Text('Level $level',
                          style: const TextStyle(
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.w800,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Text('🏆', style: TextStyle(fontSize: 54)),
          const Text('👦', style: TextStyle(fontSize: 62)),
        ],
      ),
    );
  }

  // ---------------- 4 stat tiles ----------------
  Widget _statTiles(int stars, int completed, int accuracy, int streak) {
    return Row(
      children: [
        _tile('⭐', '$stars', 'Total Stars', const Color(0xFFFFF4D6)),
        const SizedBox(width: 10),
        _tile('🏆', '$completed', 'Levels\nCompleted', const Color(0xFFE4EEFF)),
        const SizedBox(width: 10),
        _tile('🎯', '$accuracy%', 'Accuracy', const Color(0xFFFFE6EA)),
        const SizedBox(width: 10),
        _tile('🔥', '$streak', 'Day Streak', const Color(0xFFDDF6E8)),
      ],
    );
  }

  Widget _tile(String emoji, String value, String label, Color bg) {
    return Expanded(
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _shadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: _C.navy)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, height: 1.1, color: _C.muted)),
          ],
        ),
      ),
    );
  }

  // ---------------- Level progress ----------------
  Widget _levelProgress(BuildContext context, List<int> worldDone) {
    void openLevels() => Navigator.push(
        context, MaterialPageRoute(builder: (_) => const LevelsScreen()));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Level Progress',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _C.navy)),
              GestureDetector(
                onTap: openLevels,
                child: const Row(
                  children: [
                    Text('View All Levels',
                        style: TextStyle(
                            color: _C.blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded,
                        color: _C.blue, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < 5; i++) _worldRow(i, worldDone[i], openLevels),
        ],
      ),
    );
  }

  Widget _worldRow(int i, int done, VoidCallback onTap) {
    const total = 20;
    final color = _worldColors[i];
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.hexagon_rounded, color: color, size: 40),
                  Text('${i + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 64,
              child: Text('World ${i + 1}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.navy)),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: done / total,
                  minHeight: 9,
                  backgroundColor: const Color(0xFFDFE9FA),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 44,
              child: Text('$done/$total',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.navy)),
            ),
            const Icon(Icons.chevron_right_rounded, color: _C.muted, size: 20),
          ],
        ),
      ),
    );
  }

  // ---------------- Time played ----------------
  Widget _timeCard() {
    final h = _minutesPlayed ~/ 60;
    final m = _minutesPlayed % 60;
    final maxV = _weeklyMinutes.reduce(math.max);
    final todayIdx = DateTime.now().weekday - 1; // Mon=0
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EEFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.timer_outlined,
                    color: _C.blue, size: 22),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text('Time Played',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _C.navy)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('${h}h ${m}m',
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w900, color: _C.navy)),
          const Text('Total Play Time',
              style: TextStyle(fontSize: 12, color: _C.muted)),
          const Spacer(),
          SizedBox(
            height: 92,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final v = _weeklyMinutes[i];
                final double barH = 8 + (maxV == 0 ? 0.0 : (v / maxV) * 62);
                final isToday = i == todayIdx;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: barH,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isToday
                              ? _C.blue
                              : const Color(0xFF8EC5FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(days[i],
                          style: const TextStyle(
                              fontSize: 8.5, color: _C.muted)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Performance ----------------
  Widget _performanceCard(int accuracy) {
    final total = _correct + _incorrect + _skipped;
    final values = total > 0
        ? [_correct.toDouble(), _incorrect.toDouble(), _skipped.toDouble()]
        : [accuracy.toDouble(), 0.0, (100 - accuracy).toDouble()];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6EA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: Color(0xFFEF4444), size: 22),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text('Performance',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _C.navy)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: 96,
              height: 96,
              child: CustomPaint(
                painter: _DonutPainter(
                  values: values,
                  colors: const [
                    Color(0xFF22C55E),
                    Color(0xFFFB7185),
                    Color(0xFFD6DEEE),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$accuracy%',
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: _C.navy)),
                      const Text('Accuracy',
                          style: TextStyle(fontSize: 9, color: _C.navy)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          _legend(const Color(0xFF22C55E), 'Correct', _correct),
          _legend(const Color(0xFFFB7185), 'Incorrect', _incorrect),
          _legend(const Color(0xFFD6DEEE), 'Skipped', _skipped),
        ],
      ),
    );
  }

  Widget _legend(Color c, String label, int v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: _C.muted)),
          ),
          Text('$v',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _C.navy)),
        ],
      ),
    );
  }

  // ---------------- Helpers ----------------
  List<BoxShadow> get _shadow => [
        BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4)),
      ];

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _shadow,
      );
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 13.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFE4EAF6);
    canvas.drawArc(rect, 0, 2 * math.pi, false, base);

    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;

    double start = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweep = values[i] / total * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = colors[i];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.values != values || old.colors != colors;
}