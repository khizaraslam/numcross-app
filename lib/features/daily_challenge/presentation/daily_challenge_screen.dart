import 'package:flutter/material.dart';
import '../../../core/services/puzzle_generator.dart';
import '../../../core/services/storage_service.dart';
import '../../game/presentation/game_screen.dart';

class _C {
  static const bg = Color(0xFFF1F6FF);
  static const navy = Color(0xFF0F1F5C);
  static const blue = Color(0xFF1D6BF3);
  static const muted = Color(0xFF6B7A99);
  static const amber = Color(0xFFF59E0B);
  static const green = Color(0xFF22C55E);
}

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  static const _rewardXp = [50, 75, 100, 150, 200];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct',
    'Nov', 'Dec'
  ];

  late PlayerProfile _profile;
  late bool _todayDone;

  String get _todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  String get _todayLabel {
    final n = DateTime.now();
    return '${_months[n.month - 1]} ${n.day}, ${n.year}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _profile = FlutterStorageService.getProfile();
    _todayDone = FlutterStorageService.getDailyProgress()[_todayKey] == true;
  }

  // Levels finished today (3 = challenge complete)
  int get _levelsDone => _todayDone ? 3 : 0;

  // Which reward day (1..5) is "today" in the streak cycle
  int get _rewardDay => (_profile.currentStreak % 5) + 1;

  Future<void> _play() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NumCrossGameScreen(
          difficulty: PuzzleDifficulty.hard,
          levelTitle: 'Daily • $_todayLabel',
        ),
      ),
    );
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
                _missionCard(),
                const SizedBox(height: 18),
                _rewardsHeader(),
                const SizedBox(height: 10),
                _rewardsRow(),
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
                child: Text('Daily Challenge',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: _C.navy)),
              ),
              Text('Complete today\'s challenge and earn rewards!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _C.muted)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- Banner ----------------
  Widget _banner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 190,
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
            // clouds
            Positioned(top: 18, left: 14, child: _cloud(60)),
            Positioned(top: 30, right: 150, child: _cloud(44)),
            // green bushes
            Positioned(bottom: -30, left: -20, child: _bush(120)),
            Positioned(bottom: -40, right: -10, child: _bush(140)),
            // stars
            const Positioned(
                top: 40, left: 34, child: Text('⭐', style: TextStyle(fontSize: 22))),
            const Positioned(
                top: 28, left: 170, child: Text('⭐', style: TextStyle(fontSize: 18))),
            const Positioned(
                top: 70, left: 150, child: Text('✨', style: TextStyle(fontSize: 16))),
            // boy + trophy
            const Positioned(
                bottom: 6,
                left: 40,
                child: Text('👦', style: TextStyle(fontSize: 96))),
            const Positioned(
                bottom: 4,
                left: 125,
                child: Text('🏆', style: TextStyle(fontSize: 70))),
            // calendar card
            Positioned(
              right: 22,
              top: 22,
              child: Transform.rotate(
                angle: 0.12,
                child: Container(
                  width: 110,
                  height: 125,
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
                        height: 26,
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
                              fontSize: 14,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                              color: _C.navy)),
                      const SizedBox(height: 6),
                      const Icon(Icons.star_rounded,
                          color: _C.amber, size: 34),
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

  // ---------------- Mission card ----------------
  Widget _missionCard() {
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
                    Text('Complete 3 Levels',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: _C.navy)),
                    Text('Finish any 3 levels today',
                        style: TextStyle(fontSize: 12, color: _C.muted)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF6E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.hexagon_rounded,
                            color: _C.green, size: 38),
                        const Text('XP',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('+100 XP',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: _C.navy)),
                        Text('Reward',
                            style: TextStyle(fontSize: 10, color: _C.muted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _progressSteps(),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _todayDone ? null : _play,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFB7C6E4),
                disabledForegroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              icon: Icon(
                  _todayDone ? Icons.check_circle_rounded : Icons.play_arrow_rounded,
                  size: 32),
              label: Text(_todayDone ? 'Completed Today' : 'Play Now',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressSteps() {
    Widget step(int n) {
      final done = _levelsDone >= n;
      return SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? _C.blue : const Color(0xFFD5DEEF),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 24)
                    : Text('$n',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 4),
            Text('Level $n',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: done ? _C.blue : _C.muted)),
          ],
        ),
      );
    }

    Widget line(bool filled) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Container(
              height: 6,
              color: filled ? _C.blue : const Color(0xFFDCE5F5),
            ),
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        step(1),
        line(_levelsDone >= 2),
        step(2),
        line(_levelsDone >= 3),
        step(3),
      ],
    );
  }

  // ---------------- Rewards ----------------
  Widget _rewardsHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Daily Rewards',
            style: TextStyle(
                fontSize: 21, fontWeight: FontWeight.w900, color: _C.navy)),
        Row(
          children: [
            Text('View All',
                style: TextStyle(
                    color: _C.blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded, color: _C.blue, size: 18),
          ],
        ),
      ],
    );
  }

  Widget _rewardsRow() {
    return Row(
      children: List.generate(5, (i) {
        final day = i + 1;
        final isCurrent = day == _rewardDay && !_todayDone;
        final isDone = day < _rewardDay || (_todayDone && day == _rewardDay);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 4 ? 0 : 8),
            child: _rewardTile(day, _rewardXp[i], isDone, isCurrent),
          ),
        );
      }),
    );
  }

  Widget _rewardTile(int day, int xp, bool done, bool current) {
    Color bg;
    Color fg;
    Widget icon;
    Border? border;

    if (done) {
      bg = const Color(0xFFDDF6E8);
      fg = const Color(0xFF15803D);
      icon = Container(
        width: 38,
        height: 38,
        decoration:
            const BoxDecoration(color: _C.green, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
      );
    } else if (current) {
      bg = const Color(0xFFFFF1C9);
      fg = const Color(0xFF92400E);
      border = Border.all(color: const Color(0xFFFBBF24), width: 1.5);
      icon = const Text('🎁', style: TextStyle(fontSize: 34));
    } else {
      bg = const Color(0xFFE4EAF6);
      fg = _C.muted;
      icon = const Icon(Icons.lock_rounded, color: Color(0xFF8795B5), size: 32);
    }

    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: border,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Day $day',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: fg)),
          icon,
          Text('+$xp XP',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: fg)),
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
                    _profile.currentStreak > 0
                        ? '🔥 ${_profile.currentStreak} day streak. Complete daily challenges to earn bigger rewards!'
                        : 'Complete daily challenges to earn bigger rewards and maintain your streak.',
                    style: const TextStyle(
                        fontSize: 12, height: 1.3, color: _C.muted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _C.muted),
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