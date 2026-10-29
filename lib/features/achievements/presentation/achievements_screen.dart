import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

class _C {
  static const bg = Color(0xFFF1F6FF);
  static const navy = Color(0xFF0F1F5C);
  static const blue = Color(0xFF1D6BF3);
  static const muted = Color(0xFF6B7A99);
  static const green = Color(0xFF22C55E);
}

class _Ach {
  final String title;
  final String desc;
  final String category; // Learning | Streaks | Special | Gameplay
  final IconData icon;
  final Color color;
  final int current;
  final int target;

  const _Ach(this.title, this.desc, this.category, this.icon, this.color,
      this.current, this.target);

  bool get unlocked => current >= target;
  bool get started => current > 0;
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  static const _filters = ['All', 'Learning', 'Streaks', 'Special', 'Gameplay'];
  String _filter = 'All';

  late List<_Ach> _all;

  @override
  void initState() {
    super.initState();
    _all = _build();
  }

  // Every number here comes from the player's real saved progress.
  List<_Ach> _build() {
    final profile = FlutterStorageService.getProfile();
    final levels = FlutterStorageService.getLevels().values.toList();

    final completed = levels.where((l) => l.isCompleted).length;
    final threeStar = levels.where((l) => l.stars >= 3).length;
    int worldDone(int w) =>
        levels.where((l) => l.worldId == w && l.isCompleted).length;

    final streak = profile.bestStreak > profile.currentStreak
        ? profile.bestStreak
        : profile.currentStreak;

    const blue = Color(0xFF2B8CFF);
    const orange = Color(0xFFF97316);
    const purple = Color(0xFF7C3AED);
    const green = Color(0xFF22C55E);
    const pink = Color(0xFFEF4444);
    const gold = Color(0xFFF59E0B);
    const teal = Color(0xFF0EA5A5);

    return [
      // ---- Learning ----
      _Ach('First Step', 'Complete your first level', 'Learning',
          Icons.star_rounded, gold, completed, 1),
      _Ach('Knowledge Seeker', 'Complete 5 levels', 'Learning',
          Icons.menu_book_rounded, green, completed, 5),
      _Ach('Level Explorer', 'Complete 10 levels', 'Learning',
          Icons.bar_chart_rounded, purple, completed, 10),
      _Ach('Puzzle Pro', 'Complete 30 levels', 'Learning',
          Icons.extension_rounded, blue, completed, 30),
      _Ach('Math Legend', 'Complete 60 levels', 'Learning',
          Icons.workspace_premium_rounded, orange, completed, 60),
      _Ach('World Traveler', 'Complete all levels in World 1', 'Learning',
          Icons.public_rounded, teal, worldDone(1), 20),

      // ---- Streaks ----
      _Ach('3 Day Streak', 'Play for 3 days in a row', 'Streaks',
          Icons.local_fire_department_rounded, orange, streak, 3),
      _Ach('Week Warrior', 'Reach a 7 day streak', 'Streaks',
          Icons.whatshot_rounded, pink, streak, 7),
      _Ach('Fortnight Fire', 'Reach a 14 day streak', 'Streaks',
          Icons.bolt_rounded, gold, streak, 14),
      _Ach('Unstoppable', 'Reach a 30 day streak', 'Streaks',
          Icons.rocket_launch_rounded, purple, streak, 30),

      // ---- Special ----
      _Ach('Rising Star', 'Earn 50 stars', 'Special',
          Icons.emoji_events_rounded, blue, profile.totalStars, 50),
      _Ach('Star Collector', 'Earn 150 stars', 'Special',
          Icons.stars_rounded, gold, profile.totalStars, 150),
      _Ach('Level Up', 'Reach player level 5', 'Special',
          Icons.trending_up_rounded, green, profile.level, 5),
      _Ach('Veteran', 'Reach player level 10', 'Special',
          Icons.military_tech_rounded, purple, profile.level, 10),

      // ---- Gameplay ----
      _Ach('Perfect Level', 'Get 3 stars on a level', 'Gameplay',
          Icons.gps_fixed_rounded, pink, threeStar, 1),
      _Ach('Perfectionist', 'Get 3 stars on 10 levels', 'Gameplay',
          Icons.verified_rounded, orange, threeStar, 10),
      _Ach('Hard Mode', 'Complete 5 levels in World 3', 'Gameplay',
          Icons.fitness_center_rounded, blue, worldDone(3), 5),
      _Ach('Master Grid', 'Complete 5 levels in World 5', 'Gameplay',
          Icons.grid_view_rounded, purple, worldDone(5), 5),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _all.where((a) => a.unlocked).length;
    final shown =
        _filter == 'All' ? _all : _all.where((a) => a.category == _filter).toList();

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
                _progressBanner(unlocked, _all.length),
                const SizedBox(height: 14),
                _filterRow(),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 198,
                  ),
                  itemCount: shown.length,
                  itemBuilder: (_, i) => _card(shown[i]),
                ),
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
            Text('Achievements',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _C.navy)),
            Text('Complete goals and collect badges!',
                style: TextStyle(fontSize: 12, color: _C.muted)),
          ],
        ),
      ],
    );
  }

  // ---------------- Progress banner ----------------
  Widget _progressBanner(int unlocked, int total) {
    final pct = total == 0 ? 0 : ((unlocked / total) * 100).round();

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8CCBFF), Color(0xFFC9E8FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
                bottom: -30,
                left: -20,
                child: Container(
                  width: 190,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3DBE5C),
                    borderRadius: BorderRadius.circular(100),
                  ),
                )),
            const Positioned(
                bottom: 4,
                left: 12,
                child: Text('👦', style: TextStyle(fontSize: 88))),
            const Positioned(
                bottom: 6,
                left: 84,
                child: Text('🏆', style: TextStyle(fontSize: 64))),
            const Positioned(
                top: 14,
                left: 20,
                child: Text('⭐', style: TextStyle(fontSize: 18))),
            Positioned(
              right: 12,
              top: 14,
              bottom: 14,
              width: 190,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.93),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Progress',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _C.navy)),
                    Text('$unlocked/$total',
                        style: const TextStyle(
                            fontSize: 28,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                            color: _C.navy)),
                    const Text('Achievements Unlocked',
                        style: TextStyle(fontSize: 11, color: _C.muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : unlocked / total,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFDDE6F5),
                              valueColor:
                                  const AlwaysStoppedAnimation(_C.green),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('$pct%',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _C.muted)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Filter chips ----------------
  Widget _filterRow() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final selected = f == _filter;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _C.blue : const Color(0xFFDCE8FB),
                borderRadius: BorderRadius.circular(16),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: _C.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ]
                    : null,
              ),
              child: Text(f,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : _C.muted)),
            ),
          );
        },
      ),
    );
  }

  // ---------------- Achievement card ----------------
  Widget _card(_Ach a) {
    final locked = !a.unlocked && !a.started;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _shadow,
      ),
      child: Column(
        children: [
          _badge(a, locked),
          const SizedBox(height: 6),
          Text(a.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: _C.navy)),
          const SizedBox(height: 3),
          Text(a.desc,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 10.5, height: 1.2, color: _C.muted)),
          const Spacer(),
          _status(a, locked),
        ],
      ),
    );
  }

  Widget _badge(_Ach a, bool locked) {
    final color = locked ? const Color(0xFFB4BCCD) : a.color;
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (a.unlocked)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: a.color.withOpacity(0.35),
                      blurRadius: 18,
                      spreadRadius: 2),
                ],
              ),
            ),
          Icon(Icons.hexagon_rounded, color: color, size: 70),
          Icon(locked ? Icons.lock_rounded : a.icon,
              color: Colors.white, size: 30),
        ],
      ),
    );
  }

  Widget _status(_Ach a, bool locked) {
    if (a.unlocked) {
      return Container(
        height: 30,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFDDF6E8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: _C.green, size: 16),
            SizedBox(width: 4),
            Text('Unlocked',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D))),
          ],
        ),
      );
    }

    if (locked) {
      return Container(
        height: 30,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE9EDF5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, color: Color(0xFF8795B5), size: 15),
            SizedBox(width: 4),
            Text('Locked',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7E8DAE))),
          ],
        ),
      );
    }

    // in progress
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: a.current / a.target,
                minHeight: 7,
                backgroundColor: const Color(0xFFDDE6F5),
                valueColor: const AlwaysStoppedAnimation(_C.blue),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text('${a.current}/${a.target}',
              style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: _C.muted)),
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