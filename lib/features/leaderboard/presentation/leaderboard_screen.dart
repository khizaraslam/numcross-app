import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

class _C {
  static const bg = Color(0xFFF1F6FF);
  static const navy = Color(0xFF0F1F5C);
  static const blue = Color(0xFF1D6BF3);
  static const muted = Color(0xFF6B7A99);
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _tab = 0; // 0 Global, 1 Friends, 2 Country

  late PlayerProfile _p;
  late int _totalXp;

  @override
  void initState() {
    super.initState();
    _p = FlutterStorageService.getProfile();
    // Total XP earned (same formula as storage_service.addXP)
    int xp = _p.xp;
    for (int l = 1; l < _p.level; l++) {
      xp += l * 100 + 400;
    }
    _totalXp = xp;
  }

  String get _avatar => _p.avatar == 'girl' ? '👧' : '👦';

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
                _podium(),
                const SizedBox(height: 14),
                _tabs(),
                const SizedBox(height: 12),
                _tab == 0 ? _globalList() : _emptyState(),
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
                child: Text('Leaderboard',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: _C.navy)),
              ),
              Text('Compete with friends and players worldwide!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _C.muted)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- Podium ----------------
  Widget _podium() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 270,
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
            Positioned(top: 16, left: 16, child: _cloud(60)),
            Positioned(top: 30, right: 24, child: _cloud(48)),
            Positioned(bottom: -40, left: -30, child: _bush(130)),
            Positioned(bottom: -40, right: -30, child: _bush(130)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd place - open slot
                  Expanded(
                    child: _podiumSlot(
                      rank: 2,
                      height: 92,
                      color: const Color(0xFF3B8DF5),
                      figure: '👤',
                      crown: '🥈',
                      name: 'Open slot',
                      xp: '— XP',
                      empty: true,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // 1st place - the real player
                  Expanded(
                    child: _podiumSlot(
                      rank: 1,
                      height: 122,
                      color: const Color(0xFFFBBF24),
                      figure: _avatar,
                      crown: '👑',
                      name: _p.name,
                      xp: '${_fmt(_totalXp)} XP',
                      empty: false,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // 3rd place - open slot
                  Expanded(
                    child: _podiumSlot(
                      rank: 3,
                      height: 78,
                      color: const Color(0xFFE08A3C),
                      figure: '👤',
                      crown: '🥉',
                      name: 'Open slot',
                      xp: '— XP',
                      empty: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _podiumSlot({
    required int rank,
    required double height,
    required Color color,
    required String figure,
    required String crown,
    required String name,
    required String xp,
    required bool empty,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(crown, style: TextStyle(fontSize: rank == 1 ? 30 : 22)),
        Opacity(
          opacity: empty ? 0.35 : 1,
          child: Text(figure,
              style: TextStyle(fontSize: rank == 1 ? 64 : 48)),
        ),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: empty ? color.withOpacity(0.55) : color,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 4),
              Text('$rank',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: rank == 1 ? 34 : 28,
                      height: 1.1,
                      fontWeight: FontWeight.w900)),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(name,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _C.navy)),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(xp,
                          style: const TextStyle(
                              fontSize: 10, color: _C.muted)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
        height: w * 0.9,
        decoration: BoxDecoration(
          color: const Color(0xFF3DBE5C),
          borderRadius: BorderRadius.circular(w),
        ),
      );

  // ---------------- Tabs ----------------
  Widget _tabs() {
    const labels = ['Global', 'Friends', 'Country'];
    return Row(
      children: List.generate(3, (i) {
        final selected = _tab == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: Container(
              height: 46,
              margin: EdgeInsets.only(right: i == 2 ? 0 : 10),
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
              child: Center(
                child: Text(labels[i],
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : _C.muted)),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ---------------- Global list (real player only) ----------------
  Widget _globalList() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _card(),
      child: Column(
        children: [
          // rank 1 = you
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1C9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const SizedBox(
                    width: 44,
                    child: Center(
                        child: Text('👑', style: TextStyle(fontSize: 30)))),
                const SizedBox(width: 8),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF9CC9FF),
                    border: Border.all(color: _C.blue, width: 2),
                  ),
                  child: Center(
                      child: Text(_avatar,
                          style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_p.name} (You)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: _C.navy)),
                      Text('Level ${_p.level}',
                          style: const TextStyle(
                              fontSize: 12, color: _C.muted)),
                    ],
                  ),
                ),
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFBBF24), size: 30),
                const SizedBox(width: 4),
                Text('${_fmt(_totalXp)} XP',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _C.navy)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text('🌍', style: TextStyle(fontSize: 34)),
                SizedBox(height: 6),
                Text('Other players will appear here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _C.navy)),
                SizedBox(height: 4),
                Text(
                    'A worldwide leaderboard needs online accounts. For now you are the only player on this device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, height: 1.3, color: _C.muted)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _emptyState() {
    final isFriends = _tab == 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _card(),
      child: Column(
        children: [
          Text(isFriends ? '👫' : '🗺️', style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text(isFriends ? 'No friends yet' : 'No country ranking yet',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _C.navy)),
          const SizedBox(height: 4),
          Text(
              isFriends
                  ? 'Adding friends needs online accounts, which are not available yet.'
                  : 'Country rankings need online accounts, which are not available yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, height: 1.3, color: _C.muted)),
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