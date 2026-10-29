import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/core/services/puzzle_generator.dart';
import '../lib/core/services/storage_service.dart';

int? ap(String op, int a, int b) {
  switch (op) {
    case '+': return a + b;
    case '-': return a - b;
    case '\u00D7': return a * b;
    case '\u00F7': return b != 0 && a % b == 0 ? a ~/ b : null;
  }
  return null;
}

int v(CrossMathPuzzle p, int r, int c) => int.parse(p.cells[r][c].value);
String sig(CrossMathPuzzle p) =>
    p.cells.expand((r) => r).map((c) => c.value + (c.isInitial ? '' : '?')).join(',');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PuzzleGenerator', () {
    test('same seed -> same puzzle', () {
      for (final d in PuzzleDifficulty.values) {
        expect(sig(PuzzleGenerator.generate(d, 'w1_l3')),
            sig(PuzzleGenerator.generate(d, 'w1_l3')));
      }
    });

    test('different levels differ', () {
      for (final d in PuzzleDifficulty.values) {
        final sigs = {for (int l = 1; l <= 20; l++) sig(PuzzleGenerator.generate(d, 'w1_l$l'))};
        expect(sigs.length, greaterThan(10));
      }
    });

    test('equations correct, values 1..99, hidden counts sane', () {
      const expected = {
        PuzzleDifficulty.easy: 3, PuzzleDifficulty.medium: 4,
        PuzzleDifficulty.hard: 5, PuzzleDifficulty.expert: 5,
      };
      for (final d in PuzzleDifficulty.values) {
        for (int l = 1; l <= 100; l++) {
          final p = PuzzleGenerator.generate(d, 'w2_l$l');
          for (final r in [0, 2, 4]) {
            expect(ap(p.cells[r][1].value, v(p, r, 0), v(p, r, 2)), v(p, r, 4));
          }
          for (final c in [0, 2, 4]) {
            expect(ap(p.cells[1][c].value, v(p, 0, c), v(p, 2, c)), v(p, 4, c));
          }
          for (final r in [0, 2, 4]) {
            for (final c in [0, 2, 4]) {
              expect(v(p, r, c), inInclusiveRange(1, 99));
            }
          }
          final hidden = p.cells.expand((r) => r)
              .where((c) => c.type == CellType.number && !c.isInitial).length;
          expect(hidden, p.totalEmptyCells);
          expect(hidden, expected[d]);
        }
      }
    });
  });

  group('Progression', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await FlutterStorageService.init();
    });

    test('fresh user: only W1 L1 unlocked, fresh profile', () {
      final unlocked = FlutterStorageService.getLevels().values
          .where((l) => l.isUnlocked).map((l) => 'w${l.worldId}_l${l.levelNum}').toList();
      expect(unlocked, ['w1_l1']);
      expect(FlutterStorageService.getLevels().values.any((l) => l.isCompleted), isFalse);
      final p = FlutterStorageService.getProfile();
      expect([p.level, p.xp, p.totalStars, p.completedCount], [1, 0, 0, 0]);
    });

    test('completing a level unlocks the next and persists', () async {
      await FlutterStorageService.completeLevel(1, 1, 3);
      final m = FlutterStorageService.getLevels();
      expect(m['w1_l1']!.isCompleted, isTrue);
      expect(m['w1_l2']!.isUnlocked, isTrue);
      expect(m['w1_l3']!.isUnlocked, isFalse);
    });

    test('level 20 unlocks next world', () async {
      await FlutterStorageService.completeLevel(1, 20, 2);
      expect(FlutterStorageService.getLevels()['w2_l1']!.isUnlocked, isTrue);
    });

    test('existing saved progress is preserved', () async {
      SharedPreferences.setMockInitialValues({
        'numcross_levels': jsonEncode({
          'w1_l1': {'worldId': 1, 'levelNum': 1, 'isUnlocked': true, 'isCompleted': true, 'stars': 2},
        }),
      });
      await FlutterStorageService.init();
      final m = FlutterStorageService.getLevels();
      expect(m['w1_l1']!.stars, 2);
      expect(m.length, 1);
    });
  });
}