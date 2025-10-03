# 🚦 RoadSafe Alerts — *veh_app*
*A privacy-respecting road-safety alerts app built with Flutter. Map-first, batteries included.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg?logo=flutter)](https://docs.flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/Android%20%7C%20iOS%20%7C%20Web-multi--platform-brightgreen)](https://flutter.dev/multi-platform)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](#license)
[![CI](https://img.shields.io/badge/CI-ready-success)](#)
[![Code style](https://img.shields.io/badge/style-dartfmt-informational)](https://dart.dev/tools/dart-format)

> **Package ID:** adjust as needed (e.g., `com.example.veh_app`).

---

## 🗂️ Table of contents
- [✨ Features](#-features)
- [🧱 Tech stack](#-tech-stack)
- [📱  App Video](#-app-video)
- [📦 Project layout](#-project-layout)
- [⚡ Quick start](#-quick-start)
- [📲 Platform setup & permissions](#-platform-setup--permissions)
- [🔁 Data & privacy](#-data--privacy)
- [🧭 Architecture](#-architecture)
- [☁️ Optional: Firebase wiring](#️-optional-firebase-wiring)
- [🧪 Testing](#-testing)
- [🗺️ Maps & tiles](#️-maps--tiles)
- [🧑‍🤝‍🧑 Contributing](#-contributing)
- [🗺️ Roadmap](#️-roadmap)
- [📚 References (EN & FR)](#-references-en--fr)
- [📜 License](#-license)

---

## ✨ Features
- 🗺️ **Live map** via [`flutter_map`](https://pub.dev/packages/flutter_map) (Leaflet ecosystem).
- 📍 **Precise location** with [`geolocator`](https://pub.dev/packages/geolocator).
- 🔔 **Notifications** (local) using [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications); optional **push** with Firebase Cloud Messaging.
- 🔎 **Readable alerts feed** (ships with a deterministic sample generator; plug into **Cloud Firestore** for real data).
- ⚙️ **User preferences** with [`shared_preferences`](https://pub.dev/packages/shared_preferences) (theme, locale, filters).
- 🌍 **i18n-ready** via `flutter_localizations` and ARB-based generation.
- 🌓 **Dark/Light/System** themes; **EN/FR** locale toggle ready.

> The sample data generator is deterministic for demos/tests. Swap in Firestore to go live.

---

## 🧱 Tech stack
- **Flutter** (Dart 3) — Android · iOS · Web  
- **flutter_map** + optional offline tile caching  
- **Geolocator** for permissions & GPS  
- **Shared Preferences** for lightweight storage  
- **Firebase (optional)**: Firestore (read-only), Cloud Messaging (push)  
- **Local notifications** for on-device alerts

---
## 📱 App Video:


https://github.com/user-attachments/assets/3acda7f6-6487-4ed1-a35b-e3e75ed8ac20


---
## 📦 Project layout

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
---

## ⚡ Quick start

```bash
# 1) Install dependencies
flutter pub get

# 2) Run in debug (pick your device)
flutter devices
flutter run -d <device_id>

# 3) Build artifacts
flutter build apk      # Android
flutter build ios      # iOS (Xcode required)
flutter build web      # Web (optional)
```
## ✨ Feature highlights
- 🗺️ **Follow-me map** with a *Follow location* toggle  
- 🚨 **Priority filter** to surface relevant alerts  
- 🌓 **Theme toggle** (Dark · Light · System)  
- 🌍 **Locale switch** (EN / FR ready)  

---

## 📲 Platform setup & permissions

### Android
- ✅ Ensure `compileSdkVersion` / `targetSdkVersion` are set appropriately.  
- ✅ Add required permissions in `AndroidManifest.xml`:  
  - `ACCESS_COARSE_LOCATION`  
  - `ACCESS_FINE_LOCATION`  
  - (Android 10+) `ACCESS_BACKGROUND_LOCATION`  
- ✅ Configure **notification channels** for local & push notifications.  

### iOS
- ✅ Enable *Location Updates* and *Background Modes* in Xcode.  
- ✅ Add the following to `Info.plist`:  
  - `NSLocationWhenInUseUsageDescription`  
  - *(optional)* `NSLocationAlwaysAndWhenInUseUsageDescription`  
- ✅ Request **notification authorization** on first run.  

> ⚠️ **Safety notice**: This app is for *awareness only*, not for interaction while driving.  
> Always keep your eyes on the road.  

---

## 🔁 Data & privacy
- 🔒 **Privacy-first**: local preferences only; *no tracking* or analytics baked in.  
- ☁️ **Optional cloud**: if connected to Firebase, reads are usually **read-only** and limited to alerts data.  
- 📍 **Location data** stays on device, except when explicitly shared for push geofencing (optional).  



# 🗺️ AlertMap — README

## 🧭 Architecture

### 📱 Presentation
├── Screens (Map / Alerts / Preferences)
└── Widgets (atoms / molecules)


### ⚙️ Application
├── State (Riverpod / Provider / BLoC — pick your flavor)
└── Services (Location, Notifications, Repository)


### 🗄️ Data
├── Local (SharedPreferences)
└── Remote (Firestore - optional)


🔑 **Principes clés :**
- **Map-first UX** : les alertes sont spatiales → la carte est la surface principale.  
- **Générateur déterministe** pour simuler des alertes → idéal pour démo & tests.  
- **☁️ Firebase (optionnel)** :  
  - Crée un projet Firebase + ajoute Android / iOS / Web.  
  - Active **Cloud Firestore** (lecture seule pour démo publique ou sécurisé).  
  - Active **Cloud Messaging** pour push alerts.  
  - Ajoute les configs générées (`google-services.json`, `GoogleService-Info.plist`, config web).  
  - Initialise Firebase dans `main.dart`.  

---

## 🧪 Testing

### 🔍 Analyse & formatage
```bash
flutter analyze
dart format .
```
### ✅ Tests unitaires & widgets
```bash
flutter test
```
# ✨ Tips & Roadmap

## 💡 Astuces
- 🟡 Ajouter des **golden tests** pour les widgets de carte.  
- 🟢 Utiliser du **snapshot testing** pour les cartes d’alertes.  

---

## 🗺️ Maps & Tiles
- 🌍 **Source par défaut** : [OpenStreetMap](https://www.openstreetmap.org) (compliant public tiles).  
- 📜 Respecter les **Terms of Use** & **rate limits**.  

### 🔧 En production :
- 🔒 Considérer un **hébergement de tuiles** ou un **provider commercial**.  
- ⚡ Activer le **caching** si autorisé.  

---

## 🧑‍🤝‍🧑 Contributing
Contributions bienvenues ! 🎉  

Merci de :  
- ✅ Lancer **linters/tests** avant vos PRs.  
- 🔐 Garder les features **privacy-first** par défaut.  
- 💬 Discuter tout **breaking change** dans les issues avant merge.  

---

## 🛣️ Roadmap
- ✅ Vérification en arrière-plan des alertes & **throttling intelligent**  
- 🗂️ **Tuiles hors-ligne configurables**  
- ♿ **Audit basique d’accessibilité** (TalkBack / VoiceOver)  
- 🌍 **Support multi-langues** (ar, es, …)  
- 🔗 **Deep-linking** vers alertes spécifiques  

---

## 📌 Badges
![Flutter](https://img.shields.io/badge/Flutter-Framework-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-Language-blue?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Optional-orange?logo=firebase)
![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-Tiles-green?logo=openstreetmap)
