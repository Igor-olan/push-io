import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/game_screen.dart';
import 'screens/win_screen.dart';
import 'screens/lose_screen.dart';

void main() {
  runApp(const PushIOApp());
}

class PushIOApp extends StatelessWidget {
  const PushIOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      routes: {
        '/': (_) => const HomeScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/game': (_) => const GameScreen(),
        '/win': (_) => const WinScreen(),
        '/lose': (_) => const LoseScreen(),
      },
    );
  }
}