# graduation_project

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 🛠️ Firebase Setup
This project uses Firebase. To protect our production environment, the configuration files are ignored by Git.

To run the project with your own Firebase instance:
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/).
2. Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`.
3. Run `flutterfire configure`.
4. This will generate your own `lib/firebase_options.dart` and native config files.

