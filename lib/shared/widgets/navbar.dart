import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/providers/providers.dart';

class Navbar extends ConsumerWidget {
  const Navbar({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authProvider);
    final navigationState = ref.watch(navigationProvider);
    final pageTitle = _pageTitle(navigationState.currentPage);

    return Container(
      width: double.infinity,
      height: 52,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (size.width <= 700)
            IconButton(
              icon: const Icon(Icons.menu_outlined, size: 20),
              onPressed: onMenuTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          if (size.width <= 700) const SizedBox(width: 8),

          // Page title
          Text(
            pageTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.zinc900,
            ),
          ),

          const Spacer(),

          // User chip
          if (authState.profile != null)
            Builder(
              builder: (context) {
                final name = authState.profile!.name ?? '';
                final initial =
                    name.isNotEmpty ? name[0].toUpperCase() : '?';
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.zinc100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.zinc200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (size.width > 390 && name.isNotEmpty)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.zinc700,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  String _pageTitle(String? page) => switch (page) {
    RouterName.addPatient => 'Agregar Paciente',
    RouterName.searchPatient => 'Buscar Paciente',
    RouterName.sell => 'Nueva Venta',
    RouterName.salesHistory => 'Historial de Ventas',
    RouterName.settings => 'Configuración',
    RouterName.resins => 'Inventario · Resinas',
    RouterName.mounts => 'Inventario · Monturas',
    _ => 'Dashboard',
  };
}
