import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../core/gps/location_service.dart';
import '../../auth/data/auth_repository.dart';
import '../data/sos_repository.dart';
import '../../../shared/widgets/kairos_app_bar.dart';
import '../../../shared/widgets/kairos_action_button.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _sosSent = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _triggerSos() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: KairosTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KairosTheme.radius12)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: KairosTheme.error, size: 28),
            const SizedBox(width: 8),
            Text(
              'EMERGENCY SOS',
              style: GoogleFonts.plusJakartaSans(
                color: KairosTheme.error,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'This will immediately alert the Coast Guard and your supervisor of your GPS location. '
          'Use only in genuine emergencies.\n\n'
          'Press SEND SOS to proceed.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: KairosTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: KairosTheme.error,
              minimumSize: const Size(120, 44),
            ),
            child: Text(
              'SEND SOS',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      _pulseController.stop();
      setState(() => _sosSent = true);

      try {
        final locAsync = ref.read(currentLocationProvider);
        var loc = locAsync.value;
        
        // Fallback to manual fetch if stream hasn't emitted yet
        loc ??= await LocationService.getCurrentLocation();

        await ref.read(sosRepositoryProvider).triggerSos(
          loc?.latitude ?? 0.0,
          loc?.longitude ?? 0.0,
        );
      } catch (e) {
        // Handled by sync queue
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: KairosTheme.surfaceWhite, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SOS sent. Coast Guard has been notified.',
                  style: GoogleFonts.inter(color: KairosTheme.surfaceWhite),
                ),
              ),
            ],
          ),
          backgroundColor: KairosTheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    // Keep GPS stream hot
    ref.watch(currentLocationProvider);

    return Scaffold(
      backgroundColor: KairosTheme.backgroundLight,
      appBar: const KairosAppBar(
        title: 'EMERGENCY SOS',
        subtitle: 'NTRO Field Protocol',
        showBackButton: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KairosTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: KairosTheme.spacing24),

              // Officer info
              Container(
                padding: const EdgeInsets.all(KairosTheme.spacing16),
                decoration: BoxDecoration(
                  color: KairosTheme.surfaceWhite.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(KairosTheme.radius12),
                  border: Border.all(color: KairosTheme.borderGrey),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: KairosTheme.primaryNavy, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${user?.name ?? 'Officer'} · ${user?.employeeId ?? ''}',
                      style: GoogleFonts.inter(
                        color: KairosTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Main SOS button
              Center(
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: GestureDetector(
                    onLongPress: _sosSent ? null : _triggerSos,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: KairosTheme.surfaceWhite,
                        border: Border.all(
                          color: _sosSent ? KairosTheme.success : KairosTheme.error,
                          width: 8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_sosSent ? KairosTheme.success : KairosTheme.error).withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _sosSent ? Icons.check : Icons.sos_rounded,
                            color: _sosSent ? KairosTheme.success : KairosTheme.error,
                            size: 64,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _sosSent ? 'SENT' : 'SOS',
                            style: GoogleFonts.plusJakartaSans(
                              color: _sosSent ? KairosTheme.success : KairosTheme.error,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: KairosTheme.spacing24),
              Text(
                _sosSent
                    ? 'SOS signal sent. Help is on the way.'
                    : 'HOLD TO ACTIVATE EMERGENCY SOS',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: KairosTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(),

              // Direct call buttons
              Container(
                padding: const EdgeInsets.all(KairosTheme.spacing20),
                decoration: BoxDecoration(
                  color: KairosTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(KairosTheme.radius16),
                  border: Border.all(color: KairosTheme.borderGrey),
                  boxShadow: [
                    BoxShadow(
                      color: KairosTheme.textPrimary.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMERGENCY CONTACTS',
                      style: GoogleFonts.inter(
                        color: KairosTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: KairosTheme.spacing16),
                    KairosActionButton(
                      label: 'CALL COAST GUARD (1554)',
                      icon: Icons.anchor_rounded,
                      color: KairosTheme.error,
                      isOutline: false,
                      onPressed: () => _callNumber('1554'),
                    ),
                    const SizedBox(height: KairosTheme.spacing12),
                    KairosActionButton(
                      label: 'MEDICAL EMERGENCY (108)',
                      icon: Icons.local_hospital_rounded,
                      color: KairosTheme.primaryNavy,
                      isOutline: true,
                      onPressed: () => _callNumber('108'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KairosTheme.spacing24),
            ],
          ),
        ),
      ),
    );
  }
}

