import 'package:flutter/material.dart';
import '../widgets/round_button.dart';

class WinScreen extends StatelessWidget {
  const WinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "YOU WIN",
              style: TextStyle(color: Colors.white, fontSize: 32),
            ),
            const SizedBox(height: 40),

            RoundButton(
              text: "PLAY AGAIN",
              onTap: () {
                Navigator.pushReplacementNamed(context, '/game');
              },
            ),

            const SizedBox(height: 20),

            RoundButton(
              text: "MENU",
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}