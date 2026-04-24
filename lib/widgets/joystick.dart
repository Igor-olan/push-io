import 'dart:math';
import 'package:flutter/material.dart';

class Joystick extends StatefulWidget {
  final Function(Offset direction) onChanged;

  const Joystick({super.key, required this.onChanged});

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset knobPosition = Offset.zero;
  final double radius = 60;

  void _update(Offset localPosition) {
    final center = Offset(radius, radius);
    Offset delta = localPosition - center;

    if (delta.distance > radius) {
      delta = Offset.fromDirection(delta.direction, radius);
    }

    setState(() {
      knobPosition = delta;
    });

    // normalize (-1 to 1)
    final normalized = delta / radius;
    widget.onChanged(normalized);
  }

  void _end() {
    setState(() {
      knobPosition = Offset.zero;
    });
    widget.onChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (d) => _update(d.localPosition),
      onPanEnd: (_) => _end(),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Center(
          child: Transform.translate(
            offset: knobPosition,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}