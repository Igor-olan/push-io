import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/push_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController =
      TextEditingController(text: 'Player');
  late AnimationController _animController;
  late Animation<double> _titleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _titleAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background particles
          const _BackgroundParticles(),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  // Title
                  ScaleTransition(
                    scale: _titleAnim,
                    child: Column(
                      children: [
                        Text(
                          'PUSH.IO',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                            letterSpacing: 6,
                            shadows: [
                              Shadow(
                                color: AppColors.accent,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '● BATTLE ARENA ●',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 4,
                            color: AppColors.accent.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Username
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Username',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.4),
                              width: 1.5,
                            ),
                            color: AppColors.surfaceLight.withOpacity(0.3),
                          ),
                          child: TextField(
                            controller: _usernameController,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Username',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Buttons
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        PushButton(
                          label: 'PLAY NOW',
                          isPrimary: true,
                          onPressed: () {
                            final username = _usernameController.text.trim();
                            if (username.isEmpty) return;
                            Navigator.pushNamed(
                              context,
                              '/game',
                              arguments: {'username': username},
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        PushButton(
                          label: 'SETTING',
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                        const SizedBox(height: 12),
                        PushButton(
                          label: 'HOW TO PLAY',
                          onPressed: () {
                            Navigator.pushNamed(context, '/how-to-play');
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundParticles extends StatefulWidget {
  const _BackgroundParticles();

  @override
  State<_BackgroundParticles> createState() => _BackgroundParticlesState();
}

class _BackgroundParticlesState extends State<_BackgroundParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ParticlesPainter(_controller.value),
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double t;
  static final List<_Particle> _particles = List.generate(
    12,
    (i) => _Particle(i),
  );

  _ParticlesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      p.draw(canvas, size, t);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => true;
}

class _Particle {
  final int seed;
  late double x, y, r, speed, phase;

  _Particle(this.seed) {
    final rng = seed * 1234567;
    x = (rng % 100) / 100.0;
    y = ((rng * 7) % 100) / 100.0;
    r = 2.0 + (rng % 4);
    speed = 0.2 + (rng % 3) * 0.15;
    phase = (rng % 100) / 100.0;
  }

  void draw(Canvas canvas, Size size, double t) {
    final animT = (t * speed + phase) % 1.0;
    final opacity = (animT < 0.5 ? animT : 1 - animT) * 0.4;
    final paint = Paint()
      ..color = AppColors.accent.withOpacity(opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(x * size.width, y * size.height),
      r,
      paint,
    );
  }
}
