# 🚦 RoadSafe Alerts (veh_app)
_A privacy-respecting road-safety alerts app built with Flutter. Map-first, batteries included._

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg?logo=flutter)](https://docs.flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/Android%20%7C%20iOS%20%7C%20Web-multi--platform-brightgreen)](https://flutter.dev/multi-platform)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](#license)

> _Note:_ Adjust the app/package name as needed (e.g., `com.example.veh_app`).

---

## ✨ What it does

- 🗺️ **Live map** powered by [`flutter_map`](https://pub.dev/packages/flutter_map) (Leaflet ecosystem).
- 📍 **Location** features with [`geolocator`](https://pub.dev/packages/geolocator).
- 🔔 **Notifications** (local) via [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) and optional **push** via Firebase Cloud Messaging.
- 🔎 **Readable alerts feed** (sample generator in the Alerts page; can be wired to **Cloud Firestore** for real data).
- ⚙️ **User preferences** persisted through [`shared_preferences`](https://pub.dev/packages/shared_preferences) (theme, locale, filters).
- 🌍 **i18n-ready** (`flutter_localizations`) with ARB-based generation.

> The sample includes a deterministic alerts generator for demos/tests. Swap in Firestore to go live.

---

## 🧱 Tech stack

- **Flutter** (Dart 3) — Android · iOS · Web  
- **flutter_map** + optional offline tile caching  
- **Geolocator** for permissions & GPS  
- **Shared Preferences** for lightweight storage  
- **Firebase (optional)**: Cloud Firestore (read-only), Cloud Messaging (push)  
- **Local notifications** for on-device alerts

---

## 📦 Project layout (high-level)

```text
lib/
  main.dart
  screens/
    splash_screen.dart
    home_screen.dart
    map_page.dart
    alerts_page.dart
    preferences_page.dart
assets/
  images/roadsafe_logo.png
android/
  build.gradle(.kts)
  app/build.gradle(.kts)
ios/
  Runner/...
```
# 1) Install dependencies
flutter pub get

# 2) Run in debug
flutter run -d <device_id>

# 3) Build artifacts
flutter build apk      # Android
flutter build ios      # iOS (requires Xcode setup)
flutter build web      # Web (optional)


#🧭 Features & UX

1) Follow-me map with a “follow location” toggle
2) Priority filter to surface relevant alerts
3) Dark/Light/System theme toggle
4) Locale switch (en/fr) ready

