import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/shared/widgets/menu_item.dart';

const _kBrand = Color(0xff7A6BF5);
const _kSidebarBg = Color(0xff18181B);
const _kDivider = Color(0xff27272A);

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);

    return Container(
      width: 220,
      height: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
      decoration: BoxDecoration(
        color: _kSidebarBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Logo ────────────────────────────────────────────
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                ref.read(appRouterProvider).go(RouterName.dashboard);
                ref
                    .read(navigationProvider.notifier)
                    .setCurrentPage(RouterName.dashboard);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _kBrand.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.bubble_chart_outlined,
                        color: _kBrand,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'OFTALWEB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(height: 1, color: _kDivider),
          const SizedBox(height: 10),

          // ─── Section label ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
            child: Text(
              'MENÚ',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.28),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
          ),

          // ─── Nav items ───────────────────────────────────────
          MenuItem(
            text: 'Agregar paciente',
            icon: Icons.person_add_outlined,
            onPressed: () =>
                ref.read(appRouterProvider).go(RouterName.addPatient),
            isActive: navigationState.currentPage == RouterName.addPatient,
          ),
          MenuItem(
            text: 'Buscar paciente',
            icon: Icons.manage_search_outlined,
            onPressed: () =>
                ref.read(appRouterProvider).go(RouterName.searchPatient),
            isActive: navigationState.currentPage == RouterName.searchPatient,
          ),
          MenuItem(
            text: 'Vender',
            icon: Icons.point_of_sale_outlined,
            onPressed: () => ref.read(appRouterProvider).go(RouterName.sell),
            isActive: navigationState.currentPage == RouterName.sell,
          ),
          MenuItem(
            text: 'Historial ventas',
            icon: Icons.receipt_long_outlined,
            onPressed: () =>
                ref.read(appRouterProvider).go(RouterName.salesHistory),
            isActive: navigationState.currentPage == RouterName.salesHistory,
          ),
          MenuItem(
            text: 'Egresos',
            icon: Icons.account_balance_wallet_outlined,
            onPressed: () =>
                ref.read(appRouterProvider).go(RouterName.expenses),
            isActive: navigationState.currentPage == RouterName.expenses,
          ),
          if (ref.read(navigationProvider).isAdmin)
            MenuItem(
              text: 'Configuración',
              icon: Icons.tune_outlined,
              onPressed: () =>
                  ref.read(appRouterProvider).go(RouterName.settings),
              isActive: navigationState.currentPage == RouterName.settings,
            ),

          const Spacer(),

          // ─── Logout ──────────────────────────────────────────
          Container(height: 1, color: _kDivider),
          MenuItem(
            text: 'Cerrar sesión',
            icon: Icons.logout_outlined,
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              ref.read(appRouterProvider).go(RouterName.login);
            },
          ).paddingOnly(bottom: 8, top: 4),
        ],
      ),
    );
  }
}
