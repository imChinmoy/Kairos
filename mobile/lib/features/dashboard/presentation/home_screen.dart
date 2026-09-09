import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../core/network/connectivity_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../investigations/data/investigation_repository.dart';
import '../../../shared/widgets/kairos_app_bar.dart';
import '../../../shared/widgets/kairos_offline_banner.dart';
import '../../../shared/widgets/kairos_action_button.dart';
import '../../../shared/widgets/connection_status_pill.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/investigation_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final investigations = ref.watch(investigationsProvider);
    final connectivity = ref.watch(connectivityProvider);
    final isOnline = connectivity.valueOrNull ?? true;

    KairosConnectionState connState = isOnline ? KairosConnectionState.secure : KairosConnectionState.offline;

    final officerTitle = '${user?.role == 'SUPERVISOR' ? 'Cmdr.' : 'Officer'} ${user?.firstName ?? ''}';

    return Column(
      children: [
        KairosAppBar(
          title: 'KAIROS',
          imageTitle: 'assets/images/appbar_image.png',
          showBackButton: false,
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: KairosTheme.surfaceWhite.withOpacity(0.3)),
              ),
              child: IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none_rounded, size: 22, color: KairosTheme.surfaceWhite),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: KairosTheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {},
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: KairosTheme.surfaceWhite.withOpacity(0.3)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  popupMenuTheme: PopupMenuThemeData(
                    color: KairosTheme.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KairosTheme.radius12),
                    ),
                  ),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.person_outline_rounded, size: 22, color: KairosTheme.surfaceWhite),
                  offset: const Offset(0, 48),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (value) async {
                    if (value == 'logout') {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KairosTheme.radius12)),
                          title: Text('Logout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                          content: Text('Securely disconnect and logout?', style: GoogleFonts.inter()),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('LOGOUT', style: TextStyle(color: KairosTheme.error))),
                          ],
                        ),
                      );
                      if (shouldLogout == true) {
                        ref.read(authProvider.notifier).logout();
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout_rounded, size: 18, color: KairosTheme.error),
                          const SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: GoogleFonts.inter(
                              color: KairosTheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        KairosOfflineBanner(isOnline: isOnline),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.refresh(investigationsProvider),
            color: KairosTheme.oceanBlue,
            child: CustomScrollView(
              slivers: [
                // Greeting and Status
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(KairosTheme.spacing24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.greeting ?? 'Good Morning,',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: KairosTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: KairosTheme.spacing4),
                            Text(
                              officerTitle.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: KairosTheme.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: KairosTheme.spacing4),
                            Text(
                              'FIELD OPERATIONS',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: KairosTheme.oceanBlue,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        ConnectionStatusPill(state: connState),
                      ],
                    ),
                  ),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: KairosTheme.spacing24),
                    child: Row(
                      children: [
                        Expanded(
                          child: KairosActionButton(
                            label: 'SOS',
                            icon: Icons.emergency_share_rounded,
                            color: KairosTheme.sosRed,
                            onPressed: () => context.go('/sos'),
                          ),
                        ),
                        const SizedBox(width: KairosTheme.spacing12),
                        Expanded(
                          child: KairosActionButton(
                            label: 'TOOLS',
                            icon: Icons.build_rounded,
                            isOutline: true,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: KairosTheme.spacing12),
                        Expanded(
                          child: KairosActionButton(
                            label: 'MANUAL',
                            icon: Icons.gavel_rounded,
                            isOutline: true,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Investigations Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(KairosTheme.spacing24, KairosTheme.spacing32, KairosTheme.spacing24, KairosTheme.spacing16),
                    child: SectionHeader(
                      title: 'ACTIVE INVESTIGATIONS',
                      actionText: 'VIEW ALL',
                      onActionTap: () => context.push('/investigations'),
                    ),
                  ),
                ),

                // Investigations List
                investigations.when(
                  data: (list) {
                    if (list.isEmpty) return const SliverToBoxAdapter(child: _EmptyState());
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.fromLTRB(KairosTheme.spacing24, 0, KairosTheme.spacing24, KairosTheme.spacing16),
                          child: InvestigationCard(
                            item: list[index],
                            onTap: () => context.push('/investigations/${list[index].id}'),
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
                  error: (err, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        ),
      ],
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
              color: KairosTheme.surfaceWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: KairosTheme.textPrimary.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.assignment_turned_in_rounded, size: 48, color: KairosTheme.teal.withOpacity(0.5)),
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
        borderRadius: BorderRadius.circular(KairosTheme.radius12),
        border: Border.all(color: KairosTheme.borderGrey),
      ),
    );
  }
}
