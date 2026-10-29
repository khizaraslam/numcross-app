import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/core/services/puzzle_generator.dart';
import '../lib/core/services/storage_service.dart';

int? _ap(String op, int a, int b) {
  switch (op) {
    case '+':
      return a + b;
    case '-':
      return a - b;
    case '\u00D7':
      return a * b;
    case '\u00F7':
      return (b != 0 && a % b == 0) ? a ~/ b : null;
  }
  return null;
}

int _v(CrossMathPuzzle p, int r, int c) => int.parse(p.cells[r][c].value);

String _sig(CrossMathPuzzle p) => p.cells
    .expand((r) => r)
    .map((c) => c.value + (c.isInitial ? '' : '?'))
    .join(',');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PuzzleGenerator Tests', () {
    test('Seed reproducibility test: Same seed produces identical puzzle', () {
      const testSeed = '12345';
      final puzzle1 = PuzzleGenerator.generate(PuzzleDifficulty.hard, testSeed);
      final puzzle2 = PuzzleGenerator.generate(PuzzleDifficulty.hard, testSeed);

      expect(puzzle1.seed, equals(puzzle2.seed));
      expect(puzzle1.difficulty, equals(puzzle2.difficulty));
      expect(puzzle1.totalEmptyCells, equals(puzzle2.totalEmptyCells));

      for (int r = 0; r < 5; r++) {
        for (int c = 0; c < 5; c++) {
          expect(puzzle1.cells[r][c].value, equals(puzzle2.cells[r][c].value));
          expect(puzzle1.cells[r][c].type, equals(puzzle2.cells[r][c].type));
        }
      }
    });

    test('Daily challenge seed format produces valid 5x5 board', () {
      const dailySeed = 'daily-2026-10-27';
      final dailyPuzzle =
          PuzzleGenerator.generate(PuzzleDifficulty.hard, dailySeed);

      expect(dailyPuzzle.cells.length, equals(5));
      expect(dailyPuzzle.cells[0].length, equals(5));
      expect(dailyPuzzle.totalEmptyCells, greaterThan(0));
    });

    test('All difficulties generate properly configured empty cells', () {
      for (final diff in PuzzleDifficulty.values) {
        final puzzle = PuzzleGenerator.generate(diff, 'test-${diff.name}');
        expect(puzzle.totalEmptyCells, greaterThanOrEqualTo(3));
        expect(puzzle.gridSize, equals(5));
      }
    });

    test('Different levels produce different puzzles', () {
      for (final d in PuzzleDifficulty.values) {
        final sigs = {
          for (int l = 1; l <= 20; l++)
            _sig(PuzzleGenerator.generate(d, 'w1_l$l'))
        };
        expect(sigs.length, greaterThan(10));
      }
    });

    test('Equations are correct, values within 1..99, hidden counts match', () {
      const expected = {
        PuzzleDifficulty.easy: 3,
        PuzzleDifficulty.medium: 4,
        PuzzleDifficulty.hard: 5,
        PuzzleDifficulty.expert: 5,
      };
      for (final d in PuzzleDifficulty.values) {
        for (int l = 1; l <= 100; l++) {
          final p = PuzzleGenerator.generate(d, 'w2_l$l');
          for (final r in [0, 2, 4]) {
            expect(_ap(p.cells[r][1].value, _v(p, r, 0), _v(p, r, 2)),
                _v(p, r, 4));
          }
          for (final c in [0, 2, 4]) {
            expect(_ap(p.cells[1][c].value, _v(p, 0, c), _v(p, 2, c)),
                _v(p, 4, c));
          }
          for (final r in [0, 2, 4]) {
            for (final c in [0, 2, 4]) {
              expect(_v(p, r, c), inInclusiveRange(1, 99));
            }
          }
          final hidden = p.cells
              .expand((r) => r)
              .where((c) => c.type == CellType.number && !c.isInitial)
              .length;
          expect(hidden, p.totalEmptyCells);
          expect(hidden, expected[d]);
        }
      }
    });
  });

  group('Level Progression Logic Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await FlutterStorageService.init();
    });

    test('Fresh user: only World 1 Level 1 is unlocked, nothing completed', () {
      final map = FlutterStorageService.getLevels();
      final unlocked = map.values
          .where((l) => l.isUnlocked)
          .map((l) => 'w${l.worldId}_l${l.levelNum}')
          .toList();
      expect(unlocked, equals(['w1_l1']));
      expect(map.values.any((l) => l.isCompleted), isFalse);
      expect(map['w1_l2']!.isUnlocked, isFalse);
    });

    test('Fresh user profile starts clean', () {
      final p = FlutterStorageService.getProfile();
      expect(p.level, 1);
      expect(p.xp, 0);
      expect(p.totalStars, 0);
      expect(p.completedCount, 0);
    });

    test('Level completion unlocks next consecutive level', () async {
      await FlutterStorageService.completeLevel(1, 1, 3);
      final updated = FlutterStorageService.getLevels();

      expect(updated['w1_l1']!.isCompleted, isTrue);
      expect(updated['w1_l1']!.stars, equals(3));
      expect(updated['w1_l2']!.isUnlocked, isTrue);
      expect(updated['w1_l3']!.isUnlocked, isFalse);
    });

    test('Completing level 20 unlocks first level of next world', () async {
      await FlutterStorageService.completeLevel(1, 20, 2);
      final updated = FlutterStorageService.getLevels();
      expect(updated['w2_l1']!.isUnlocked, isTrue);
      expect(updated['w2_l2']!.isUnlocked, isFalse);
    });

    test('Existing saved progress is preserved', () async {
      SharedPreferences.setMockInitialValues({
        'numcross_levels': jsonEncode({
          'w1_l1': {
            'worldId': 1,
            'levelNum': 1,
            'isUnlocked': true,
            'isCompleted': true,
            'stars': 2,
          },
        }),
      });
      await FlutterStorageService.init();
      final map = FlutterStorageService.getLevels();
      expect(map['w1_l1']!.stars, 2);
      expect(map.length, 1);
    });
  });
}