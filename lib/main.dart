import 'package:flutter/material.dart';
import 'package:nimble_neck/pages/recordings_page.dart';

/// Starts the app [NimbleNeckApp]
void main() {
  runApp(const NimbleNeckApp());
}

/// Creates a Material 3 app
/// Sets the [RecordingsPage] as starting point
class NimbleNeckApp extends StatelessWidget {
  const NimbleNeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nimble Neck',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const RecordingsPage(),
    );
  }
}
