import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/settings/viewmodels/audit_logs_provider.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/models/audit_log_model.dart';
import 'package:oftal_web/shared/services/authorization_service.dart';
import 'package:oftal_web/shared/widgets/authorization_dialog.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:timeago/timeago.dart' as timeago;

class AuditLogCard extends ConsumerWidget {
  const AuditLogCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(recentAuditLogsProvider);

    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // ─── Header ──────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.orangeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Actividad reciente',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.zinc900,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _onVerTodo(context, ref),
                child: const Text(
                  'Ver todo →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          // ─── Logs ────────────────────────────────────────
          logsAsync.when(
            loading:
                () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            error: (_, __) => const _EmptyLogs(),
            data:
                (logs) =>
                    logs.isEmpty
                        ? const _EmptyLogs()
                        : Column(
                          spacing: 0,
                          children:
                              logs.map((log) => _LogRow(log: log)).toList(),
                        ),
          ),
        ],
      ),
    );
  }

  Future<void> _onVerTodo(BuildContext context, WidgetRef ref) async {
    final authorized = await showAuthorizationDialog(
      context: context,
      requiredRole: AuthorizationRole.admin,
      actionName: 'ver el registro de auditoría',
    );
    if (authorized && context.mounted) {
      ref.read(appRouterProvider).go(RouterName.auditLogs);
    }
  }
}

// ─── Log row ─────────────────────────────────────────────────────────────────

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log});
  final AuditLogModel log;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_calendar_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      log.userEmail,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${log.actionLabel} · Folio ${log.entityId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.zinc500,
                      ),
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        _DateChip(log.oldValue),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 11,
                          color: AppColors.zinc500,
                        ),
                        _DateChip(log.newValue, isNew: true),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                timeago.format(log.createdAt, locale: 'es'),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.zinc400,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip(this.date, {this.isNew = false});
  final String date;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isNew ? AppColors.successBg : AppColors.zinc100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        date,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isNew ? AppColors.successDark : AppColors.zinc600,
        ),
      ),
    );
  }
}

class _EmptyLogs extends StatelessWidget {
  const _EmptyLogs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'Sin actividad reciente',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
      ),
    );
  }
}
