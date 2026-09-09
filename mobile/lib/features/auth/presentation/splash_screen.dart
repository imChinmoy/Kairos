import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _minTimeElapsed = false;

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

    // Enforce a minimum splash duration of 2.5 seconds so the animation can play fully
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (mounted) {
        setState(() => _minTimeElapsed = true);
        _navigateIfReady();
      }
    });
  }

  void _navigateIfReady() {
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (!authState.isLoading && _minTimeElapsed) {
      if (authState.isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (prev, next) {
      _navigateIfReady();
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.asset(
            'assets/images/bg_image.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // 2. Soft Light Overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.white.withOpacity(0.35),
                  const Color(0xFFE0F2FE).withOpacity(0.20), // Light blue fade
                ],
              ),
            ),
          ),
          
          // Additional subtle bottom fade to ensure text readability if needed
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),

          // 3. KAIROS Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                
                // Main Content
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) => FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(scale: _scaleAnim, child: child),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: KairosTheme.cardWhite,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: KairosTheme.primaryNavy.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: KairosTheme.spacing20),
                      
                      // KAIROS Wordmark
                      Text(
                        'KAIROS',
                        style: GoogleFonts.plusJakartaSans(
                          color: KairosTheme.primaryNavy,
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: KairosTheme.spacing8),
                      
                      // Subtitle
                      Text(
                        'Field Investigation Platform',
                        style: GoogleFonts.inter(
                          color: KairosTheme.primaryNavy.withOpacity(0.85),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: KairosTheme.spacing24),
                      
                      // Subtle Tricolor Accent Line
                      Container(
                        height: 2,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [
                              KairosTheme.saffron,
                              KairosTheme.cardWhite,
                              KairosTheme.seaGreen,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 4),
                
                // Bottom Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: KairosTheme.spacing32),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Lottie.asset(
                          'assets/animations/loading.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: KairosTheme.spacing16),
                      Text(
                        'Clean Oceans  |  Secure Coasts',
                        style: GoogleFonts.inter(
                          color: KairosTheme.primaryNavy,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: KairosTheme.spacing8),
                      Text(
                        'NTRO • Smart India Hackathon 2026',
                        style: GoogleFonts.inter(
                          color: KairosTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

