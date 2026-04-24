import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final bool isInGame;

  const SettingsScreen({super.key, this.isInGame = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F2D),
      body: Column(
        children: [
          const SizedBox(height: 60),

          const Text(
            "SETTINGS",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),

          const SizedBox(height: 40),

          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text("Sound", style: TextStyle(color: Colors.white)),
          ),

          const Spacer(),

          if (isInGame)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("RETURN TO GAME"),
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("BACK"),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}