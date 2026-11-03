import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numcross/app/config/app_config.dart';
import 'package:numcross/core/services/settings_service.dart';
import 'package:numcross/core/services/storage_service.dart';
import 'package:numcross/features/splash/presentation/splash_screen.dart';
import 'package:numcross/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppConfig.load();
    await FlutterStorageService.init();
    SettingsService.load();
  });

  testWidgets('NumCross app opens successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const NumCrossApp());
    await tester.pump(); // first frame (also removes native splash)
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Advance splash timers so no pending timers remain after dispose.
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });
}
