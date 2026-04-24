import 'package:flutter/material.dart';
import '../widgets/round_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F2D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "PUSH.IO",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundButton(
                  text: "START",
                  onTap: () {
                    Navigator.pushNamed(context, '/game');
                  },
                ),
                const SizedBox(width: 30),
                RoundButton(
                  text: "SETTINGS",
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}