import 'package:flutter/material.dart';
import '../../../core/services/puzzle_generator.dart';
import '../../../core/services/storage_service.dart';
import '../../game/presentation/game_screen.dart';
import '../../daily_challenge/presentation/daily_challenge_screen.dart';

class _C {
  static const bg = Color(0xFFF1F6FF);
  static const navy = Color(0xFF0F1F5C);
  static const blue = Color(0xFF1D6BF3);
  static const muted = Color(0xFF6B7A99);
  static const amber = Color(0xFFF59E0B);
  static const green = Color(0xFF22C55E);
}

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  late PlayerProfile _p;
  late bool _todayDone;
  late int _levelsCompleted;
  late int _levelsWith3Stars;

  String get _todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _p = FlutterStorageService.getProfile();
    _todayDone = FlutterStorageService.getDailyProgress()[_todayKey] == true;
    final levels = FlutterStorageService.getLevels().values;
    _levelsCompleted = levels.where((l) => l.isCompleted).length;
    _levelsWith3Stars = levels.where((l) => l.stars >= 3).length;
  }

  Future<void> _push(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
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
                _topBar(),
                const SizedBox(height: 14),
                _banner(),
                _dailyCard(),
                const SizedBox(height: 16),
                _endlessCard(),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Milestones',
                      style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: _C.navy)),
                ),
                const SizedBox(height: 10),
                _milestone('🎯', 'Complete 20 levels', _levelsCompleted, 20,
                    const Color(0xFFFFE4E8)),
                const SizedBox(height: 10),
                _milestone('⭐', 'Get 3 stars on 10 levels', _levelsWith3Stars,
                    10, const Color(0xFFFFF1C9)),
                const SizedBox(height: 10),
                _milestone('🔥', 'Reach a 5 day streak', _p.currentStreak, 5,
                    const Color(0xFFFFE9D6)),
                const SizedBox(height: 16),
                _streakCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Top bar ----------------
  Widget _topBar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (Navigator.of(context).canPop())
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 46,
                height: 46,
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
        const Column(
          children: [
            Text('Challenges',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _C.navy)),
            SizedBox(height: 2),
            Text('Take on challenges and keep improving!',
                style: TextStyle(fontSize: 12, color: _C.muted)),
          ],
        ),
      ],
    );
  }

  // ---------------- Banner ----------------
  Widget _banner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 170,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8CCBFF), Color(0xFFDFF1FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: 16, left: 14, child: _cloud(60)),
            Positioned(top: 28, right: 150, child: _cloud(44)),
            Positioned(bottom: -30, left: -20, child: _bush(120)),
            Positioned(bottom: -40, right: -10, child: _bush(140)),
            const Positioned(
                top: 34,
                left: 34,
                child: Text('⭐', style: TextStyle(fontSize: 22))),
            const Positioned(
                top: 24,
                left: 170,
                child: Text('⭐', style: TextStyle(fontSize: 18))),
            const Positioned(
                bottom: 4,
                left: 40,
                child: Text('👦', style: TextStyle(fontSize: 90))),
            const Positioned(
                bottom: 2,
                left: 122,
                child: Text('🏆', style: TextStyle(fontSize: 64))),
            Positioned(
              right: 22,
              top: 16,
              child: Transform.rotate(
                angle: 0.12,
                child: Container(
                  width: 104,
                  height: 118,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Today\'s\nChallenge',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                              color: _C.navy)),
                      const SizedBox(height: 4),
                      const Icon(Icons.star_rounded,
                          color: _C.amber, size: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cloud(double w) => Container(
        width: w,
        height: w * 0.45,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(40),
        ),
      );

  Widget _bush(double w) => Container(
        width: w,
        height: w * 0.8,
        decoration: BoxDecoration(
          color: const Color(0xFF3DBE5C),
          borderRadius: BorderRadius.circular(w),
        ),
      );

  // ---------------- Daily card ----------------
  Widget _dailyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: _shadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                    child: Text('🎯', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Challenge',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: _C.navy)),
                    Text('A new puzzle every day',
                        style: TextStyle(fontSize: 12, color: _C.muted)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _todayDone
                      ? const Color(0xFFDDF6E8)
                      : const Color(0xFFE3EDFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(_todayDone ? '✅ Done' : 'Ready',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _todayDone
                            ? const Color(0xFF15803D)
                            : _C.blue)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _push(const DailyChallengeScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.blue,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 32),
              label: const Text('Play Now',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Endless mode ----------------
  Widget _endlessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF9333EA)]),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          const Text('♾️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 6),
          const Text('Endless Mode',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Solve continuous puzzles with increasing difficulty',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _statBox('Best Streak', '${_p.bestStreak}')),
              const SizedBox(width: 10),
              Expanded(
                  child: _statBox('Levels Solved', '${_p.completedCount}')),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6366F1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _push(const NumCrossGameScreen(
                difficulty: PuzzleDifficulty.medium,
                levelTitle: 'Endless Mode',
              )),
              child: const Text('Start Endless Mode',
                  style:
                      TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String title, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  // ---------------- Milestones ----------------
  Widget _milestone(
      String emoji, String title, int curr, int target, Color tint) {
    final value = (curr / target).clamp(0.0, 1.0);
    final done = curr >= target;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _shadow,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: tint, borderRadius: BorderRadius.circular(14)),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: _C.navy)),
                    ),
                    Text(done ? '✅' : '${curr > target ? target : curr}/$target',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _C.blue,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFDFE9FA),
                    valueColor: AlwaysStoppedAnimation(
                        done ? _C.green : _C.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Streak card ----------------
  Widget _streakCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _shadow,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 84,
            child: Center(child: Text('🏆', style: TextStyle(fontSize: 60))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Keep the Streak!',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: _C.navy)),
                const SizedBox(height: 4),
                Text(
                    _p.currentStreak > 0
                        ? '🔥 ${_p.currentStreak} day streak. Complete daily challenges to keep it going!'
                        : 'Complete daily challenges to build your streak.',
                    style: const TextStyle(
                        fontSize: 12, height: 1.3, color: _C.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<BoxShadow> get _shadow => [
        BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4)),
      ];
}