import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  // --- Simulation config ---
  static const int kMaxVisible = 20; // purge au-delà
  static const int kTotalToGenerate = 30;
  static const Duration kTick = Duration(seconds: 2); // 30 en 60 s
  static const Duration kHardStop = Duration(minutes: 1);

  final List<_AlertItem> _items = <_AlertItem>[];
  Timer? _ticker;
  Timer? _deadline;
  int _generated = 0;
  final _rng = Random();

  // 5 cas (libellés + priorité initiale + exemples de messages + brèves descriptions)
  final List<_CaseDef> _cases = const [
    _CaseDef(
      label: 'Vitesse faible constante',
      basePriority: 1,
      samples: [
        "Vitesse réduite détectée",
        "Trafic ralenti",
        "Déplacement lent et constant",
      ],
      briefs: ["Ralentissement prolongé", "Trafic dense", "Flux lent"],
    ),
    _CaseDef(
      label: 'Comportement zigzag',
      basePriority: 2,
      samples: [
        "Trajectoire irrégulière",
        "Zigzag détecté",
        "Corrections de direction fréquentes",
      ],
      briefs: [
        "Trajectoire instable",
        "Oscillations latérales",
        "Conduite imprécise",
      ],
    ),
    _CaseDef(
      label: 'Vitesse élevée constante',
      basePriority: 3,
      samples: [
        "Vitesse élevée soutenue",
        "Seuil vitesse dépassé",
        "Allure rapide constante",
      ],
      briefs: ["Allure rapide", "Risque vitesse", "Peu de marge"],
    ),
    _CaseDef(
      label: 'Changement brusque de voie',
      basePriority: 4,
      samples: [
        "Changement de voie soudain",
        "Manœuvre latérale rapide",
        "Déport brusque détecté",
      ],
      briefs: ["Manœuvre agressive", "Déport soudain", "Écart non anticipé"],
    ),
    _CaseDef(
      label: 'Accident détecté',
      basePriority: 5,
      samples: [
        "Accident détecté",
        "Collision probable",
        "Alerte incident critique",
      ],
      briefs: ["Incident critique", "Risque majeur", "Zone danger"],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _deadline?.cancel();
    super.dispose();
  }

  // Lance/relance la génération
  void _startSimulation() {
    _ticker?.cancel();
    _deadline?.cancel();
    setState(() {
      _items.clear();
      _generated = 0;
    });

    _ticker = Timer.periodic(kTick, (_) {
      if (_generated >= kTotalToGenerate) {
        _finish();
        return;
      }
      _addRandomAlert();
    });

    _deadline = Timer(kHardStop, _finish);
  }

  void _finish() {
    _ticker?.cancel();
    _deadline?.cancel();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            // ignore: unnecessary_brace_in_string_interps
            'Simulation terminée (${_generated}/${kTotalToGenerate})',
          ),
        ),
      );
      setState(() {});
    }
  }

  void _addRandomAlert() {
    final def = _cases[_rng.nextInt(_cases.length)];
    final msg = def.samples[_rng.nextInt(def.samples.length)];
    final brief = def.briefs[_rng.nextInt(def.briefs.length)];

    // Petite “randomisation” d’escalade (sauf P5 qui reste P5)
    int prio = def.basePriority;
    if (prio < 5) {
      final escalate = _rng.nextInt(10) == 0; // ~10% de chance
      if (escalate) prio = (prio + 1).clamp(1, 5);
    }

    final now = DateTime.now();

    final item = _AlertItem(
      id: now.microsecondsSinceEpoch.toString(),
      category: def.label,
      message: msg,
      brief: brief, // << nouvelle brève description
      priority: prio,
      timestamp: now, // << timestamp exact
    );

    setState(() {
      // Ajoute en haut
      _items.insert(0, item);
      _generated++;

      // Purge: conserve les 20 plus récentes
      if (_items.length > kMaxVisible) {
        _items.removeRange(kMaxVisible, _items.length);
      }
    });
  }

  // Couleur par priorité (palette demandée)
  Color _priorityColor(int p) => switch (p) {
    1 => const Color(0xFF4CAF50), // P1
    2 => const Color(0xFFFFC107), // P2
    3 => const Color(0xFFFF9800), // P3
    4 => const Color(0xFFF44336), // P4
    5 => const Color(0xFFB71C1C), // P5
    _ => const Color(0xFFFF9800),
  };

  // Horodatage court HH:mm:ss (sans dépendance externe)
  String _fmtTime(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    final lt = t.toLocal();
    return '${two(lt.hour)}:${two(lt.minute)}:${two(lt.second)}';
  }

  String _relativeShort(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 5) return 'à l’instant';
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    return '${d.inHours}h';
  }

  bool get _isRunning => (_ticker?.isActive ?? false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isRunning
              // ignore: unnecessary_brace_in_string_interps
              ? 'Alerts'
              // ignore: unnecessary_brace_in_string_interps
              : 'Alerts ',
        ),
        actions: [
          IconButton(
            tooltip: 'Restart simulation',
            onPressed: _startSimulation,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body:
          _items.isEmpty
              ? const Center(child: Text('En attente des alertes…'))
              : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final a = _items[i];
                  final c = _priorityColor(a.priority);
                  return Container(
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: c.withOpacity(.10),
                      border: Border.all(color: c, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ligne 1 : badge Pn + catégorie
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: c,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'P${a.priority}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                a.category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Ligne 2 : message
                        Text(a.message),

                        const SizedBox(height: 6),

                        // Ligne 3 : brève description (italique) + timestamp (HH:mm:ss • relatif)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                a.brief,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(
                                    context,
                                    // ignore: deprecated_member_use
                                  ).textTheme.bodySmall?.color?.withOpacity(.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${_fmtTime(a.timestamp)} • ${_relativeShort(a.timestamp)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

// ---------- petits types internes ----------
class _CaseDef {
  final String label;
  final int basePriority; // 1..5
  final List<String> samples;
  final List<String> briefs;
  const _CaseDef({
    required this.label,
    required this.basePriority,
    required this.samples,
    required this.briefs,
  });
}

class _AlertItem {
  final String id;
  final String category;
  final String message;
  final String brief; // << nouveau
  final int priority;
  final DateTime timestamp;
  const _AlertItem({
    required this.id,
    required this.category,
    required this.message,
    required this.brief,
    required this.priority,
    required this.timestamp,
  });
}
