import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../app/theme/kairos_theme.dart';
import '../data/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.7)),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (prev, next) {
      if (!next.isLoading) {
        if (next.isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              KairosTheme.deepNavy,
              KairosTheme.navyBlue,
              KairosTheme.oceanBlue,
            ],
            stops: [0, 0.5, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Government branding strip
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ministry of Ports, Shipping and Waterways\nGovernment of India',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 10,
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Main content
              AnimatedBuilder(
                animation: _controller,
                builder: (_, child) => FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(scale: _scaleAnim, child: child),
                ),
                child: Column(
                  children: [
                    // Logo circle with maritime icon
                    Container(
                      width: 116,
                      height: 116,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: KairosTheme.tealLight.withOpacity(0.35),
                            blurRadius: 50,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            width: 116,
                            height: 116,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // KAIROS wordmark
                    const Text(
                      'KAIROS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Field Intelligence for Safer Seas',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Maritime wave decoration
                    SizedBox(
                      width: 300,
                      height: 64,
                      child: CustomPaint(painter: _WavePainter()),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    // Tricolor accent bar
                    Container(
                      height: 3,
                      width: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          colors: [
                            KairosTheme.saffron,
                            Colors.white,
                            KairosTheme.govGreen,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Clean Seas  ·  Secure Coasts  ·  Stronger India',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Lottie.asset(
                        'assets/animations/loading.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    _drawWave(canvas, size, paint1, 0, 0.5);
    _drawWave(canvas, size, paint2, math.pi / 3, 0.65);
  }

  void _drawWave(
      Canvas canvas, Size size, Paint paint, double offset, double heightFactor) {
    final path = Path();
    path.moveTo(0, size.height * heightFactor);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * heightFactor +
          12 * math.sin(x / size.width * 2 * math.pi + offset) +
          5 * math.sin(x / size.width * 4 * math.pi + offset);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
