import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/how_to_play_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PushIOApp());
}

class PushIOApp extends StatelessWidget {
  const PushIOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PUSH.IO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4FC3F7),
          surface: const Color(0xFF0D1B2A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/how-to-play': (context) => const HowToPlayScreen(),
        '/game': (context) => const GameScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/result') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ResultScreen(
              isWin: args['isWin'] as bool,
              killed: args['killed'] as int,
              surviveTime: args['surviveTime'] as int,
            ),
          );
        }
        return null;
      },
    );
  }
}
