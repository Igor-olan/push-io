import 'package:flutter/material.dart';

class GamePainter extends CustomPainter {
  final Map players;
  final String myId;

  GamePainter(this.players, this.myId);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    players.forEach((id, p) {
      if (!p['alive']) return;

      final isMe = id == myId;

      paint.color = isMe ? Colors.red : Colors.blue;

      canvas.drawCircle(
        Offset(p['x'], p['y']),
        35,
        paint,
      );

      // text nama
      final textPainter = TextPainter(
        text: TextSpan(
          text: id,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(p['x'] - 20, p['y'] - 10),
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}