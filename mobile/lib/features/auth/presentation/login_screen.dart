import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    await ref.read(authProvider.notifier).login(
      _identifierController.text.trim(),
      _passwordController.text,
    );

    if (mounted) setState(() => _isLoading = false);

    final error = ref.read(authProvider).error;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: KairosTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityProvider);
    final isOnline = connectivity.valueOrNull ?? true;

    return Scaffold(
      backgroundColor: KairosTheme.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header hero
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [KairosTheme.deepNavy, KairosTheme.navyBlue],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: KairosTheme.oceanBlue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.satellite_alt_rounded,
                          size: 38,
                          color: KairosTheme.oceanBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'KAIROS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Field Investigation Platform',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Login form
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Officer Login',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: KairosTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in with your employee credentials',
                        style: TextStyle(
                          fontSize: 13,
                          color: KairosTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Connection status banner
                      if (!isOnline) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: KairosTheme.warning.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: KairosTheme.warning.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.wifi_off,
                                  color: KairosTheme.warning, size: 16),
                              const SizedBox(width: 8),
                              const Text(
                                'No internet connection',
                                style: TextStyle(
                                    color: KairosTheme.warning,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Employee ID field
                      TextFormField(
                        controller: _identifierController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Employee ID or Email',
                          hintText: 'e.g. OFF-001',
                          prefixIcon: Icon(Icons.badge_outlined,
                              color: KairosTheme.oceanBlue),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Employee ID or email is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: KairosTheme.oceanBlue),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: KairosTheme.textSecondary,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
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
                      const SizedBox(height: 28),

                      // Login button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            backgroundColor: KairosTheme.oceanBlue,
                            disabledBackgroundColor:
                                KairosTheme.oceanBlue.withOpacity(0.5),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login, size: 20),
                                    SizedBox(width: 8),
                                    Text('LOGIN',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.5)),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Security notice
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: KairosTheme.surfaceGrey,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: KairosTheme.borderGrey),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.security, size: 16,
                                color: KairosTheme.teal),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Authorized personnel only. All access is logged and monitored.',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: KairosTheme.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    Container(
                      height: 2,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            KairosTheme.saffron,
                            Colors.white,
                            KairosTheme.govGreen,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'NTRO · Smart India Hackathon 2026',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10, color: KairosTheme.textMuted),
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
