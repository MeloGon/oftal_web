import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/settings_provider.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/services/authorization_service.dart';
import 'package:oftal_web/shared/widgets/authorization_dialog.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(settingsProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(settingsProvider.notifier).clearErrorMessage(),
        );
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          // ─── Page header ─────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              const Text(
                'Configuración',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff18181B),
                ),
              ),
              Text(
                'Gestiona el inventario y consulta los reportes',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),

          // ─── Feature flags ───────────────────────────────
          const Text(
            'Funcionalidades',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff52525B),
              letterSpacing: 0.3,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final features = _SettingsNavCard(
                title: 'Funcionalidades',
                description: 'Activa o desactiva funcionalidades del sistema',
                icon: Icons.tune_rounded,
                iconColor: const Color(0xff7A6BF5),
                iconBgColor: const Color(0xffEEECFE),
                onTap: () async {
                  final authorized = await showAuthorizationDialog(
                    context: context,
                    requiredRole: AuthorizationRole.admin,
                    actionName: 'acceder a Funcionalidades',
                  );
                  if (authorized) {
                    ref.read(appRouterProvider).go(RouterName.features);
                  }
                },
              );
              if (constraints.maxWidth < 560) return features;
              return Row(
                spacing: 16,
                children: [
                  Expanded(child: features),
                  const Expanded(child: SizedBox()),
                ],
              );
            },
          ),

          // ─── Inventory options ────────────────────────────
          const Text(
            'Inventario',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff52525B),
              letterSpacing: 0.3,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final resinas = _SettingsNavCard(
                title: 'Resinas',
                description: 'Administra el catálogo de resinas y lentes',
                icon: Icons.lens_outlined,
                iconColor: const Color(0xff0EA5E9),
                iconBgColor: const Color(0xffE0F2FE),
                onTap: () async {
                  ref.read(appRouterProvider).go(RouterName.resins);
                },
              );
              final monturas = _SettingsNavCard(
                title: 'Monturas',
                description: 'Administra el inventario de armazones',
                icon: Icons.visibility_outlined,
                iconColor: const Color(0xff7A6BF5),
                iconBgColor: const Color(0xffEEECFE),
                onTap: () async {
                  final authorized = await showAuthorizationDialog(
                    context: context,
                    requiredRole: AuthorizationRole.admin,
                    actionName: 'acceder a Monturas',
                  );
                  if (authorized) {
                    ref.read(appRouterProvider).go(RouterName.mounts);
                  }
                },
              );
              if (constraints.maxWidth < 560) {
                return Column(
                  spacing: 16,
                  children: [resinas, monturas],
                );
              }
              return Row(
                spacing: 16,
                children: [
                  Expanded(child: resinas),
                  Expanded(child: monturas),
                ],
              );
            },
          ),

          // ─── Admin section ────────────────────────────────
          const Text(
            'Administración',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff52525B),
              letterSpacing: 0.3,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final auditLogs = _SettingsNavCard(
                title: 'Registro de auditoría',
                description: 'Historial de cambios realizados por los usuarios',
                icon: Icons.history_rounded,
                iconColor: const Color(0xffEA580C),
                iconBgColor: const Color(0xffFFF7ED),
                onTap: () async {
                  final authorized = await showAuthorizationDialog(
                    context: context,
                    requiredRole: AuthorizationRole.admin,
                    actionName: 'ver el registro de auditoría',
                  );
                  if (authorized) {
                    ref.read(appRouterProvider).go(RouterName.auditLogs);
                  }
                },
              );
              if (constraints.maxWidth < 560) return auditLogs;
              return Row(
                spacing: 16,
                children: [
                  Expanded(child: auditLogs),
                  const Expanded(child: SizedBox()),
                ],
              );
            },
          ),

          // ─── Reports section ──────────────────────────────
          const Text(
            'Reportes',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff52525B),
              letterSpacing: 0.3,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final reporte = _SettingsNavCard(
                title: 'Reporte de ingresos y egresos',
                description:
                    'Consulta ingresos y egresos registrados por período',
                icon: Icons.bar_chart_rounded,
                iconColor: const Color(0xff22C55E),
                iconBgColor: const Color(0xffDCFCE7),
                onTap: () async {
                  final authorized = await showAuthorizationDialog(
                    context: context,
                    requiredRole: AuthorizationRole.admin,
                    actionName: 'ver el reporte de ingresos',
                  );
                  if (authorized) {
                    ref.read(appRouterProvider).go(RouterName.paymentsReport);
                  }
                },
              );
              final ventasPorVendedor = _SettingsNavCard(
                title: 'Ventas por vendedor',
                description:
                    'Consulta las ventas agrupadas por vendedor por mes',
                icon: Icons.people_outline_rounded,
                iconColor: const Color(0xff7A6BF5),
                iconBgColor: const Color(0xffEEECFE),
                onTap: () async {
                  final authorized = await showAuthorizationDialog(
                    context: context,
                    requiredRole: AuthorizationRole.admin,
                    actionName: 'ver ventas por vendedor',
                  );
                  if (authorized) {
                    ref.read(appRouterProvider).go(RouterName.salesBySeller);
                  }
                },
              );
              if (constraints.maxWidth < 560) {
                return Column(
                  spacing: 16,
                  children: [reporte, ventasPorVendedor],
                );
              }
              return Row(
                spacing: 16,
                children: [
                  Expanded(child: reporte),
                  Expanded(child: ventasPorVendedor),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsNavCard extends StatefulWidget {
  const _SettingsNavCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Future<void> Function() onTap;

  @override
  State<_SettingsNavCard> createState() => _SettingsNavCardState();
}

class _SettingsNavCardState extends State<_SettingsNavCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _hovered
                      ? widget.iconColor.withValues(alpha: 0.4)
                      : const Color(0xffE4E4E7),
              width: 1.5,
            ),
            boxShadow:
                _hovered
                    ? [
                      BoxShadow(
                        color: widget.iconColor.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 20, color: widget.iconColor),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff18181B),
                    ),
                  ),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff71717A),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Ir al módulo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: widget.iconColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: widget.iconColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showSnackbar(
  BuildContext context,
  SnackbarConfigModel? snackbarConfig,
  String errorMessage,
) {
  CustomSnackbar().show(
    context,
    snackbarConfig ??
        SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
    errorMessage,
  );
}
