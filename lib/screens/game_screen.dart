import 'package:flutter/material.dart';
import '../network/socket_service.dart';
import '../models/player.dart';
import '../widgets/joystick.dart';
import '../widgets/game_painter.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SocketService socket;

  Map<String, PlayerModel> players = {};
  String myId = "";

  Offset input = Offset.zero;
  bool sprint = false;

  bool isConnected = false;
  bool isLoading = true;
  bool hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initConnection();
  }

  @override
  void dispose() {
    socket.channel.sink.close();
    super.dispose();
  }

  Future<void> _initConnection() async {
    socket = SocketService();

    bool found = await socket.connectAuto();

    if (!found) {
      // connect manual kalau perlu (ubah IP)
      socket.connectManual("192.168.1.10");
    }

    socket.onState = (data) {
      final Map<String, PlayerModel> updated = {};

      data['players'].forEach((id, p) {
        updated[id] = PlayerModel.fromJson(id, p);
      });

      if (!mounted) return;

      setState(() {
        players = updated;
        myId = socket.myId;
        isConnected = true;
        isLoading = false;
      });

      _checkGameEnd();
    };
  }

  void _sendInput({bool dash = false}) {
    if (!isConnected) return;

    socket.sendInput(
      input.dx,
      input.dy,
      sprint,
      dash,
    );
  }

  void _checkGameEnd() {
    if (hasNavigated) return;
    if (myId.isEmpty || !players.containsKey(myId)) return;

    final me = players[myId]!;

    // kalah
    if (!me.alive) {
      hasNavigated = true;
      Navigator.pushReplacementNamed(context, '/lose');
      return;
    }

    // menang
    final alivePlayers =
        players.values.where((p) => p.alive).toList();

    if (alivePlayers.length == 1 &&
        alivePlayers.first.id == myId) {
      hasNavigated = true;
      Navigator.pushReplacementNamed(context, '/win');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F2D),
      body: Stack(
        children: [
          /// ================= GAME =================
          if (!isLoading)
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: GamePainter(players, myId),
            ),

          /// ================= LOADING =================
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          /// ================= STATUS =================
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              isConnected ? "Connected" : "Connecting...",
              style: const TextStyle(color: Colors.white),
            ),
          ),

          /// ================= SETTINGS =================
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const SettingsScreen(isInGame: true),
                  ),
                );
              },
            ),
          ),

          /// ================= PLAYER COUNT =================
          Positioned(
            top: 70,
            left: 20,
            child: Text(
              "Alive: ${players.values.where((p) => p.alive).length}",
              style: const TextStyle(color: Colors.white),
            ),
          ),

          /// ================= JOYSTICK =================
          Positioned(
            bottom: 40,
            left: 30,
            child: Joystick(
              onChanged: (dir) {
                input = dir;
                _sendInput();
              },
            ),
          ),

          /// ================= DASH =================
          Positioned(
            bottom: 60,
            right: 40,
            child: ElevatedButton(
              onPressed: () => _sendInput(dash: true),
              child: const Text("DASH"),
            ),
          ),

          /// ================= SPRINT =================
          Positioned(
            bottom: 130,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                sprint = !sprint;
                setState(() {});
                _sendInput();
              },
              child: Text(sprint ? "SPRINT ON" : "SPRINT"),
            ),
          ),
        ],
      ),
    );
  }
}