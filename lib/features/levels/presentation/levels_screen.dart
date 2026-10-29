import 'package:flutter/material.dart';
import '../../../core/services/puzzle_generator.dart';
import '../../../core/services/storage_service.dart';
import '../../game/presentation/game_screen.dart';

class _C {
  static const bg = Color(0xFFF1F6FF);
  static const navy = Color(0xFF0F1F5C);
  static const blue = Color(0xFF1D6BF3);
  static const muted = Color(0xFF6B7A99);
  static const star = Color(0xFFFFC83D);
}

class _World {
  final int id;
  final String name;
  final String sub;
  final Color color;
  final PuzzleDifficulty diff;

  const _World(this.id, this.name, this.sub, this.color, this.diff);
}

const _worlds = [
  _World(1, 'World 1', 'Math Basics', Color(0xFF1D6BF3), PuzzleDifficulty.easy),
  _World(2, 'World 2', 'Multiplication Fun', Color(0xFF22C55E),
      PuzzleDifficulty.medium),
  _World(3, 'World 3', 'Mixed Math', Color(0xFFF97316), PuzzleDifficulty.hard),
  _World(4, 'World 4', 'Division Master', Color(0xFF7C3AED),
      PuzzleDifficulty.hard),
  _World(5, 'World 5', 'Master Grid', Color(0xFFEC4899),
      PuzzleDifficulty.expert),
];

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  late Map<String, LevelStatus> _levelsMap;
  final Set<int> _expanded = {};
  String _filter = 'All'; // All | Easy | Medium | Hard | Expert

  @override
  void initState() {
    super.initState();
    _levelsMap = FlutterStorageService.getLevels();
    _expanded.add(_currentWorldId());
    FlutterStorageService.levelsRevision.addListener(_loadLevels);
  }

  @override
  void dispose() {
    FlutterStorageService.levelsRevision.removeListener(_loadLevels);
    super.dispose();
  }

  void _loadLevels() {
    if (!mounted) return;
    setState(() {
      _levelsMap = FlutterStorageService.getLevels();
    });
  }

  // World that contains the next level to play
  int _currentWorldId() {
    final cur = _currentLevelKey();
    if (cur == null) return 1;
    return _levelsMap[cur]!.worldId;
  }

  // Key of first unlocked-but-not-completed level
  String? _currentLevelKey() {
    for (final w in _worlds) {
      for (int l = 1; l <= 20; l++) {
        final key = 'w${w.id}_l$l';
        final s = _levelsMap[key];
        if (s != null && s.isUnlocked && !s.isCompleted) return key;
      }
    }
    return null;
  }

  int _worldStars(int worldId) {
    int total = 0;
    for (int l = 1; l <= 20; l++) {
      total += _levelsMap['w${worldId}_l$l']?.stars ?? 0;
    }
    return total;
  }

  bool _matchesFilter(_World w) {
    if (_filter == 'All') return true;
    return w.diff.name.toLowerCase() == _filter.toLowerCase();
  }

  Future<void> _openLevel(_World w, int lvlNum) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NumCrossGameScreen(
          difficulty: w.diff,
          worldId: w.id,
          levelNum: lvlNum,
          levelTitle: 'Level $lvlNum • ${w.name}',
        ),
      ),
    );
    _loadLevels();
  }

  @override
  Widget build(BuildContext context) {
    final currentKey = _currentLevelKey();
    final shown = _worlds.where(_matchesFilter).toList();

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
                _landscape(),
                if (shown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No worlds for this difficulty',
                        style: TextStyle(color: _C.muted)),
                  ),
                for (final w in shown) ...[
                  _worldCard(w, currentKey),
                  const SizedBox(height: 14),
                ],
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
              Text('Levels',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: _C.navy)),
              Text('Solve puzzles, earn stars and unlock new worlds!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _C.muted)),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: PopupMenuButton<String>(
            onSelected: (v) => setState(() => _filter = v),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'Easy', child: Text('Easy')),
              PopupMenuItem(value: 'Medium', child: Text('Medium')),
              PopupMenuItem(value: 'Hard', child: Text('Hard')),
              PopupMenuItem(value: 'Expert', child: Text('Expert')),
            ],
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _shadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_filter,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _C.navy)),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: _C.blue, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Landscape banner ----------------
  Widget _landscape() {
    return SizedBox(
      height: 110,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
              bottom: -30,
              left: -30,
              child: _blob(150, const Color(0xFF2FAE61))),
          Positioned(
              bottom: -40,
              right: -30,
              child: _blob(160, const Color(0xFF3DBE5C))),
          Positioned(
              bottom: -60,
              child: _blob(260, const Color(0xFF6FD491))),
          const Positioned(
              bottom: 14,
              child: Text('🏆', style: TextStyle(fontSize: 54))),
        ],
      ),
    );
  }

  Widget _blob(double w, Color c) => Container(
        width: w,
        height: w * 0.7,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(w),
        ),
      );

  // ---------------- World card ----------------
  Widget _worldCard(_World w, String? currentKey) {
    final open = _expanded.contains(w.id);
    final stars = _worldStars(w.id);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, w.color.withOpacity(0.07)],
        ),
        boxShadow: _shadow,
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              open ? _expanded.remove(w.id) : _expanded.add(w.id);
            }),
            child: Row(
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.hexagon_rounded, color: w.color, size: 58),
                      Text('${w.id}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _C.navy)),
                      Text(w.sub,
                          style: const TextStyle(
                              fontSize: 13, color: _C.muted)),
                    ],
                  ),
                ),
                const Icon(Icons.star_rounded, color: _C.star, size: 30),
                const SizedBox(width: 4),
                Text('$stars/60',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _C.navy)),
                const SizedBox(width: 6),
                Icon(
                    open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _C.blue,
                    size: 28),
              ],
            ),
          ),
          if (open) ...[
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.05,
              ),
              itemCount: 20,
              itemBuilder: (context, i) => _levelTile(w, i + 1, currentKey),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- Level tile ----------------
  Widget _levelTile(_World w, int n, String? currentKey) {
    final key = 'w${w.id}_l$n';
    final status = _levelsMap[key] ??
        LevelStatus(
            worldId: w.id,
            levelNum: n,
            isUnlocked: false,
            isCompleted: false);
    final isCurrent = key == currentKey;

    // Locked
    if (!status.isUnlocked) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE4EAF6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$n',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7E8DAE))),
            const Icon(Icons.lock_rounded,
                size: 18, color: Color(0xFF8795B5)),
          ],
        ),
      );
    }

    final done = status.isCompleted;
    final fg = done ? Colors.white : _C.navy;

    return GestureDetector(
      onTap: () => _openLevel(w, n),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: done
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [w.color.withOpacity(0.85), w.color],
                )
              : null,
          color: done ? null : Colors.white,
          border: isCurrent ? Border.all(color: _C.blue, width: 3) : null,
          boxShadow: done
              ? [
                  BoxShadow(
                      color: w.color.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$n',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: fg)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (s) => Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: s < status.stars
                      ? _C.star
                      : (done
                          ? Colors.white.withOpacity(0.45)
                          : const Color(0xFFC5CFE3)),
                ),
              ),
            ),
          ],
        ),
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