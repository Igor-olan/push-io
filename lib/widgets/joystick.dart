import 'dart:math';
import 'package:flutter/material.dart';

class Joystick extends StatefulWidget {
  final Function(Offset) onDirectionChanged;
  final double size;

  const Joystick({
    super.key,
    required this.onDirectionChanged,
    this.size = 120,
  });

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset _knobOffset = Offset.zero;
  bool _isDragging = false;

  void _handlePanStart(DragStartDetails details) {
    _isDragging = true;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final maxDist = widget.size / 2 - 20;

    Offset newOffset = _knobOffset + details.delta;
    final dist = newOffset.distance;

    if (dist > maxDist) {
      newOffset = newOffset / dist * maxDist;
    }

    setState(() {
      _knobOffset = newOffset;
    });

    final direction = newOffset.distance > 5
        ? newOffset / newOffset.distance
        : Offset.zero;
    widget.onDirectionChanged(direction);
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _knobOffset = Offset.zero;
      _isDragging = false;
    });
    widget.onDirectionChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _JoystickPainter(
            knobOffset: _knobOffset,
            isDragging: _isDragging,
          ),
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final Offset knobOffset;
  final bool isDragging;

  _JoystickPainter({required this.knobOffset, required this.isDragging});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Base circle
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width / 2, basePaint);

    // Base border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, size.width / 2, borderPaint);

    // Knob
    final knobCenter = center + knobOffset;
    final knobPaint = Paint()
      ..color = isDragging
          ? Colors.white.withOpacity(0.7)
          : Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(knobCenter, size.width / 4, knobPaint);
  }

  @override
  bool shouldRepaint(_JoystickPainter old) =>
      old.knobOffset != knobOffset || old.isDragging != isDragging;
}
