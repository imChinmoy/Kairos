import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../core/network/connectivity_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../investigations/data/investigation_repository.dart';
import 'widgets/kairos_header.dart';
import 'widgets/quick_action_card.dart';
import '../../../shared/widgets/connection_status_pill.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/investigation_card.dart';
import '../../../shared/widgets/offline_state_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final investigations = ref.watch(investigationsProvider);
    final connectivity = ref.watch(connectivityProvider);
    final isOnline = connectivity.valueOrNull ?? true;

    KairosConnectionState connState = isOnline ? KairosConnectionState.secure : KairosConnectionState.offline;
    // Assuming error state could be handled here if needed.

    return Scaffold(
      backgroundColor: KairosTheme.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: KairosHeader(
                greeting: user?.greeting ?? 'Good Morning,',
                officerName: '${user?.role == 'SUPERVISOR' ? 'Cmdr.' : 'Officer'} ${user?.firstName ?? ''}',
                connectionState: connState,
                onProfileTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KairosTheme.radius16)),
                      title: Text('Logout',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: KairosTheme.primaryNavy)),
                      content: Text(
                          'Are you sure you want to securely disconnect and logout?',
                          style: GoogleFonts.inter()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('LOGOUT',
                              style: TextStyle(color: KairosTheme.error)),
                        ),
                      ],
                    ),
                  );
                  if (shouldLogout == true) {
                    ref.read(authProvider.notifier).logout();
                  }
                },
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: KairosTheme.spacing24, vertical: KairosTheme.spacing12),
                child: Row(
                  children: [
                    QuickActionCard(
                      icon: Icons.emergency_share_rounded,
                      label: 'SOS',
                      subtext: 'Emergency',
                      color: KairosTheme.sosRed,
                      onTap: () => context.go('/sos'),
                    ),
                    const SizedBox(width: KairosTheme.spacing12),
                    QuickActionCard(
                      icon: Icons.menu_book_rounded,
                      label: 'Resources',
                      subtext: 'Field resources',
                      color: KairosTheme.secondaryBlue,
                      onTap: () {},
                    ),
                    const SizedBox(width: KairosTheme.spacing12),
                    QuickActionCard(
                      icon: Icons.gavel_rounded,
                      label: 'Guidelines',
                      subtext: 'Protocols',
                      color: KairosTheme.teal,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Active Investigations Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(KairosTheme.spacing24, KairosTheme.spacing24, KairosTheme.spacing24, KairosTheme.spacing16),
                child: SectionHeader(
                  title: 'Active Investigations',
                  actionText: 'View All',
                  onActionTap: () => context.go('/investigations'),
                ),
              ),
            ),

            // Investigation List or States
            investigations.when(
              data: (list) {
                if (!isOnline && list.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: KairosTheme.spacing24),
                      child: OfflineStateCard(
                        hasCachedData: false,
                        onRetry: () => ref.refresh(investigationsProvider),
                      ),
                    ),
                  );
                } else if (!isOnline && list.isNotEmpty) {
                  // Offline with cached data
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: KairosTheme.spacing24),
                        child: OfflineStateCard(
                          hasCachedData: true,
                          lastSyncTime: DateTime.now().subtract(const Duration(minutes: 42)), // Dummy last sync
                          onRetry: () => ref.refresh(investigationsProvider),
                        ),
                      ),
                      const SizedBox(height: KairosTheme.spacing16),
                      ...list.map((item) => Padding(
                            padding: const EdgeInsets.fromLTRB(KairosTheme.spacing24, 0, KairosTheme.spacing24, KairosTheme.spacing16),
                            child: InvestigationCard(
                              item: item,
                              onTap: () => context.push('/investigations/${item.id}'),
                            ),
                          )),
                    ]),
                  );
                }

                if (list.isEmpty) {
                  return const SliverToBoxAdapter(child: _EmptyState());
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.fromLTRB(KairosTheme.spacing24, 0, KairosTheme.spacing24, KairosTheme.spacing16),
                      child: InvestigationCard(
                        item: list[index],
                        onTap: () => context.push(
                          '/investigations/${list[index].id}',
                        ),
                      ),
                    ),
                    childCount: list.length,
                  ),
                );
              },
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const Padding(
                    padding: EdgeInsets.fromLTRB(KairosTheme.spacing24, 0, KairosTheme.spacing24, KairosTheme.spacing16),
                    child: _ShimmerCard(),
                  ),
                  childCount: 3,
                ),
              ),
              error: (err, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: KairosTheme.spacing24),
                  child: OfflineStateCard(
                    onRetry: () => ref.refresh(investigationsProvider),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KairosTheme.spacing32, vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(KairosTheme.spacing24),
            decoration: BoxDecoration(
              color: KairosTheme.cardWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: KairosTheme.textPrimary.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.assignment_turned_in_rounded,
                size: 48, color: KairosTheme.teal.withOpacity(0.5)),
          ),
          const SizedBox(height: KairosTheme.spacing24),
          Text(
            'Zero Active Investigations',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: KairosTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: KairosTheme.spacing8),
          Text(
            'You currently have no field investigations assigned to your unit.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: KairosTheme.textSecondary,
              height: 1.5,
            ),
          ),
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
      height: 130,
      decoration: BoxDecoration(
        color: KairosTheme.borderGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(KairosTheme.radius16),
        border: Border.all(color: KairosTheme.borderGrey),
      ),
    );
  }
}
