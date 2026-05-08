import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _taglineFade;
  late Animation<double> _dotsFade;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
      ),
    );

    _dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _glowPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _entryController.forward();

    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AuthGate(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 900),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Ambient Background Glow ───────────────────────────────
          // Soft warm-gold bloom centered behind the logo (top half),
          // separate from the orange logo dots so they don't wash out.
          AnimatedBuilder(
            animation: _glowPulse,
            builder: (_, __) => Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.15),
                    radius: 0.75,
                    colors: [
                      const Color(0xFFFFCC66).withAlpha(
                        (_glowPulse.value * 18).round(),
                      ),
                      AppTheme.backgroundDark.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Floating Particles ────────────────────────────────────
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(
                progress: _particleController.value,
                width: size.width,
                height: size.height,
              ),
            ),
          ),

          // ── Main Content ──────────────────────────────────────────
          Column(
            children: [
              const Spacer(flex: 3),

              // Logo
              AnimatedBuilder(
                animation: _entryController,
                builder: (_, __) => FadeTransition(
                  opacity: _logoFade,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: AnimatedBuilder(
                      animation: _glowPulse,
                      builder: (_, __) => SizedBox(
                        width: 240,
                        height: 240,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer diffuse halo
                            Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFFFAA40).withAlpha(
                                      (_glowPulse.value * 55).round(),
                                    ),
                                    const Color(0xFFFF6B35).withAlpha(
                                      (_glowPulse.value * 20).round(),
                                    ),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                            // Inner bright halo
                            Container(
                              width: 165,
                              height: 165,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFFFE0A0).withAlpha(
                                      (_glowPulse.value * 70).round(),
                                    ),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 1.0],
                                ),
                              ),
                            ),
                            // Logo — no clip, transparent bg dots pop on the halo
                            Image.asset(
                              AppAssets.appLogo,
                              width: 190,
                              height: 190,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 44),

              // App name + tagline
              AnimatedBuilder(
                animation: _entryController,
                builder: (_, __) => SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        // BREATH NOISE
                        Text(
                          'BREATH NOISE',
                          style: GoogleFonts.poppins(
                            color: AppTheme.warmCream,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 5.0,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // SOUNDS — gradient text
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.fireGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: Text(
                            'SOUNDS',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 8.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Divider line
                        FadeTransition(
                          opacity: _taglineFade,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 1,
                                color: AppTheme.mutedGray.withAlpha(80),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'ATMOSPHERIC SOUNDSCAPES',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.mutedGray,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3.0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 40,
                                height: 1,
                                color: AppTheme.mutedGray.withAlpha(80),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Loading indicator
              AnimatedBuilder(
                animation: _entryController,
                builder: (_, __) => FadeTransition(
                  opacity: _dotsFade,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: _PulsingDots(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Pulsing dots loading indicator ───────────────────────────────────────────

class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i / 3;
          final t = ((_ctrl.value - delay) % 1.0 + 1.0) % 1.0;
          final scale = 0.6 + 0.4 * math.sin(t * math.pi);
          final alpha = (80 + 120 * math.sin(t * math.pi)).round().clamp(0, 255);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.amberGold.withAlpha(alpha),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Floating ember particles ──────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double progress;
  final double width;
  final double height;

  static final _rng = math.Random(42);
  static final _particles = List.generate(18, (i) {
    return _Particle(
      x: _rng.nextDouble(),
      startY: 0.7 + _rng.nextDouble() * 0.3,
      speed: 0.04 + _rng.nextDouble() * 0.06,
      radius: 1.0 + _rng.nextDouble() * 2.2,
      drift: (_rng.nextDouble() - 0.5) * 0.06,
      phase: _rng.nextDouble(),
    );
  });

  const _ParticlePainter({
    required this.progress,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (progress + p.phase) % 1.0;
      final py = p.startY - t * p.speed * 10;
      if (py < -0.05 || py > 1.0) continue;

      final px = p.x + math.sin(t * math.pi * 2) * p.drift;
      final opacity = (math.sin(t * math.pi) * 0.55).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = AppTheme.amberGold.withAlpha((opacity * 255).round())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(px * width, py * height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x;
  final double startY;
  final double speed;
  final double radius;
  final double drift;
  final double phase;

  const _Particle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.radius,
    required this.drift,
    required this.phase,
  });
}
