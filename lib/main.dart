import 'package:flutter/material.dart';
import 'package:nir_app/models/settings.dart';
import 'package:nir_app/screens/home_screen.dart';
import 'package:nir_app/services/speech_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Create shared instances
    final settings = AppSettings();
    final speechService = SpeechService();

    return MaterialApp(
      title: 'Сравнение речи',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: HomeScreen(settings: settings, speechService: speechService),
    );
  }
}
