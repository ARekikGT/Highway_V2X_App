import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _t;

  // 🔽 Chemin de ton logo dans le projet Flutter
  final ImageProvider _logo = const AssetImage(
    'assets/images/roadsafe_logo.png',
  );

  @override
  void initState() {
    super.initState();

    // Pré-cache le logo pour éviter tout "flicker"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(_logo, context);
    });

    _t = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: _logo,
              width: 128,
              fit: BoxFit.contain,
              semanticLabel: 'RoadSafe logo',
            ),
            const SizedBox(height: 24),
            const Text('Loading…'),
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
