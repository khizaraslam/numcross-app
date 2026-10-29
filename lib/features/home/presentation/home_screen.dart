import 'package:flutter/material.dart';
import '../../../core/services/puzzle_generator.dart';
import '../../../core/services/storage_service.dart';
import '../../game/presentation/game_screen.dart';
import '../../levels/presentation/levels_screen.dart';
import '../../daily_challenge/presentation/daily_challenge_screen.dart';
import '../../challenges/presentation/challenges_screen.dart';
import '../../statistics/presentation/statistics_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../leaderboard/presentation/leaderboard_screen.dart';
import '../../settings/presentation/settings_screen.dart';

// ---------- Colors (local so the file works standalone) ----------
class _C {
  static const bg = Color(0xFFF1F6FF);
  static const navy = Color(0xFF0F1F5C);
  static const blue = Color(0xFF2563EB);
  static const muted = Color(0xFF6B7A99);
  static const amber = Color(0xFFF59E0B);
}

class NumCrossHomeScreen extends StatefulWidget {
  const NumCrossHomeScreen({super.key});

  @override
  State<NumCrossHomeScreen> createState() => _NumCrossHomeScreenState();
}

class _NumCrossHomeScreenState extends State<NumCrossHomeScreen> {
  int _tab = 0;

  PlayerProfile _p = FlutterStorageService.getProfile();

  int get level => _p.level;
  int get xp => _p.xp;
  int get xpMax => _p.level * 100 + 400;
  int get streak => _p.currentStreak;
  int get totalStars => _p.totalStars;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _homeBody(),
      const ChallengesScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: _C.bg,
      body: pages[_tab],
      bottomNavigationBar: _bottomNav(),
    );
  }

  // Home tab content
  Widget _homeBody() {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F1FF), Color(0xFFF7FAFF)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 16),
                _levelCard(),
                const SizedBox(height: 16),
                _playBanner(),
                const SizedBox(height: 18),
                _difficultyHeader(),
                const SizedBox(height: 10),
                _difficultyRow(),
                const SizedBox(height: 16),
                _dailyChallengeCard(),
                const SizedBox(height: 14),
                if (FlutterStorageService.getSavedGame() != null) ...[
                  _continueCard(),
                  const SizedBox(height: 14),
                ],
                _quickTiles(),
              ],
            ),
          ),
        ),
      );
  }

  Future<void> _openGame(PuzzleDifficulty d,
      {Map<String, dynamic>? resume}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => NumCrossGameScreen(difficulty: d, resume: resume)),
    );
    // game se wapas aane par XP / stars / streak refresh
    if (mounted) {
      setState(() => _p = FlutterStorageService.getProfile());
    }
  }

  Future<void> _push(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) {
      setState(() => _p = FlutterStorageService.getProfile());
    }
  }

  // ---------------- Header ----------------
  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _push(const ProfileScreen()),
          child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF3B82F6),
            border: Border.all(color: _C.blue, width: 2.5),
          ),
          child: const Center(child: Text('👦', style: TextStyle(fontSize: 28))),
        )),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5),
                  children: [
                    TextSpan(text: 'Num', style: TextStyle(color: _C.navy)),
                    TextSpan(text: 'Cross', style: TextStyle(color: _C.blue)),
                  ],
                ),
              ),
              const Text(
                'MATH PUZZLE',
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
                    color: _C.muted),
              ),
            ],
          ),
        ),
        _squareIconBtn(Icons.workspace_premium_rounded, _C.amber,
            () => _push(const LeaderboardScreen())),
        const SizedBox(width: 10),
        _squareIconBtn(Icons.settings_rounded, _C.muted,
            () => _push(const SettingsScreen())),
      ],
    );
  }

  Widget _squareIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _softShadow,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  // ---------------- Level card ----------------
  Widget _levelCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          // hexagon badge
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.hexagon_rounded, size: 62, color: _C.blue),
                Text('$level',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Level $level',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _C.navy)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: xp / xpMax,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFDDE6F5),
                    valueColor: const AlwaysStoppedAnimation(_C.blue),
                  ),
                ),
                const SizedBox(height: 4),
                Text('$xp / $xpMax XP',
                    style: const TextStyle(fontSize: 12, color: _C.muted)),
              ],
            ),
          ),
          _vDivider(),
          Expanded(
            flex: 3,
            child: _stat('🔥', '$streak', 'Day Streak'),
          ),
          _vDivider(),
          Expanded(
            flex: 3,
            child: _stat('⭐', '$totalStars', 'Total Stars'),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: const Color(0xFFE2E8F0),
      );

  Widget _stat(String emoji, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 3),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _C.navy)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: _C.muted)),
      ],
    );
  }

  // ---------------- Play banner ----------------
  Widget _playBanner() {
    return GestureDetector(
      onTap: () => _openGame(PuzzleDifficulty.hard),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF1D5BF0), Color(0xFF2E9BFF)],
          ),
          boxShadow: [
            BoxShadow(
                color: _C.blue.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            SizedBox(width: 120, height: 120, child: _tilesCluster()),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('— LET\'S PLAY —',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600)),
                  const Text('PLAY',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          height: 1.05,
                          fontWeight: FontWeight.w900)),
                  Text('Solve Math Puzzles',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 13)),
                ],
              ),
            ),
            Container(
              width: 62,
              height: 62,
              margin: const EdgeInsets.only(right: 16),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded,
                  color: _C.blue, size: 38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tilesCluster() {
    Widget tile(String t, Color bg, Color fg, double angle) {
      return Transform.rotate(
        angle: angle,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(11),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 4, offset: Offset(0, 3))
            ],
          ),
          child: Text(t,
              style: TextStyle(
                  color: fg, fontSize: 22, fontWeight: FontWeight.w900)),
        ),
      );
    }

    return Stack(
      children: [
        Positioned(
            top: 6,
            left: 40,
            child: tile('8', Colors.white, _C.navy, -0.12)),
        Positioned(
            top: 40,
            left: 8,
            child: tile('+', Colors.white, _C.blue, -0.1)),
        Positioned(
            top: 40,
            left: 40,
            child: tile('×', const Color(0xFF3B82F6), Colors.white, 0.0)),
        Positioned(
            top: 40,
            left: 74,
            child: tile('=', const Color(0xFF22C55E), Colors.white, 0.12)),
        Positioned(
            top: 74,
            left: 44,
            child: tile('3', Colors.white, _C.navy, 0.1)),
      ],
    );
  }

  // ---------------- Difficulty ----------------
  Widget _difficultyHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Choose Difficulty',
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.w800, color: _C.navy)),
        GestureDetector(
          onTap: () => _push(const LevelsScreen()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3EDFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text('View Levels',
                    style: TextStyle(
                        color: _C.blue,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, color: _C.blue, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _difficultyRow() {
    return Row(
      children: [
        _diffBtn('Easy', PuzzleDifficulty.easy, const [Color(0xFF34D399), Color(0xFF10B981)]),
        const SizedBox(width: 10),
        _diffBtn('Medium', PuzzleDifficulty.medium, const [Color(0xFF3B82F6), Color(0xFF2563EB)]),
        const SizedBox(width: 10),
        _diffBtn('Hard', PuzzleDifficulty.hard, const [Color(0xFFFBBF24), Color(0xFFF59E0B)]),
        const SizedBox(width: 10),
        _diffBtn('Expert', PuzzleDifficulty.expert, const [Color(0xFF8B5CF6), Color(0xFF6D3FE0)]),
      ],
    );
  }

  Widget _diffBtn(String label, PuzzleDifficulty d, List<Color> colors) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _openGame(d),
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors),
            boxShadow: [
              BoxShadow(
                  color: colors.last.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: Colors.white, size: 26),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Daily challenge ----------------
  Widget _dailyChallengeCard() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ];
    final dateStr = '${months[now.month - 1]} ${now.day}, ${now.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFDDF3F4)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border(
                  top: BorderSide(color: Colors.red.shade300, width: 14)),
              boxShadow: _softShadow,
            ),
            child: const Center(
                child: Icon(Icons.star_rounded, color: _C.amber, size: 34)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Challenge',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _C.navy)),
                Text(dateStr,
                    style: const TextStyle(fontSize: 13, color: _C.muted)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE9D6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('🔥 $streak Day Streak',
                      style: const TextStyle(
                          color: Color(0xFFEA580C),
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Complete today\'s puzzle and keep your streak!',
                        style: TextStyle(fontSize: 11, color: _C.muted),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: () => _push(const DailyChallengeScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.blue,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Play Today',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Continue game ----------------
  Widget _continueCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _miniGrid(),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Continue Game',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: _C.navy)),
                SizedBox(height: 4),
                Text('Hard Puzzle',
                    style: TextStyle(fontSize: 14, color: _C.muted)),
                Text('03:21',
                    style: TextStyle(fontSize: 14, color: _C.muted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openGame(PuzzleDifficulty.hard,
                resume: FlutterStorageService.getSavedGame()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3EDFF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Text('Resume',
                      style: TextStyle(
                          color: _C.blue,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: _C.blue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniGrid() {
    const rows = [
      ['8', '+', '', '=', '12'],
      ['3', '4', '4', '=', ''],
      ['11', '+', '', '=', '19'],
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3EDFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: rows
            .map((r) => Row(
                  children: r
                      .map((t) => Container(
                            width: 17,
                            height: 17,
                            margin: const EdgeInsets.all(1),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: t.isEmpty
                                  ? const Color(0xFFD6E4FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(t,
                                style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: _C.navy)),
                          ))
                      .toList(),
                ))
            .toList(),
      ),
    );
  }

  // ---------------- Quick tiles ----------------
  Widget _quickTiles() {
    return Row(
      children: [
        _tile('🏆', 'Daily\nChallenge', const Color(0xFFE9F0FF),
            () => _push(const DailyChallengeScreen())),
        const SizedBox(width: 10),
        _tile('📊', 'Levels', const Color(0xFFE3F8EF),
            () => _push(const LevelsScreen())),
        const SizedBox(width: 10),
        _tile('📈', 'Statistics', const Color(0xFFFFF6E0),
            () => _push(const StatisticsScreen())),
        const SizedBox(width: 10),
        _tile('🏅', 'Leaderboard', const Color(0xFFFFE8EE),
            () => _push(const LeaderboardScreen())),
      ],
    );
  }

  Widget _tile(String emoji, String label, Color bg, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _softShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: _C.navy)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Bottom nav ----------------
  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, -3))
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() {
            _tab = i;
            _p = FlutterStorageService.getProfile();
          }),
          backgroundColor: Colors.white, // dark nav fix
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _C.blue,
          unselectedItemColor: const Color(0xFF9AA7BF),
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 30), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded, size: 30),
                label: 'Challenges'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded, size: 30), label: 'Stats'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 30), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------
  List<BoxShadow> get _softShadow => [
        BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4)),
      ];

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow,
      );
}