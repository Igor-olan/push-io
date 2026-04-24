import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/push_button.dart';

class ResultScreen extends StatefulWidget {
  final bool isWin;
  final int killed;
  final int surviveTime;

  const ResultScreen({
    super.key,
    required this.isWin,
    required this.killed,
    required this.surviveTime,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _titleScale;
  late Animation<double> _cardSlide;
  late Animation<double> _buttonsSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _titleScale = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    _cardSlide = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    );
    _buttonsSlide = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background effect
          if (widget.isWin) _WinParticles() else _DeathBackground(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // Title
                  ScaleTransition(
                    scale: _titleScale,
                    child: Column(
                      children: [
                        Text(
                          widget.isWin ? 'You Win!' : 'You Are Dead',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: widget.isWin ? 42 : 36,
                            fontWeight: FontWeight.w900,
                            color: widget.isWin
                                ? AppColors.accent
                                : AppColors.white,
                            letterSpacing: 1,
                            shadows: widget.isWin
                                ? [
                                    Shadow(
                                      color: AppColors.accent.withOpacity(0.6),
                                      blurRadius: 20,
                                    )
                                  ]
                                : null,
                            decoration: !widget.isWin
                                ? TextDecoration.underline
                                : null,
                            decorationColor:
                                AppColors.accent.withOpacity(0.6),
                            decorationThickness: 3,
                          ),
                        ),
                        if (!widget.isWin) ...[
                          const SizedBox(height: 12),
                          Text(
                            _getDeathMessage(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Stats card
                  AnimatedBuilder(
                    animation: _cardSlide,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _cardSlide.value)),
                        child: Opacity(
                          opacity: _cardSlide.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: (widget.isWin ? AppColors.accent : AppColors.danger)
                              .withOpacity(0.25),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isWin
                                    ? AppColors.accent
                                    : AppColors.danger)
                                .withOpacity(0.08),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _StatRow(
                            label: 'Killed',
                            value: widget.killed.toString(),
                            icon: Icons.sports_kabaddi,
                          ),
                          const SizedBox(height: 14),
                          Divider(
                            color: AppColors.surfaceLight,
                            height: 1,
                          ),
                          const SizedBox(height: 14),
                          _StatRow(
                            label: 'Survive time',
                            value: _formatTime(widget.surviveTime),
                            icon: Icons.timer_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Buttons
                  AnimatedBuilder(
                    animation: _buttonsSlide,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - _buttonsSlide.value)),
                        child: Opacity(
                          opacity: _buttonsSlide.value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        PushButton(
                          label: 'PLAY AGAIN',
                          isPrimary: true,
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/game');
                          },
                        ),
                        const SizedBox(height: 12),
                        PushButton(
                          label: 'RETURN TO HOME',
                          onPressed: () {
                            Navigator.popUntil(context, (r) => r.isFirst);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDeathMessage() {
    final messages = [
      'Git Gud',
      'Try Again!',
      'You Got Pushed!',
      'Off The Edge!',
      'Better Luck Next Time',
    ];
    return messages[widget.killed % messages.length];
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        const Spacer(),
        const Text(
          ': ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _WinParticles extends StatefulWidget {
  @override
  State<_WinParticles> createState() => _WinParticlesState();
}

class _WinParticlesState extends State<_WinParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _ConfettiPainter(_ctrl.value),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  static final _rng = Random(42);
  static final _colors = [
    AppColors.accent,
    Colors.yellow,
    Colors.green,
    Colors.pink,
    Colors.orange,
  ];
  static final _particles = List.generate(20, (i) => [
    _rng.nextDouble(), // x
    _rng.nextDouble(), // startY
    _rng.nextDouble() * 0.3 + 0.1, // speed
    _rng.nextDouble() * 4 + 2, // radius
    (_rng.nextInt(5)).toDouble(), // colorIdx
  ]);

  _ConfettiPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final x = p[0] * size.width;
      final speed = p[2];
      final y = ((p[1] + t * speed) % 1.2) * size.height;
      final r = p[3];
      final color = _colors[p[4].toInt()].withOpacity(0.7);
      canvas.drawCircle(Offset(x, y), r, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}

class _DeathBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            AppColors.danger.withOpacity(0.08),
            AppColors.background,
          ],
        ),
      ),
    );
  }
}
