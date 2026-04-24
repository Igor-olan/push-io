import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_logic.dart';
import '../game/game_painter.dart';
import '../game/settings.dart';
import '../theme.dart';
import '../widgets/joystick.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameState _gameState;
  late Timer _gameTimer;
  Offset _joystickInput = Offset.zero;
  bool _isSprinting = false;
  bool _showTutorial = true;
  bool _showPauseMenu = false;
  DateTime _lastFrame = DateTime.now();
  String _username = 'You';
  int _killCount = 0;
  bool _gameEnded = false;

  final GameSettings _settings = GameSettings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGame();
    });

    // Hide tutorial after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showTutorial = false);
    });
  }

  void _initGame() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _username = args?['username'] ?? 'You';

    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight * 0.5;
    final bottomPad = 220.0; // Controls area

    final mapWidth = size.width * 0.85;
    final mapHeight = (size.height - topPad - bottomPad) * 0.9;
    final mapLeft = (size.width - mapWidth) / 2;
    final mapTop = topPad + 20;

    final mapBounds = Rect.fromLTWH(mapLeft, mapTop, mapWidth, mapHeight);
    final center = mapBounds.center;

    final players = [
      Player(
        id: 'human',
        name: _username,
        color: AppColors.playerSelf,
        position: Offset(center.dx, center.dy + mapHeight * 0.2),
        isBot: false,
      ),
      Player(
        id: 'bot1',
        name: 'Player 1',
        color: AppColors.player1,
        position: Offset(center.dx + mapWidth * 0.25, center.dy - mapHeight * 0.2),
        isBot: true,
      ),
      Player(
        id: 'bot2',
        name: 'Player 2',
        color: AppColors.player2,
        position: Offset(center.dx - mapWidth * 0.25, center.dy - mapHeight * 0.1),
        isBot: true,
      ),
      Player(
        id: 'bot3',
        name: 'Player 3',
        color: AppColors.player4,
        position: Offset(center.dx, center.dy - mapHeight * 0.35),
        isBot: true,
      ),
    ];

    setState(() {
      _gameState = GameState(players: players, mapBounds: mapBounds);
    });

    _startGameLoop();
  }

  void _startGameLoop() {
    _lastFrame = DateTime.now();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_showPauseMenu) return;

      final now = DateTime.now();
      final dt = now.difference(_lastFrame).inMilliseconds / 1000.0;
      _lastFrame = now;

      setState(() {
        _gameState.update(
          dt.clamp(0, 0.05),
          _joystickInput,
          _isSprinting,
        );

        // Track kills
        final human = _gameState.humanPlayer;
        if (human != null) {
          _killCount = human.killCount;
        }
      });

      if (_gameState.isGameOver && !_gameEnded) {
        _gameEnded = true;
        timer.cancel();
        _handleGameOver();
      }
    });
  }

  void _handleGameOver() {
    final human = _gameState.humanPlayer;
    final isWin = _gameState.humanWon;
    final surviveTime = human?.surviveTime.toInt() ?? 0;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/result',
          arguments: {
            'isWin': isWin,
            'killed': _killCount,
            'surviveTime': surviveTime,
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    super.dispose();
  }

  void _onDash() {
    if (_settings.vibration) {
      HapticFeedback.mediumImpact();
    }
    final human = _gameState.humanPlayer;
    if (human != null && _joystickInput != Offset.zero) {
      setState(() {
        human.dash(_joystickInput);
      });
    } else if (human != null) {
      // Dash in movement direction based on velocity
      final vel = human.velocity;
      if (vel.distance > 0) {
        setState(() {
          human.dash(vel / vel.distance);
        });
      }
    }
  }

  String _formatTime(double seconds) {
    final s = seconds.toInt();
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted || _gameEnded) return const Scaffold(backgroundColor: AppColors.background);

    final isRightHanded = _settings.rightHanded;
    final alivePlayers = _gameState.alivePlayers;
    final human = _gameState.humanPlayer;
    final dashCooldown = human?.dashCooldownRemaining ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Game canvas
          CustomPaint(
            painter: GamePainter(
              gameState: _gameState,
              screenSize: MediaQuery.of(context).size,
            ),
            size: MediaQuery.of(context).size,
          ),

          // HUD - Timer
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Settings gear
                      GestureDetector(
                        onTap: () {
                          setState(() => _showPauseMenu = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.settings, color: Colors.white, size: 22),
                        ),
                      ),
                      // Timer
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _formatTime(_gameState.timeRemaining),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Players alive
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Player alive:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            ...alivePlayers.map((p) => Text(
                                  p.name,
                                  style: TextStyle(
                                    color: p.color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tutorial overlay
          if (_showTutorial)
            GestureDetector(
              onTap: () => setState(() => _showTutorial = false),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: SafeArea(
                  child: Column(
                    children: [
                      const Spacer(),
                      // Controls annotations
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _TutorialAnnotation(
                              'Drag joystick\nto move',
                              isLeft: true,
                            ),
                            const Spacer(),
                            _TutorialAnnotation(
                              'Press sprint\nto move faster\nand dash to leap',
                              isLeft: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 180),
                      const Text(
                        'Tap anywhere to go back',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

          // Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: isRightHanded
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Joystick(
                            onDirectionChanged: (dir) {
                              _joystickInput = dir;
                            },
                            size: 110,
                          ),
                          const Spacer(),
                          _buildActionButtons(dashCooldown),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildActionButtons(dashCooldown),
                          const Spacer(),
                          Joystick(
                            onDirectionChanged: (dir) {
                              _joystickInput = dir;
                            },
                            size: 110,
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Pause menu overlay
          if (_showPauseMenu)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: SettingsScreen(
                isInGame: true,
                onBack: () => setState(() => _showPauseMenu = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double dashCooldown) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Sprint
        GestureDetector(
          onTapDown: (_) => setState(() => _isSprinting = true),
          onTapUp: (_) => setState(() => _isSprinting = false),
          onTapCancel: () => setState(() => _isSprinting = false),
          child: _ActionButton(
            label: 'SPRINT',
            isActive: _isSprinting,
            color: AppColors.accent,
            size: 64,
          ),
        ),
        const SizedBox(height: 8),
        // Dash
        GestureDetector(
          onTap: dashCooldown <= 0 ? _onDash : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _ActionButton(
                label: 'DASH',
                isActive: false,
                color: dashCooldown > 0
                    ? AppColors.surfaceLight
                    : const Color(0xFF7E57C2),
                size: 64,
              ),
              if (dashCooldown > 0)
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: 1 - (dashCooldown / kDashCooldown),
                    strokeWidth: 3,
                    color: const Color(0xFF7E57C2),
                    backgroundColor: Colors.transparent,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final double size;

  const _ActionButton({
    required this.label,
    required this.isActive,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.6),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(isActive ? 1 : 0.4),
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _TutorialAnnotation extends StatelessWidget {
  final String text;
  final bool isLeft;

  const _TutorialAnnotation(this.text, {required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        textAlign: isLeft ? TextAlign.left : TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }
}
