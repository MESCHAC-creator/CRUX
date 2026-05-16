# Flutter App

Un exemple simple d'application Flutter.

## Installation

### Prérequis

- Flutter SDK installé ([Installation guide](https://flutter.dev/docs/get-started/install))
- Un éditeur de code (VS Code, Android Studio, ou IntelliJ)

### Démarrage

```bash
# Cloner le dépôt
git clone https://github.com/MESCHAC-creator/Crux.git
cd Crux

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## Structure du projet

```
.
├── lib/
│   └── main.dart          # Point d'entrée de l'application
├── test/
│   └── widget_test.dart   # Tests unitaires
├── pubspec.yaml           # Configuration du projet
├── analysis_options.yaml  # Options d'analyse Dart
├── .gitignore            # Fichiers à ignorer
└── README.md             # Ce fichier
```

## Développement

### Exécuter les tests

```bash
flutter test
```

### Générer un build de production

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## Ressources

- [Documentation Flutter](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Flutter Packages](https://pub.dev)

## Licence

MIT
