import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

/// Clés partagées avec PreferencesPage
const _kThemeKey = 'pref_theme_mode'; // 0=system,1=light,2=dark
const _kLocaleKey = 'pref_locale'; // 'fr' | 'en'

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lire les préférences sauvegardées (synchro au boot)
  final sp = await SharedPreferences.getInstance();
  final themeIndex = (sp.getInt(_kThemeKey) ?? 0).clamp(0, 2);
  final savedLang = sp.getString(_kLocaleKey) ?? 'fr'; // défaut FR

  // Notifiers pour rafraîchir MaterialApp à chaud
  final themeMode = ValueNotifier<ThemeMode>(ThemeMode.values[themeIndex]);
  final locale = ValueNotifier<Locale?>(Locale(savedLang));

  runApp(RoadSafeApp(themeMode: themeMode, locale: locale));
}

class RoadSafeApp extends StatelessWidget {
  const RoadSafeApp({super.key, required this.themeMode, required this.locale});
  final ValueNotifier<ThemeMode> themeMode;
  final ValueNotifier<Locale?> locale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([themeMode, locale]),
      builder:
          (_, __) => MaterialApp(
            title: 'RoadSafe Alerts',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode.value,

            // ✅ Utilise le constructeur général ThemeData(...)
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.red,
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.red,
                brightness: Brightness.dark,
              ),
            ),

            // Localisation
            locale: locale.value,
            supportedLocales: const [Locale('en'), Locale('fr')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,

            initialRoute: '/',
            routes: {
              '/': (_) => const SplashScreen(),
              '/home':
                  (_) => HomeScreen(
                    onThemeModeChanged: (m) => themeMode.value = m,
                    onLocaleChanged: (l) => locale.value = l,
                  ),
            },
          ),
    );
  }
}
