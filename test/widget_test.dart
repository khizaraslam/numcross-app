
import 'package:flutter_test/flutter_test.dart';
import 'package:numcross/main.dart';

void main() {
  testWidgets('NumCross app opens successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const NumCrossApp());

    // Allow the initial frame to render.
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
