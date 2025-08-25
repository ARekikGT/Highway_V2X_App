import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({
    super.key,
    this.onThemeModeChanged,
    this.onLocaleChanged,
  });

  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ValueChanged<Locale?>? onLocaleChanged;

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  // Clés de persistance
  static const _kThemeKey = 'pref_theme_mode'; // 0=system,1=light,2=dark
  static const _kLocaleKey = 'pref_locale'; // 'fr' | 'en'
  static const _kFollowKey = 'pref_follow_location'; // bool
  static const _kMinPriorityKey = 'pref_filter_min_priority'; // int 1..5

  // État local
  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'fr';
  bool _followLocation = false;
  int _minPriority = 1;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = ThemeMode.values[(sp.getInt(_kThemeKey) ?? 0).clamp(0, 2)];
      final lang = sp.getString(_kLocaleKey) ?? 'fr';
      _languageCode = (lang == 'en' || lang == 'fr') ? lang : 'fr';
      _followLocation = sp.getBool(_kFollowKey) ?? false;
      _minPriority = (sp.getInt(_kMinPriorityKey) ?? 1).clamp(1, 5);
    });
  }

  Future<void> _saveTheme(ThemeMode m) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kThemeKey, m.index);
    setState(() => _themeMode = m);
    widget.onThemeModeChanged?.call(m);
  }

  Future<void> _saveLanguage(String code) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLocaleKey, code);
    setState(() => _languageCode = code);
    widget.onLocaleChanged?.call(Locale(code));
  }

  Future<void> _saveFollow(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kFollowKey, v);
    setState(() => _followLocation = v);
  }

  Future<void> _saveMinPriority(int p) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kMinPriorityKey, p);
    setState(() => _minPriority = p);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('Preferences', style: t.titleLarge),

          // Thème (radios simples)
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ListTile(title: Text('Theme')),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: _themeMode,
                  onChanged: (m) => _saveTheme(m ?? ThemeMode.system),
                  title: const Text('System (OS default)'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: _themeMode,
                  onChanged: (m) => _saveTheme(m ?? ThemeMode.system),
                  title: const Text('Light'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: _themeMode,
                  onChanged: (m) => _saveTheme(m ?? ThemeMode.system),
                  title: const Text('Dark'),
                ),
              ],
            ),
          ),

          // Langue (radios simples)
          Card(
            child: Column(
              children: [
                const ListTile(title: Text('Language / Langue')),
                RadioListTile<String>(
                  value: 'fr',
                  groupValue: _languageCode,
                  onChanged: (v) => _saveLanguage(v ?? 'fr'),
                  title: const Text('Français'),
                ),
                RadioListTile<String>(
                  value: 'en',
                  groupValue: _languageCode,
                  onChanged: (v) => _saveLanguage(v ?? 'fr'),
                  title: const Text('English'),
                ),
              ],
            ),
          ),

          // Toggles indispensables
          const SizedBox(height: 8),
          Text('Toggles', style: t.titleLarge),
          SwitchListTile(
            value: _followLocation,
            onChanged: _saveFollow,
            title: const Text('Follow my location'),
            subtitle: Text(
              _languageCode == 'fr'
                  ? 'Utilise la position pour centrer la carte et les alertes proches.'
                  : 'Uses your location to center the map and nearby alerts.',
            ),
          ),
          ListTile(
            title: const Text('Filter: Show P ≥ N'),
            subtitle: Text('N = $_minPriority (1..5)'),
            trailing: SizedBox(
              width: 220,
              child: Slider(
                min: 1,
                max: 5,
                divisions: 4,
                value: _minPriority.toDouble(),
                label: '$_minPriority',
                onChanged: (v) => _saveMinPriority(v.round()),
              ),
            ),
          ),

          // Legal minimal (texte simple, pas de dépendances)
          const SizedBox(height: 12),
          Text('Legal / Mentions légales', style: t.titleLarge),
          Card(
            child: ListTile(
              title: const Text('Privacy & Terms'),
              subtitle: const Text('Résumé court (FR/EN)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLegalDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showLegalDialog(BuildContext context) {
    final isFr = _languageCode == 'fr';
    final title = isFr ? 'Mentions légales' : 'Legal';
    final body =
        isFr
            ? 'Confidentialité : la localisation n’est utilisée que si « Suivre ma position » est activé.\n'
                'Conditions : application informative, ne remplace pas le Code de la route. Conduisez selon les lois locales. Réf. : Convention de Vienne (1968).'
            : 'Privacy: location is used only if “Follow my location” is enabled.\n'
                'Terms: informational app; does not replace traffic laws. Always follow local laws. Ref: Vienna Convention (1968).';

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isFr ? 'Fermer' : 'Close'),
              ),
            ],
          ),
    );
  }
}
