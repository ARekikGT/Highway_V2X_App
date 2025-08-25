// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadsafe_alerts/main.dart';

void main() {
  testWidgets('App boots, shows Splash then Home', (WidgetTester tester) async {
    // Build the app with required notifiers
    final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
    final locale = ValueNotifier<Locale?>(const Locale('fr'));

    await tester.pumpWidget(RoadSafeApp(themeMode: themeMode, locale: locale));

    // SplashScreen shows "Loading…"
    expect(find.text('Loading…'), findsOneWidget);

    // Advance time to let Splash navigate to /home (Timer = 8s)
    await tester.pump(const Duration(seconds: 9));

    // HomeScreen bottom bar shows "Map" tab label
    expect(find.text('Map'), findsOneWidget);
  });
}
