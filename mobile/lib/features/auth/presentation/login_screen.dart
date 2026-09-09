import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../app/theme/kairos_theme.dart';
import '../data/auth_repository.dart';
import '../../../core/network/connectivity_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    await ref.read(authProvider.notifier).login(
      _identifierController.text.trim(),
      _passwordController.text,
    );

    if (mounted) setState(() => _isLoading = false);

    final error = ref.read(authProvider).error;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: KairosTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityProvider);
    final isOnline = connectivity.valueOrNull ?? true;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KairosTheme.radius16),
            ),
            title: Text(
              'Exit KAIROS?',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: KairosTheme.primaryNavy,
              ),
            ),
            content: Text(
              'Are you sure you want to exit the application?',
              style: GoogleFonts.inter(color: KairosTheme.textPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('EXIT', style: TextStyle(color: KairosTheme.error)),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/auth_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header hero
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                        KairosTheme.spacing32, 
                        MediaQuery.of(context).padding.top + KairosTheme.spacing32, 
                        KairosTheme.spacing32, 
                        KairosTheme.spacing32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: KairosTheme.cardWhite,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: KairosTheme.spacing16),
                      Text(
                        'KAIROS',
                        style: GoogleFonts.plusJakartaSans(
                          color: KairosTheme.primaryNavy,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(color: KairosTheme.surfaceWhite.withValues(alpha: 0.8), blurRadius: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Field Investigation Platform',
                        style: GoogleFonts.inter(
                          color: KairosTheme.primaryNavy.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Login form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: KairosTheme.spacing24, vertical: KairosTheme.spacing32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(KairosTheme.spacing24),
                        decoration: BoxDecoration(
                          color: KairosTheme.surfaceWhite.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: KairosTheme.surfaceWhite.withValues(alpha: 0.9),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: KairosTheme.primaryNavy.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Officer Login',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: KairosTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: KairosTheme.spacing8),
                        Text(
                          'Sign in with your employee credentials',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: KairosTheme.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: KairosTheme.spacing24),

                        // Connection status banner
                        if (!isOnline) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: KairosTheme.spacing16, vertical: KairosTheme.spacing12),
                            decoration: BoxDecoration(
                              color: KairosTheme.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(KairosTheme.radius12),
                              border: Border.all(
                                  color: KairosTheme.warning.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.wifi_off_rounded,
                                    color: KairosTheme.warning, size: 18),
                                const SizedBox(width: KairosTheme.spacing8),
                                Text(
                                  'No internet connection',
                                  style: GoogleFonts.inter(
                                      color: KairosTheme.warning,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: KairosTheme.spacing24),
                        ],

                        // Employee ID field
                        TextFormField(
                          controller: _identifierController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          style: GoogleFonts.inter(
                              color: KairosTheme.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Employee ID or Email',
                            labelStyle: GoogleFonts.inter(
                                color: KairosTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                            hintText: 'e.g. OFF-001',
                            hintStyle: GoogleFonts.inter(
                                color: KairosTheme.textMuted, fontSize: 13),
                            prefixIcon: const Icon(Icons.badge_outlined,
                                color: KairosTheme.textSecondary, size: 20),
                            filled: true,
                            fillColor: KairosTheme.surfaceWhite.withValues(alpha: 0.9),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: KairosTheme.spacing16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KairosTheme.radius12),
                              borderSide: BorderSide(color: KairosTheme.primaryNavy.withValues(alpha: 0.15)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KairosTheme.radius12),
                              borderSide: BorderSide(color: KairosTheme.primaryNavy.withValues(alpha: 0.15)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KairosTheme.radius12),
                              borderSide: const BorderSide(
                                  color: KairosTheme.primaryNavy, width: 1.5),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Employee ID or email is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: KairosTheme.spacing16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.inter(
                              color: KairosTheme.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.inter(
                                color: KairosTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: KairosTheme.textSecondary, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: KairosTheme.textSecondary,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: KairosTheme.surfaceWhite.withValues(alpha: 0.9),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: KairosTheme.spacing16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KairosTheme.radius12),
                              borderSide: BorderSide(color: KairosTheme.primaryNavy.withValues(alpha: 0.15)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KairosTheme.radius12),
                              borderSide: BorderSide(color: KairosTheme.primaryNavy.withValues(alpha: 0.15)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(KairosTheme.radius12),
                              borderSide: const BorderSide(
                                  color: KairosTheme.primaryNavy, width: 1.5),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),
                        const SizedBox(height: KairosTheme.spacing24),

                        // Login button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              backgroundColor: KairosTheme.primaryNavy,
                              disabledBackgroundColor:
                                  KairosTheme.primaryNavy.withOpacity(0.5),
                              elevation: 6,
                              shadowColor: KairosTheme.primaryNavy.withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(KairosTheme.radius12),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: Lottie.asset(
                                      'assets/animations/loading.json',
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.login_rounded,
                                          size: 18, color: KairosTheme.cardWhite),
                                      const SizedBox(width: 8),
                                      Text(
                                        'LOGIN',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: KairosTheme.cardWhite,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: KairosTheme.spacing24),

                        // Security notice
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: KairosTheme.spacing16, vertical: KairosTheme.spacing12),
                          decoration: BoxDecoration(
                            color: KairosTheme.info.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(KairosTheme.radius12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.shield_outlined,
                                  size: 16, color: KairosTheme.info.withOpacity(0.8)),
                              const SizedBox(width: KairosTheme.spacing12),
                              Expanded(
                                child: Text(
                                  'Authorized personnel only. Access is monitored.',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: KairosTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

                // Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      KairosTheme.spacing24, 0, KairosTheme.spacing24, KairosTheme.spacing32),
                  child: Column(
                    children: [
                      Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              KairosTheme.saffron,
                              KairosTheme.cardWhite,
                              KairosTheme.seaGreen,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: KairosTheme.spacing12),
                      Text(
                        'NTRO • Smart India Hackathon 2026',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: KairosTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
