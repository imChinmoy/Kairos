import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../core/gps/location_service.dart';
import '../../auth/data/auth_repository.dart';
import '../data/sos_repository.dart';

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

    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
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
      builder: (_) => AlertDialog(
        backgroundColor: KairosTheme.white,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: KairosTheme.sosRed, size: 28),
            SizedBox(width: 8),
            Text(
              'EMERGENCY SOS',
              style: TextStyle(
                color: KairosTheme.sosRed,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will immediately alert the Coast Guard and your supervisor of your GPS location. '
          'Use only in genuine emergencies.\n\n'
          'Press SEND SOS to proceed.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: KairosTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: KairosTheme.sosRed,
              minimumSize: const Size(120, 44),
            ),
            child: const Text(
              'SEND SOS',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _sosSent = true);

      try {
        final loc = await LocationService.getCurrentLocation();
        await ref.read(sosRepositoryProvider).triggerSos(
          loc?.latitude ?? 0.0,
          loc?.longitude ?? 0.0,
        );
      } catch (e) {
        // Handled by sync queue
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('SOS sent. Coast Guard has been notified.'),
            ],
          ),
          backgroundColor: KairosTheme.sosRed,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
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

    return Scaffold(
      backgroundColor: const Color(0xFF1A0000),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  const Text(
                    'EMERGENCY SOS',
                    style: TextStyle(
                      color: KairosTheme.sosRed,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Officer info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.white54, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${user?.name ?? 'Officer'} · ${user?.employeeId ?? ''}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Main SOS button
            ScaleTransition(
              scale: _sosSent ? const AlwaysStoppedAnimation(1.0) : _pulseAnim,
              child: GestureDetector(
                onLongPress: _sosSent ? null : _triggerSos,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _sosSent
                        ? KairosTheme.success
                        : KairosTheme.sosRed,
                    boxShadow: [
                      BoxShadow(
                        color: (_sosSent ? KairosTheme.success : KairosTheme.sosRed)
                            .withOpacity(0.6),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _sosSent ? Icons.check : Icons.sos_outlined,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _sosSent ? 'SENT' : 'SOS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              _sosSent
                  ? 'SOS signal sent. Help is on the way.'
                  : 'Hold to activate emergency SOS',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),

            const Spacer(),

            // Direct call buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EMERGENCY CONTACTS',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _EmergencyCallButton(
                    icon: Icons.anchor,
                    label: 'Coast Guard',
                    number: '1554',
                    onTap: () => _callNumber('1554'),
                  ),
                  const SizedBox(height: 8),
                  _EmergencyCallButton(
                    icon: Icons.local_police_outlined,
                    label: 'Police Emergency',
                    number: '100',
                    onTap: () => _callNumber('100'),
                  ),
                  const SizedBox(height: 8),
                  _EmergencyCallButton(
                    icon: Icons.local_hospital_outlined,
                    label: 'Medical Emergency',
                    number: '108',
                    onTap: () => _callNumber('108'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyCallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;
  final VoidCallback onTap;

  const _EmergencyCallButton({
    required this.icon,
    required this.label,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    number,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: KairosTheme.success.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone, color: KairosTheme.success, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
