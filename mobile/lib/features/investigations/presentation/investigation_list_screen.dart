import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../investigations/data/investigation_repository.dart';
import '../../../app/theme/kairos_theme.dart';

class InvestigationListScreen extends ConsumerWidget {
  const InvestigationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investigations = ref.watch(investigationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Investigations'),
        backgroundColor: KairosTheme.navyBlue,
        foregroundColor: Colors.white,
      ),
      body: investigations.when(
        data: (list) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) => const SizedBox(), // reuse HomeScreen card
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
