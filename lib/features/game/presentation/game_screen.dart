import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/puzzle_generator.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/storage_service.dart';

class NumCrossGameScreen extends StatefulWidget {
  final PuzzleDifficulty difficulty;
  final int? worldId;
  final int? levelNum;
  final String? levelTitle;
  final Map<String, dynamic>? resume;

  const NumCrossGameScreen({
    super.key,
    required this.difficulty,
    this.worldId,
    this.levelNum,
    this.levelTitle,
    this.resume,
  });

  @override
  State<NumCrossGameScreen> createState() => _NumCrossGameScreenState();
}

class _NumCrossGameScreenState extends State<NumCrossGameScreen> {
  late CrossMathPuzzle _puzzle;
  late PuzzleDifficulty _difficulty;
  late int? _currentWorldId;
  late int? _currentLevelNum;
  late String _currentTitle;

  int? _selectedRow;
  int? _selectedCol;
  int _hintsRemaining = 3;
  int _mistakesCount = 0;
  final List<Map<String, dynamic>> _history = [];
  bool _isCompleted = false;

  // Timer (always counts; only shown when the Timer setting is on)
  Timer? _ticker;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _currentWorldId = widget.worldId;
    _currentLevelNum = widget.levelNum;
    _currentTitle = widget.levelTitle ?? 'Classic Puzzle';
    _difficulty = widget.difficulty;
    _startNewPuzzle();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isCompleted) return;
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _fmtTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  PuzzleDifficulty _difficultyFor(int? worldId) {
    switch (worldId) {
      case 1:
        return PuzzleDifficulty.easy;
      case 2:
        return PuzzleDifficulty.medium;
      case 3:
      case 4:
        return PuzzleDifficulty.hard;
      case 5:
        return PuzzleDifficulty.expert;
      default:
        return widget.difficulty;
    }
  }

  void _startNewPuzzle() {
    String? seed;
    if (_currentWorldId != null && _currentLevelNum != null) {
      seed = 'w${_currentWorldId}_l$_currentLevelNum';
    }
    _puzzle = PuzzleGenerator.generate(_difficulty, seed);
    _history.clear();
    _isCompleted = false;
    _mistakesCount = 0;
    _hintsRemaining = 3;
    _selectedRow = null;
    _selectedCol = null;
    _seconds = 0;

    // Auto-select first empty number cell
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        final cell = _puzzle.cells[r][c];
        if (cell.type == CellType.number &&
            !cell.isInitial &&
            cell.userValue.isEmpty) {
          _selectedRow = r;
          _selectedCol = c;
          return;
        }
      }
    }
  }

  void _onNumberTap(String num) {
    if (_selectedRow == null || _selectedCol == null || _isCompleted) return;
    final cell = _puzzle.cells[_selectedRow!][_selectedCol!];
    if (cell.isInitial || cell.isHinted) return;

    SettingsService.tap();
    final mode = SettingsService.current.mistakeChecking;

    setState(() {
      final prev = cell.userValue;
      String next = num;
      if (prev.isNotEmpty && prev.length < cell.value.length) {
        next = prev + num;
      }

      _history.add({
        'r': _selectedRow!,
        'c': _selectedCol!,
        'prev': prev,
        'next': next,
      });

      cell.userValue = next;
      if (next.length >= cell.value.length) {
        if (next != cell.value) {
          // mistakes always count towards stars,
          // but are only shown in "Immediate" mode
          _mistakesCount++;
          cell.isWrong = mode == 'immediate';
          cell.isCorrect = false;
          if (mode == 'immediate') SettingsService.error();
        } else {
          cell.isWrong = false;
          cell.isCorrect = true;
        }
      } else {
        // Partial entry of a multi-digit answer: not a mistake yet
        cell.isWrong = false;
        cell.isCorrect = false;
      }

      _checkVictory();
    });
  }

  void _onErase() {
    if (_selectedRow == null || _selectedCol == null || _isCompleted) return;
    final cell = _puzzle.cells[_selectedRow!][_selectedCol!];
    if (cell.isInitial || cell.isHinted || cell.userValue.isEmpty) return;

    SettingsService.tap();
    setState(() {
      _history.add({
        'r': _selectedRow!,
        'c': _selectedCol!,
        'prev': cell.userValue,
        'next': '',
      });
      cell.userValue = '';
      cell.isWrong = false;
      cell.isCorrect = false;
    });
  }

  void _onUndo() {
    if (_history.isEmpty || _isCompleted) return;
    SettingsService.tap();
    setState(() {
      final last = _history.removeLast();
      final r = last['r'] as int;
      final c = last['c'] as int;
      final cell = _puzzle.cells[r][c];
      cell.userValue = last['prev'] as String;
      cell.isWrong = false;
      _selectedRow = r;
      _selectedCol = c;
    });
  }

  void _onHint() {
    if (_hintsRemaining <= 0 || _isCompleted) return;

    // Find first incorrect or empty cell
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        final cell = _puzzle.cells[r][c];
        if (cell.type == CellType.number &&
            !cell.isInitial &&
            cell.userValue != cell.value) {
          SettingsService.tap();
          setState(() {
            cell.userValue = cell.value;
            cell.isHinted = true;
            cell.isWrong = false;
            cell.isCorrect = true;
            _hintsRemaining--;
            _selectedRow = r;
            _selectedCol = c;
            _checkVictory();
          });
          return;
        }
      }
    }
  }

  void _onCheck() {
    SettingsService.tap();
    bool hasErrors = false;
    setState(() {
      for (int r = 0; r < 5; r++) {
        for (int c = 0; c < 5; c++) {
          final cell = _puzzle.cells[r][c];
          if (cell.type == CellType.number &&
              !cell.isInitial &&
              cell.userValue.isNotEmpty) {
            if (cell.userValue != cell.value) {
              cell.isWrong = true;
              hasErrors = true;
            } else {
              cell.isWrong = false;
              cell.isCorrect = true;
            }
          }
        }
      }
      // Pressing Check can always finish the puzzle
      _checkVictory(force: true);
    });

    if (hasErrors) SettingsService.error();

    if (!_isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hasErrors
              ? 'Some numbers are incorrect!'
              : 'Equations look good so far!'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _saveProgress(int worldId, int levelNum, int stars) async {
    try {
      await FlutterStorageService.completeLevel(worldId, levelNum, stars);
      await FlutterStorageService.addXP(120);
      debugPrint('SAVED w$worldId l$levelNum stars=$stars');
    } catch (e, s) {
      debugPrint('SAVE FAILED: $e\n$s');
    }
  }

  int _calcStars() {
    int stars = 3;
    if (_hintsRemaining < 3 || _mistakesCount > 1) stars = 2;
    if (_hintsRemaining < 2 || _mistakesCount > 3) stars = 1;
    return stars;
  }

  void _checkVictory({bool force = false}) {
    if (_isCompleted) return;

    // Are all answers correct?
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        final cell = _puzzle.cells[r][c];
        if (cell.type == CellType.number && cell.userValue != cell.value) {
          return;
        }
      }
    }

    // All correct. With Auto-Check off, the puzzle only finishes on Check.
    if (!force && !SettingsService.current.autoCheckEquations) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('All answers are filled. Press Check to finish!'),
          duration: Duration(seconds: 2),
        ));
      return;
    }

    _isCompleted = true;
    SettingsService.success();

    final stars = _calcStars();

    // Save level progression (ids captured now, saved sequentially)
    if (_currentWorldId != null && _currentLevelNum != null) {
      _saveProgress(_currentWorldId!, _currentLevelNum!, stars);
    }

    _showVictoryDialog(stars);
  }

  void _goToNextLevel() {
    if (_currentWorldId != null && _currentLevelNum != null) {
      int nextLevel = _currentLevelNum! + 1;
      int nextWorld = _currentWorldId!;
      if (nextLevel > 20) {
        if (nextWorld < 5) {
          nextWorld++;
          nextLevel = 1;
        } else {
          // Reached final level!
          Navigator.pop(context);
          return;
        }
      }

      setState(() {
        _currentWorldId = nextWorld;
        _currentLevelNum = nextLevel;
        _currentTitle = 'Level $nextLevel • World $nextWorld';
        _difficulty = _difficultyFor(nextWorld);
        _startNewPuzzle();
      });
    } else {
      // Free play / endless mode: generate next fresh puzzle
      setState(() {
        _startNewPuzzle();
      });
    }
  }

  void _showVictoryDialog(int stars) {
    final showTimer = SettingsService.current.timer;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: const [
            Text('🎉', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text('Excellent!', style: TextStyle(fontWeight: FontWeight.w900)),
            Text('Puzzle Completed',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (idx) => Icon(
                  Icons.star,
                  color: idx < stars ? Colors.amber : Colors.grey.shade300,
                  size: idx == 1 ? 38 : 30,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Mistakes: $_mistakesCount  •  Hints: ${3 - _hintsRemaining}'),
            if (showTimer) ...[
              const SizedBox(height: 4),
              Text('Time: ${_fmtTime(_seconds)}'),
            ],
            const SizedBox(height: 4),
            const Text('+120 XP Earned',
                style: TextStyle(
                    color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return home/levels
            },
            child: const Text('Home'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _goToNextLevel();
            },
            child: Text(
              _currentLevelNum != null ? 'Next Level' : 'Next Puzzle',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showTimer = SettingsService.current.timer;

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              _difficulty.name.toUpperCase(),
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.textMain),
            ),
            Text(
              _currentTitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stats bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppColors.accentAmber, size: 18),
                        const SizedBox(width: 4),
                        Text('${_calcStars()}/3 Stars',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.textMain)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.close,
                            color: Colors.redAccent, size: 18),
                        const SizedBox(width: 4),
                        Text('$_mistakesCount Mistakes',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.textMain)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.lightbulb,
                            color: AppColors.accentAmber, size: 18),
                        const SizedBox(width: 4),
                        Text('$_hintsRemaining Hints',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.textMain)),
                      ],
                    ),
                    if (showTimer)
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: AppColors.primaryBlue, size: 18),
                          const SizedBox(width: 4),
                          Text(_fmtTime(_seconds),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.textMain)),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // 5x5 Grid
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF3FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: 25,
                      itemBuilder: (context, index) {
                        final r = index ~/ 5;
                        final c = index % 5;
                        final cell = _puzzle.cells[r][c];

                        if (cell.type == CellType.blocked) {
                          return const SizedBox();
                        }

                        final isSelected =
                            _selectedRow == r && _selectedCol == c;

                        Color bg = Colors.white;
                        Color textCol = AppColors.textMain;
                        BoxBorder? border;

                        if (cell.type == CellType.operator ||
                            cell.type == CellType.equals) {
                          bg = Colors.white.withOpacity(0.7);
                          textCol = AppColors.primaryBlue;
                        } else if (!cell.isInitial) {
                          if (cell.isWrong) {
                            // wrong stays red even while the cell is selected
                            border = Border.all(
                                color: Colors.redAccent,
                                width: isSelected ? 3 : 2);
                            bg = const Color(0xFFFEE2E2);
                            textCol = Colors.redAccent;
                          } else if (isSelected) {
                            border = Border.all(
                                color: AppColors.primaryBlue, width: 2.5);
                            bg = const Color(0xFFDBEAFE);
                          } else if (cell.isHinted) {
                            border = Border.all(color: Colors.amber, width: 2);
                            bg = const Color(0xFFFEF3C7);
                            textCol = Colors.brown;
                          } else {
                            border = Border.all(
                                color: Colors.blue.shade200, width: 1.5);
                            bg = const Color(0xFFEFF6FF);
                          }
                        }

                        return GestureDetector(
                          onTap: () {
                            if (cell.type == CellType.number &&
                                !cell.isInitial) {
                              SettingsService.haptic();
                              setState(() {
                                _selectedRow = r;
                                _selectedCol = c;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(14),
                              border: border,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                cell.userValue.isNotEmpty
                                    ? cell.userValue
                                    : (cell.isInitial ? cell.value : ''),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: textCol,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Action Buttons: Undo, Erase, Hint, Check
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  _actionButton(
                      Icons.undo, 'Undo', _history.isNotEmpty ? _onUndo : null),
                  _actionButton(Icons.backspace_outlined, 'Remove', _onErase),
                  _actionButton(Icons.lightbulb_outline,
                      'Hint ($_hintsRemaining)', _onHint),
                  _actionButton(Icons.check_circle_outline, 'Check', _onCheck),
                ],
              ),
            ),

            // Number Pad
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['1', '2', '3', '4', '5']
                        .map((n) => _keyBtn(n))
                        .toList()
                      ..add(_deleteBtn()),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['6', '7', '8', '9', '0']
                        .map((n) => _keyBtn(n))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback? onTap) {
    final color = onTap != null ? AppColors.primaryBlue : Colors.grey;
    // Expanded + FittedBox: each button gets an equal share of the row
    // and shrinks its content if needed, so it can never overflow.
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 4),
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _keyBtn(String n) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textMain,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        onPressed: () => _onNumberTap(n),
        child: Text(n,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _deleteBtn() {
    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: const Color(0xFFFEE2E2),
          foregroundColor: Colors.redAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        onPressed: _onErase,
        child: const Icon(Icons.backspace_outlined, size: 18),
      ),
    );
  }
}