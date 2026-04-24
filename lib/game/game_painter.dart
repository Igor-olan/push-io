import 'package:flutter/material.dart';
import '../game/game_logic.dart';
import '../theme.dart';

class GamePainter extends CustomPainter {
  final GameState gameState;
  final Size screenSize;

  GamePainter({required this.gameState, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawMapBounds(canvas);
    _drawDangerZone(canvas, size);
    _drawPlayers(canvas);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Dark background
    final bgPaint = Paint()..color = AppColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid dots
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  void _drawMapBounds(Canvas canvas) {
    final mapPaint = Paint()
      ..color = AppColors.surface.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(gameState.mapBounds, mapPaint);

    // Map border
    final borderPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRect(gameState.mapBounds, borderPaint);

    // Glow on border
    final glowPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRect(gameState.mapBounds, glowPaint);
  }

  void _drawDangerZone(Canvas canvas, Size size) {
    // Red danger outside map
    final dangerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(gameState.mapBounds)
      ..fillType = PathFillType.evenOdd;

    final dangerPaint = Paint()
      ..color = Colors.red.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dangerPath, dangerPaint);

    // Danger stripes
    final stripePaint = Paint()
      ..color = Colors.red.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.save();
    canvas.clipPath(dangerPath);
    for (double i = -size.height; i < size.width + size.height; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), stripePaint);
    }
    canvas.restore();
  }

  void _drawPlayers(Canvas canvas) {
    for (final player in gameState.players) {
      if (!player.isAlive) continue;
      _drawPlayer(canvas, player);
    }
  }

  void _drawPlayer(Canvas canvas, Player player) {
    final pos = player.position;
    final r = player.radius;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(pos + const Offset(3, 5), r, shadowPaint);

    // Glow if sprinting
    if (player.isSprintActive) {
      final glowPaint = Paint()
        ..color = player.color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(pos, r + 6, glowPaint);
    }

    // Main circle with gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.9,
      colors: [
        _lightenColor(player.color, 0.3),
        player.color,
        _darkenColor(player.color, 0.2),
      ],
    );
    final playerPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: pos, radius: r),
      );
    canvas.drawCircle(pos, r, playerPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(pos, r, borderPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos + Offset(-r * 0.25, -r * 0.25), r * 0.35, highlightPaint);

    // Player label
    final textSpan = TextSpan(
      text: player.name,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Dash cooldown arc
    if (player.dashCooldownRemaining > 0) {
      final cooldownFrac = player.dashCooldownRemaining / kDashCooldown;
      final cooldownPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: pos, radius: r + 5),
        -3.14 / 2,
        2 * 3.14 * cooldownFrac,
        false,
        cooldownPaint,
      );
    }
  }

  Color _lightenColor(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount)!;
  }

  Color _darkenColor(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount)!;
  }

  @override
  bool shouldRepaint(GamePainter old) => true;
}
