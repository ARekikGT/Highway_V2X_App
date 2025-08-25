import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:shared_preferences/shared_preferences.dart';

/// Clés SharedPreferences (mêmes que PreferencesPage)
const _kFollowKey = 'pref_follow_location'; // bool
const _kMinPriorityKey = 'pref_filter_min_priority'; // int 1..5

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  final MapController _mapController = MapController();

  StreamSubscription<Position>? _posSub;
  bool _followLocation = false;
  bool _hasLocationPermission = false;
  int _minPriority = 1;

  // Centre par défaut (Paris)
  static const _defaultCenter = ll.LatLng(48.8566, 2.3522);
  static const _defaultZoom = 11.5;

  // Démo : données fictives (remplace par tes alertes réelles)
  final List<_Alert> _alerts = const [
    _Alert(id: 'a1', title: 'Oil spill', p: 3, pos: ll.LatLng(48.86, 2.35)),
    _Alert(id: 'a2', title: 'Fog', p: 1, pos: ll.LatLng(48.83, 2.30)),
    _Alert(id: 'a3', title: 'Accident', p: 5, pos: ll.LatLng(48.88, 2.37)),
    _Alert(id: 'a4', title: 'Potholes', p: 2, pos: ll.LatLng(48.90, 2.34)),
    _Alert(id: 'a5', title: 'Roadwork', p: 4, pos: ll.LatLng(48.85, 2.41)),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPrefsThenInitLocation();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPrefsThenInitLocation();
    }
  }

  Future<void> _loadPrefsThenInitLocation() async {
    final sp = await SharedPreferences.getInstance();
    final follow = sp.getBool(_kFollowKey) ?? false;
    final minP = (sp.getInt(_kMinPriorityKey) ?? 1).clamp(1, 5);

    setState(() {
      _followLocation = follow;
      _minPriority = minP;
    });

    await _ensurePermission();
    _restartPositionStreamIfNeeded();
  }

  Future<void> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    var permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      setState(() => _hasLocationPermission = false);
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    setState(
      () =>
          _hasLocationPermission =
              permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always,
    );
  }

  void _restartPositionStreamIfNeeded() {
    _posSub?.cancel();
    if (!_followLocation || !_hasLocationPermission) return;

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((pos) {
      if (!_followLocation) return;
      final zoom = _safeZoom();
      _mapController.move(ll.LatLng(pos.latitude, pos.longitude), zoom);
    });
  }

  double _safeZoom() {
    // MapController.camera est dispo après rendu initial ; sinon on retombe sur le zoom par défaut.
    try {
      return _mapController.camera.zoom;
    } catch (_) {
      return _defaultZoom;
    }
  }

  Future<void> _jumpToMyLocationOnce() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final zoom = (_safeZoom() < 13) ? 14.5 : _safeZoom();
      _mapController.move(ll.LatLng(pos.latitude, pos.longitude), zoom);
    } catch (_) {
      /* ignore */
    }
  }

  List<Marker> _buildMarkers() {
    return _alerts.where((a) => a.p >= _minPriority).map((a) {
      return Marker(
        point: a.pos,
        width: 40,
        height: 40,
        child: _priorityPin(a.p, a.title),
      );
    }).toList();
  }

  Widget _priorityPin(int p, String title) {
    final color = switch (p) {
      5 => Colors.red,
      4 => Colors.orange,
      3 => Colors.pink,
      2 => Colors.green,
      _ => Colors.cyan,
    };
    return Tooltip(
      message: '$title (P=$p)',
      child: Icon(Icons.place, color: color, size: 36),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: _defaultZoom,
              // On capte les événements si tu veux réagir aux zoom/moves :
              onMapEvent: (evt) {
                // Exemple: setState(() {}); // rafraîchir un overlay si besoin
              },
            ),
            children: [
              // Tu peux changer de fournisseur de tuiles (OSM, Stadia, Thunderforest, etc.)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roadsafe.app', // remplace par ton ID
                maxZoom: 19,
              ),
              MarkerLayer(markers: markers),
              // Attribution OSM (recommandé)
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    onTap: () => debugPrint('Attribution tapped'),
                  ),
                ],
              ),
            ],
          ),
          // Overlay "filtre"
          Positioned(
            top: 16,
            left: 16,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text('Filter: P ≥ $_minPriority'),
              ),
            ),
          ),
          if (_followLocation)
            Positioned(
              top: 16,
              right: 16,
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.my_location, size: 18),
                      SizedBox(width: 6),
                      Text('Following'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _jumpToMyLocationOnce,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

/// Modèle d’alerte de démo
class _Alert {
  final String id;
  final String title;
  final int p; // priorité 1..5
  final ll.LatLng pos; // <-- LatLng de latlong2
  const _Alert({
    required this.id,
    required this.title,
    required this.p,
    required this.pos,
  });
}
