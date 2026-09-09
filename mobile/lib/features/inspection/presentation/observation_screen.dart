import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../shared/widgets/kairos_loader.dart';
import '../data/inspection_repository.dart';

class ObservationScreen extends ConsumerStatefulWidget {
  final String inspectionId;

  const ObservationScreen({super.key, required this.inspectionId});

  @override
  ConsumerState<ObservationScreen> createState() => _ObservationScreenState();
}

class _ObservationScreenState extends ConsumerState<ObservationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'VISIBLE_OIL';
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  final _types = [
    {'value': 'VISIBLE_OIL', 'label': 'Visible Oil'},
    {'value': 'WATER_CONDITION', 'label': 'Water Condition'},
    {'value': 'WEATHER', 'label': 'Weather'},
    {'value': 'WIND', 'label': 'Wind'},
    {'value': 'CURRENT', 'label': 'Current'},
    {'value': 'SEA_STATE', 'label': 'Sea State'},
    {'value': 'VESSEL_SIGHTING', 'label': 'Vessel Sighting'},
    {'value': 'SHORELINE_CONTAMINATION', 'label': 'Shoreline Contamination'},
    {'value': 'ODOR', 'label': 'Odor'},
    {'value': 'DEBRIS', 'label': 'Debris'},
    {'value': 'OTHER', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      await ref.read(inspectionRepositoryProvider).createObservation(
        widget.inspectionId,
        {
          'type': _type,
          'value': _valueController.text,
          'notes': _notesController.text,
        },
      );
    } catch (e) {
      // Handled by offline queue
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Observation logged successfully'),
          ],
        ),
        backgroundColor: KairosTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    _valueController.clear();
    _notesController.clear();
    setState(() => _type = 'VISIBLE_OIL');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KairosTheme.offWhite,
      appBar: AppBar(
        title: const Text('Log Observation'),
        backgroundColor: KairosTheme.navyBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Help text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KairosTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: KairosTheme.info.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: KairosTheme.info, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All observations are timestamped and GPS-tagged automatically. '
                      'Be precise and factual in your descriptions.',
                      style: TextStyle(fontSize: 12, color: KairosTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Type selection
            const Text(
              'Observation Type',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((t) => ChoiceChip(
                label: Text(t['label']!),
                selected: _type == t['value'],
                onSelected: (_) => setState(() => _type = t['value']!),
                selectedColor: KairosTheme.oceanBlue,
                labelStyle: TextStyle(
                  color: _type == t['value']! ? Colors.white : KairosTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),

            // Value field
            const Text(
              'Observation Description *',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _valueController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: _getHintText(_type),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes field
            const Text(
              'Additional Notes',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Any additional context or remarks...',
              ),
            ),
            const SizedBox(height: 24),

            // Timestamp notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KairosTheme.surfaceGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: KairosTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Will be timestamped: ${DateTime.now().toLocal().toString().substring(0, 19)}',
                    style: const TextStyle(fontSize: 12, color: KairosTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: KairosLoader(size: 18),
                    )
                  : const Icon(Icons.add_task, size: 20),
              label: Text(_isSubmitting ? 'Logging...' : 'LOG OBSERVATION'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KairosTheme.teal,
                minimumSize: const Size(double.infinity, 54),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  String _getHintText(String type) {
    switch (type) {
      case 'VISIBLE_OIL':
        return 'e.g. Dark brownish slick, approx. 200m², strong hydrocarbon odor';
      case 'WIND':
        return 'e.g. 15 km/h from NE. Gusty with occasional stronger bursts.';
      case 'VESSEL_SIGHTING':
        return 'e.g. Oil tanker approx. 2.5 NM SE, MMSI 123456789, heading 135°';
      case 'SEA_STATE':
        return 'e.g. Moderate, wave height 1.2m, swell from SW';
      case 'CURRENT':
        return 'e.g. 0.5 kn southward current observed';
      default:
        return 'Describe your observation clearly and factually...';
    }
  }
}
