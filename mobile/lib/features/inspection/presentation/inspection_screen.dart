import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../core/gps/location_service.dart';
import '../data/inspection_repository.dart';
import '../../../shared/widgets/kairos_app_background.dart';
import '../../../shared/widgets/kairos_action_button.dart';

class InspectionScreen extends ConsumerStatefulWidget {
  final String investigationId;

  const InspectionScreen({super.key, required this.investigationId});

  @override
  ConsumerState<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends ConsumerState<InspectionScreen> {
  bool _hasArrived = false;
  bool _inspectionStarted = false;
  LocationData? _arrivalLocation;
  String _inspectionId = 'local-draft-id'; // in production from API

  // Site conditions
  String _seaState = 'MODERATE';
  String _visibility = 'GOOD';
  double _windSpeed = 0;
  bool _oilVisible = false;
  bool _odorPresent = false;
  String _finding = 'PENDING';
  final TextEditingController _notesController = TextEditingController();

  final _states = ['CALM', 'SLIGHT', 'MODERATE', 'ROUGH', 'VERY_ROUGH', 'HIGH'];
  final _visibilities = ['EXCELLENT', 'GOOD', 'MODERATE', 'POOR', 'FOG'];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _recordArrival() async {
    final loc = await LocationService.getCurrentLocation();
    
    try {
      await ref.read(inspectionRepositoryProvider).recordArrival(_inspectionId);
    } catch (e) {
      // Offline queue will handle it
    }

    setState(() {
      _arrivalLocation = loc;
      _hasArrived = true;
      _inspectionStarted = true;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(loc != null
                ? 'Arrival recorded (±${loc.accuracy?.toStringAsFixed(0) ?? '--'}m)'
                : 'Arrival recorded (GPS unavailable)'),
          ],
        ),
        backgroundColor: KairosTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitInspection() async {
    if (_finding == 'PENDING') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a finding before submitting.'),
          backgroundColor: KairosTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // In production: send to API
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submit Inspection?'),
        content: const Text(
          'Once submitted, the inspection cannot be edited. Ensure all observations and evidence have been recorded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(inspectionRepositoryProvider).submitInspection(
                _inspectionId,
                _finding,
                _notesController.text,
                {
                  'seaState': _seaState,
                  'visibility': _visibility,
                  'windSpeed': _windSpeed,
                  'oilVisible': _oilVisible,
                  'odorPresent': _odorPresent,
                },
              );
              
              Navigator.pop(context);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Inspection submitted successfully.'),
                  backgroundColor: KairosTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KairosAppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FIELD INSPECTION', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1.0)),
              Text('NTRO FIELD PROTOCOL', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 10, color: KairosTheme.surfaceWhite.withOpacity(0.7), letterSpacing: 1.5)),
            ],
          ),
          backgroundColor: KairosTheme.primaryNavy,
          foregroundColor: KairosTheme.surfaceWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => context.pop(),
          ),
          actions: [
            // SOS quick access
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: GestureDetector(
                  onTap: () => context.push('/sos'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: KairosTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KairosTheme.radius12),
                      border: Border.all(color: KairosTheme.error.withOpacity(0.5)),
                    ),
                    child: Text(
                      'SOS',
                      style: GoogleFonts.inter(
                        color: KairosTheme.error,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Status banner
          _StatusBanner(
            hasArrived: _hasArrived,
            inspectionStarted: _inspectionStarted,
          ),
          const SizedBox(height: 20),

          // Step 1: Arrival
          _InspectionStep(
            stepNumber: 1,
            title: 'RECORD ARRIVAL',
            subtitle: 'Auto-capture your GPS location upon arriving at the scene',
            isCompleted: _hasArrived,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_arrivalLocation != null)
                  _LocationCard(location: _arrivalLocation!),
                if (_arrivalLocation != null)
                  const SizedBox(height: 12),
                KairosActionButton(
                  label: _hasArrived ? 'ARRIVAL RECORDED' : 'RECORD ARRIVAL',
                  icon: _hasArrived ? Icons.check : Icons.my_location,
                  color: _hasArrived ? KairosTheme.success : KairosTheme.oceanBlue,
                  onPressed: _hasArrived ? () {} : _recordArrival,
                  isOutline: _hasArrived,
                ),
              ],
            ),
          ),

          // Step 2: Site Conditions
          _InspectionStep(
            stepNumber: 2,
            title: 'SITE CONDITIONS',
            subtitle: 'Record current environmental conditions at the scene',
            isCompleted: false,
            enabled: _inspectionStarted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FormLabel('Sea State'),
                Wrap(
                  spacing: 8,
                  children: _states.map((s) => ChoiceChip(
                    label: Text(s),
                    selected: _seaState == s,
                    onSelected: (_) => setState(() => _seaState = s),
                    selectedColor: KairosTheme.oceanBlue,
                    labelStyle: TextStyle(
                      color: _seaState == s ? Colors.white : KairosTheme.textPrimary,
                      fontSize: 12,
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                _FormLabel('Visibility'),
                Wrap(
                  spacing: 8,
                  children: _visibilities.map((v) => ChoiceChip(
                    label: Text(v),
                    selected: _visibility == v,
                    onSelected: (_) => setState(() => _visibility = v),
                    selectedColor: KairosTheme.oceanBlue,
                    labelStyle: TextStyle(
                      color: _visibility == v ? Colors.white : KairosTheme.textPrimary,
                      fontSize: 12,
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                _FormLabel('Wind Speed (km/h)'),
                Slider(
                  value: _windSpeed,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '${_windSpeed.round()} km/h',
                  activeColor: KairosTheme.oceanBlue,
                  onChanged: (v) => setState(() => _windSpeed = v),
                ),
              ],
            ),
          ),

          // Step 3: Oil Observation
          _InspectionStep(
            stepNumber: 3,
            title: 'OIL OBSERVATION',
            subtitle: 'Document any visible oil or contamination at the scene',
            isCompleted: false,
            enabled: _inspectionStarted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ToggleRow(
                  label: 'Visible Oil / Slick',
                  value: _oilVisible,
                  onChanged: (v) => setState(() => _oilVisible = v),
                ),
                _ToggleRow(
                  label: 'Odor Present',
                  value: _odorPresent,
                  onChanged: (v) => setState(() => _odorPresent = v),
                ),
                const SizedBox(height: 12),
                _FormLabel('Inspector\'s Notes'),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe oil color, thickness, spread pattern, wildlife impact...',
                    filled: true,
                    fillColor: KairosTheme.surfaceGrey,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          // Step 4: Evidence & Observations
          _InspectionStep(
            stepNumber: 4,
            title: 'EVIDENCE & OBSERVATIONS',
            subtitle: 'Capture photos and record field observations',
            isCompleted: false,
            enabled: _inspectionStarted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _inspectionStarted
                            ? () => context.push(
                                '/inspections/$_inspectionId/capture?invId=${widget.investigationId}')
                            : null,
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('Capture\nEvidence'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _inspectionStarted
                            ? () => context.push(
                                '/inspections/$_inspectionId/observe')
                            : null,
                        icon: const Icon(Icons.edit_note_outlined, size: 18),
                        label: const Text('Log\nObservation'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Step 5: Finding
          _InspectionStep(
            stepNumber: 5,
            title: 'INSPECTOR\'S FINDING',
            subtitle: 'Record your official assessment of the scene',
            isCompleted: false,
            enabled: _inspectionStarted,
            child: Column(
              children: [
                _FindingOption(
                  label: 'Oil Confirmed',
                  subtitle: 'Visible oil and/or contamination confirmed at scene',
                  color: KairosTheme.error,
                  isSelected: _finding == 'OIL_CONFIRMED',
                  onTap: () => setState(() => _finding = 'OIL_CONFIRMED'),
                ),
                const SizedBox(height: 8),
                _FindingOption(
                  label: 'Oil Suspected',
                  subtitle: 'Evidence suggests oil presence; confirmation pending',
                  color: KairosTheme.warning,
                  isSelected: _finding == 'OIL_SUSPECTED',
                  onTap: () => setState(() => _finding = 'OIL_SUSPECTED'),
                ),
                const SizedBox(height: 8),
                _FindingOption(
                  label: 'No Oil Found',
                  subtitle: 'Scene inspected; no evidence of oil spill found',
                  color: KairosTheme.success,
                  isSelected: _finding == 'NO_OIL',
                  onTap: () => setState(() => _finding = 'NO_OIL'),
                ),
                const SizedBox(height: 8),
                _FindingOption(
                  label: 'Inconclusive',
                  subtitle: 'Conditions prevented definitive assessment',
                  color: KairosTheme.textSecondary,
                  isSelected: _finding == 'INCONCLUSIVE',
                  onTap: () => setState(() => _finding = 'INCONCLUSIVE'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Submit
          KairosActionButton(
            label: 'SUBMIT INSPECTION REPORT',
            icon: Icons.send_rounded,
            color: KairosTheme.teal,
            onPressed: _inspectionStarted ? _submitInspection : () {},
          ),

          const SizedBox(height: 60),
        ],
      ),
    ));
  }
}

class _StatusBanner extends StatelessWidget {
  final bool hasArrived;
  final bool inspectionStarted;

  const _StatusBanner({required this.hasArrived, required this.inspectionStarted});

  @override
  Widget build(BuildContext context) {
    final color = inspectionStarted ? KairosTheme.oceanBlue : KairosTheme.textMuted;
    final message = inspectionStarted
        ? 'INSPECTION IN PROGRESS'
        : 'PENDING ARRIVAL AT SCENE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectionStep extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool enabled;
  final Widget child;

  const _InspectionStep({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.enabled = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: KairosTheme.surfaceWhite.withOpacity(0.95),
          borderRadius: BorderRadius.circular(KairosTheme.radius12),
          border: Border.all(
            color: isCompleted ? KairosTheme.success : KairosTheme.borderGrey,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: KairosTheme.textPrimary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? KairosTheme.success
                          : KairosTheme.oceanBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: KairosTheme.surfaceWhite, size: 16)
                          : Text(
                              stepNumber.toString(),
                              style: GoogleFonts.inter(
                                color: KairosTheme.surfaceWhite,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: KairosTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: KairosTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: KairosTheme.borderGrey, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: IgnorePointer(ignoring: !enabled, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final LocationData location;

  const _LocationCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KairosTheme.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KairosTheme.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: KairosTheme.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (location.accuracy != null)
                  Text(
                    '±${location.accuracy!.toStringAsFixed(0)}m accuracy',
                    style: const TextStyle(
                      fontSize: 10,
                      color: KairosTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: KairosTheme.success, size: 18),
        ],
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;

  const _FormLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: KairosTheme.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: KairosTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: KairosTheme.oceanBlue,
          ),
        ],
      ),
    );
  }
}

class _FindingOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FindingOption({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : KairosTheme.surfaceGrey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : KairosTheme.borderGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : KairosTheme.textMuted,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isSelected ? color : KairosTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: KairosTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
