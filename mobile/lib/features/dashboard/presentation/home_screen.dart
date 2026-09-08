import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../core/network/connectivity_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../investigations/data/investigation_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final investigations = ref.watch(investigationsProvider);
    final connectivity = ref.watch(connectivityProvider);
    final isOnline = connectivity.valueOrNull ?? true;

    return Scaffold(
      backgroundColor: KairosTheme.offWhite,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [KairosTheme.deepNavy, KairosTheme.navyBlue],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.satellite_alt_rounded,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'KAIROS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                          const Spacer(),
                          // Online/offline indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? KairosTheme.success.withOpacity(0.2)
                                  : KairosTheme.warning.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isOnline
                                    ? KairosTheme.success.withOpacity(0.5)
                                    : KairosTheme.warning.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isOnline
                                        ? KairosTheme.success
                                        : KairosTheme.warning,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isOnline ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    color: isOnline
                                        ? KairosTheme.success
                                        : KairosTheme.warning,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => ref.read(authProvider.notifier).logout(),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_outline,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Greeting
                      Text(
                        '${user?.greeting ?? 'Good Morning'},',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Officer ${user?.firstName ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stay vigilant. Seas are safer with you.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Summary cards
                      investigations.when(
                        data: (list) {
                          final assigned = list
                              .where((i) => i.assignmentStatus == 'ASSIGNED')
                              .length;
                          final inProgress = list
                              .where((i) => i.assignmentStatus == 'IN_PROGRESS')
                              .length;
                          final completed = list
                              .where((i) => i.assignmentStatus == 'COMPLETED')
                              .length;
                          return _SummaryRow(
                            assigned: assigned,
                            inProgress: inProgress,
                            completed: completed,
                          );
                        },
                        loading: () => const _SummaryRow(
                            assigned: 0, inProgress: 0, completed: 0),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                children: [
                  _QuickActionButton(
                    icon: Icons.phone,
                    label: 'SOS',
                    color: KairosTheme.sosRed,
                    onTap: () => context.go('/sos'),
                  ),
                  const SizedBox(width: 12),
                  _QuickActionButton(
                    icon: Icons.menu_book_outlined,
                    label: 'Resources',
                    color: KairosTheme.oceanBlue,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _QuickActionButton(
                    icon: Icons.gavel_outlined,
                    label: 'Guidelines',
                    color: KairosTheme.teal,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // My Investigations header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'My Investigations',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: KairosTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/investigations'),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),

          // Investigation list
          investigations.when(
            data: (list) {
              if (list.isEmpty) {
                return const SliverToBoxAdapter(child: _EmptyState());
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _InvestigationCard(
                      item: list[index],
                      onTap: () => context.push(
                        '/investigations/${list[index].id}',
                      ),
                    ),
                  ),
                  childCount: list.take(5).length,
                ),
              );
            },
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _ShimmerCard(),
                ),
                childCount: 3,
              ),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _ErrorCard(
                  message: err.toString(),
                  onRetry: () => ref.refresh(investigationsProvider),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int assigned;
  final int inProgress;
  final int completed;

  const _SummaryRow({
    required this.assigned,
    required this.inProgress,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryItem(
          count: assigned,
          label: 'Active',
          color: KairosTheme.warning,
        ),
        const SizedBox(width: 12),
        _SummaryItem(
          count: inProgress,
          label: 'In Progress',
          color: KairosTheme.info,
        ),
        const SizedBox(width: 12),
        _SummaryItem(
          count: completed,
          label: 'Completed',
          color: KairosTheme.success,
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: KairosTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KairosTheme.borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvestigationCard extends StatelessWidget {
  final InvestigationListItem item;
  final VoidCallback onTap;

  const _InvestigationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priorityColor = KairosTheme.priorityColor(item.priority);
    final dateStr = item.assignedAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(item.assignedAt!)
        : 'Date unknown';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KairosTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KairosTheme.borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Priority indicator bar
            Container(
              width: 4,
              height: 52,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: priorityColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.priority} Priority',
                              style: TextStyle(
                                color: priorityColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'INV-${item.id.substring(item.id.length > 6 ? item.id.length - 6 : 0).toUpperCase()}',
                        style: const TextStyle(
                          color: KairosTheme.textMuted,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getTitle(item),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KairosTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: KairosTheme.textMuted),
                      const SizedBox(width: 2),
                      Text(
                        _getRegion(item.id),
                        style: const TextStyle(
                          fontSize: 11,
                          color: KairosTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time,
                          size: 12, color: KairosTheme.textMuted),
                      const SizedBox(width: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: KairosTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: KairosTheme.oceanBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: KairosTheme.oceanBlue),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(InvestigationListItem item) {
    if (item.priority == 'CRITICAL') return 'Critical Oil Spill Alert';
    if (item.priority == 'HIGH') return 'Suspected Oil Spill';
    return 'Possible Debris / Slick';
  }

  String _getRegion(String id) {
    // In production, this would come from investigation data
    const regions = ['Arabian Sea', 'Bay of Bengal', 'Lakshadweep', 'Andaman', 'Gujarat Coast'];
    return regions[id.hashCode.abs() % regions.length];
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined,
              size: 56, color: KairosTheme.textMuted.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text(
            'No investigations assigned',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: KairosTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'You will see new assignments here when they are dispatched.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: KairosTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KairosTheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KairosTheme.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: KairosTheme.error),
          const SizedBox(height: 8),
          const Text('Could not load investigations',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: KairosTheme.borderGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
