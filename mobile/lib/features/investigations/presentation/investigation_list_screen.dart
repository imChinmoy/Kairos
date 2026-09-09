import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../investigations/data/investigation_repository.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../shared/widgets/kairos_app_background.dart';
import '../../../shared/widgets/kairos_app_bar.dart';
import '../../../shared/widgets/investigation_card.dart';

class InvestigationListScreen extends ConsumerWidget {
  const InvestigationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investigations = ref.watch(investigationsProvider);

    return KairosAppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: KairosAppBar(
          title: 'All Investigations',
          imageTitle: null,
          showBackButton: true,
        ),
        body: investigations.when(
          data: (list) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) => InvestigationCard(
              item: list[i],
              onTap: () => context.push('/investigations/${list[i].id}'),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString(), style: TextStyle(color: Colors.white))),
        ),
      ),
    );
  }
}
