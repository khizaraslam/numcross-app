enum PuzzleDifficulty { easy, medium, hard, expert }

enum CellType { number, operator, equals, blocked }

class PuzzleCell {
  final String id;
  final int row;
  final int col;
  final CellType type;
  final String value;
  String userValue;
  final bool isInitial;
  bool isHinted;
  bool isWrong;
  bool isCorrect;

  PuzzleCell({
    required this.id,
    required this.row,
    required this.col,
    required this.type,
    required this.value,
    this.userValue = '',
    required this.isInitial,
    this.isHinted = false,
    this.isWrong = false,
    this.isCorrect = false,
  });
}

class CrossMathPuzzle {
  final String id;
  final String seed;
  final PuzzleDifficulty difficulty;
  final int gridSize;
  final List<List<PuzzleCell>> cells;
  final int totalEmptyCells;
  final int generatorVersion;

  CrossMathPuzzle({
    required this.id,
    required this.seed,
    required this.difficulty,
    this.gridSize = 5,
    required this.cells,
    required this.totalEmptyCells,
    this.generatorVersion = 1,
  });
}

class Mulberry32Random {
  int _state;

  Mulberry32Random(String seed) : _state = _hashString(seed);

  static int _hashString(String s) {
    int hash = 0;
    for (int i = 0; i < s.length; i++) {
      hash = (hash * 31 + s.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash == 0 ? 1337 : hash;
  }

  double nextDouble() {
    int t = (_state += 0x6D2B79F5) & 0xFFFFFFFF;
    t = (t ^ (t >> 15)) * (t | 1) & 0xFFFFFFFF;
    t ^= t + ((t ^ (t >> 7)) * (t | 61) & 0xFFFFFFFF);
    return ((t ^ (t >> 14)) & 0xFFFFFFFF) / 4294967296.0;
  }

  int nextInt(int min, int max) {
    return (nextDouble() * (max - min + 1)).floor() + min;
  }

  T choice<T>(List<T> list) {
    return list[nextInt(0, list.length - 1)];
  }
}

class _Spec {
  final String rowOp;
  final String colOp;
  final int lo;
  final int hi;
  const _Spec(this.rowOp, this.colOp, this.lo, this.hi);
}

class _Solution {
  final List<List<int>> n;
  final String rowOp;
  final String colOp;
  _Solution(this.n, this.rowOp, this.colOp);
}

class PuzzleGenerator {
  static const int version = 2;
  static const int _maxValue = 99; // number pad only allows 2 digits
  static const int _maxAttempts = 2000;

  static const String _plus = '+';
  static const String _minus = '-';
  static const String _times = '\u00D7';
  static const String _divide = '\u00F7';

  // Each equation = indices into the 3x3 matrix of number cells.
  static const List<List<int>> _equations = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
  ];

  static List<_Spec> _specsFor(PuzzleDifficulty d) {
    switch (d) {
      case PuzzleDifficulty.easy:
        return const [
          _Spec(_plus, _plus, 1, 20),
          _Spec(_plus, _minus, 1, 20),
          _Spec(_minus, _plus, 1, 20),
        ];
      case PuzzleDifficulty.medium:
        return const [
          _Spec(_times, _times, 2, 5),
          _Spec(_plus, _plus, 5, 30),
          _Spec(_minus, _plus, 5, 30),
          _Spec(_plus, _minus, 5, 30),
          _Spec(_minus, _minus, 5, 30),
        ];
      case PuzzleDifficulty.hard:
        return const [
          _Spec(_times, _divide, 2, 9),
          _Spec(_divide, _times, 2, 9),
          _Spec(_times, _times, 2, 9),
          _Spec(_divide, _divide, 2, 12),
          _Spec(_minus, _minus, 10, 60),
        ];
      case PuzzleDifficulty.expert:
        return const [
          _Spec(_times, _divide, 2, 12),
          _Spec(_divide, _times, 2, 12),
          _Spec(_divide, _divide, 2, 12),
          _Spec(_times, _times, 2, 6),
          _Spec(_minus, _minus, 10, 60),
          _Spec(_plus, _minus, 10, 50),
        ];
    }
  }

  // 5 is the maximum number of hidden cells that still leaves a unique solution.
  static int _hiddenTarget(PuzzleDifficulty d) {
    switch (d) {
      case PuzzleDifficulty.easy:
        return 3;
      case PuzzleDifficulty.medium:
        return 4;
      case PuzzleDifficulty.hard:
        return 5;
      case PuzzleDifficulty.expert:
        return 5;
    }
  }

  static int? _apply(String op, int a, int b) {
    int? r;
    if (op == _plus) {
      r = a + b;
    } else if (op == _minus) {
      r = a - b;
    } else if (op == _times) {
      r = a * b;
    } else if (op == _divide) {
      if (b == 0 || a % b != 0) return null;
      r = a ~/ b;
    }
    if (r == null || r < 1 || r > _maxValue) return null;
    return r;
  }

  static _Solution? _tryBuild(Mulberry32Random rng, _Spec s) {
    final n = List.generate(3, (_) => List<int>.filled(3, 0));
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        n[i][j] = rng.nextInt(s.lo, s.hi);
      }
    }
    for (int i = 0; i < 2; i++) {
      final v = _apply(s.rowOp, n[i][0], n[i][1]);
      if (v == null) return null;
      n[i][2] = v;
    }
    for (int j = 0; j < 2; j++) {
      final v = _apply(s.colOp, n[0][j], n[1][j]);
      if (v == null) return null;
      n[2][j] = v;
    }
    final byRow = _apply(s.rowOp, n[2][0], n[2][1]);
    final byCol = _apply(s.colOp, n[0][2], n[1][2]);
    if (byRow == null || byRow != byCol) return null;
    n[2][2] = byRow;
    return _Solution(n, s.rowOp, s.colOp);
  }

  // True if every hidden cell can be deduced from equations (=> unique solution).
  static bool _isSolvable(Set<int> hidden) {
    final unknown = Set<int>.from(hidden);
    bool changed = true;
    while (changed && unknown.isNotEmpty) {
      changed = false;
      for (final eq in _equations) {
        final unk = eq.where(unknown.contains).toList();
        if (unk.length == 1) {
          unknown.remove(unk.first);
          changed = true;
        }
      }
    }
    return unknown.isEmpty;
  }

  static CrossMathPuzzle generate(PuzzleDifficulty difficulty, [String? seedInput]) {
    final seed = seedInput ?? DateTime.now().millisecondsSinceEpoch.toString();
    final rng = Mulberry32Random('$seed|${difficulty.name}|v$version');

    final specs = _specsFor(difficulty);
    _Solution? sol;
    for (int a = 0; a < _maxAttempts && sol == null; a++) {
      sol = _tryBuild(rng, rng.choice(specs));
    }
    // Bounded, guaranteed fallback: the original verified addition grid.
    sol ??= _Solution(
      [
        [8, 4, 12],
        [3, 4, 7],
        [11, 8, 19],
      ],
      _plus,
      _plus,
    );
    final n = sol.n;

    // Pick hidden cells in seeded random order, keeping the puzzle uniquely solvable.
    final order = List<int>.generate(9, (i) => i);
    for (int i = 8; i > 0; i--) {
      final j = rng.nextInt(0, i);
      final t = order[i];
      order[i] = order[j];
      order[j] = t;
    }
    final target = _hiddenTarget(difficulty);
    final hidden = <int>{};
    for (final idx in order) {
      if (hidden.length >= target) break;
      if (_isSolvable({...hidden, idx})) hidden.add(idx);
    }

    final List<List<PuzzleCell>> cells = [];
    for (int r = 0; r < 5; r++) {
      final row = <PuzzleCell>[];
      for (int c = 0; c < 5; c++) {
        CellType type;
        String val;
        if (r.isEven && c.isEven) {
          type = CellType.number;
          val = '${n[r ~/ 2][c ~/ 2]}';
        } else if (r.isEven) {
          type = c == 1 ? CellType.operator : CellType.equals;
          val = c == 1 ? sol.rowOp : '=';
        } else if (c.isEven) {
          type = r == 1 ? CellType.operator : CellType.equals;
          val = r == 1 ? sol.colOp : '=';
        } else {
          type = CellType.blocked;
          val = '';
        }
        final isHidden =
            type == CellType.number && hidden.contains((r ~/ 2) * 3 + (c ~/ 2));
        row.add(PuzzleCell(
          id: 'cell_${r}_$c',
          row: r,
          col: c,
          type: type,
          value: val,
          userValue: isHidden ? '' : val,
          isInitial: !isHidden && type == CellType.number,
        ));
      }
      cells.add(row);
    }

    return CrossMathPuzzle(
      id: 'puzzle_${difficulty.name}_$seed',
      seed: seed,
      difficulty: difficulty,
      cells: cells,
      totalEmptyCells: hidden.length,
      generatorVersion: version,
    );
  }
}