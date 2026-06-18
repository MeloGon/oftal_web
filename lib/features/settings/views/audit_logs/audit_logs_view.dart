import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/settings/viewmodels/audit_logs_provider.dart';
import 'package:oftal_web/shared/models/audit_log_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:timeago/timeago.dart' as timeago;

class AuditLogsView extends ConsumerWidget {
  const AuditLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(auditLogsProvider);
    final notifier = ref.read(auditLogsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // ─── Header ──────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    const Text(
                      'Registro de auditoría',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc900,
                      ),
                    ),
                    Text(
                      'Historial de cambios realizados en el sistema',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed: notifier.clearFilters,
                child: const Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt_off_outlined, size: 14),
                    Text('Limpiar filtros'),
                  ],
                ),
              ),
            ],
          ),

          // ─── Filters ─────────────────────────────────────
          ShadCard(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: ShadSelect<String>(
                    placeholder: const Text('Filtrar por acción'),
                    onChanged: (v) => notifier.setActionFilter(v),
                    options: const [
                      ShadOption(
                        value: 'create_sale',
                        child: Text('Creó venta'),
                      ),
                      ShadOption(
                        value: 'delete_sale',
                        child: Text('Eliminó venta'),
                      ),
                      ShadOption(
                        value: 'register_payment',
                        child: Text('Registró abono'),
                      ),
                      ShadOption(
                        value: 'change_date',
                        child: Text('Cambio de fecha'),
                      ),
                      ShadOption(
                        value: 'create_mount',
                        child: Text('Creó montura'),
                      ),
                      ShadOption(
                        value: 'update_mount',
                        child: Text('Editó montura'),
                      ),
                      ShadOption(
                        value: 'delete_mount',
                        child: Text('Eliminó montura'),
                      ),
                    ],
                    selectedOptionBuilder: (ctx, v) =>
                        Text(_actionFilterLabel(v)),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: ShadInput(
                    placeholder: const Text('Filtrar por usuario'),
                    leading: const Icon(Icons.person_outline, size: 14),
                    onChanged: notifier.setUserFilter,
                  ),
                ),
              ],
            ),
          ),

          // ─── Table ───────────────────────────────────────
          Expanded(
            child: ShadCard(
              padding: EdgeInsets.zero,
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.logs.isEmpty
                  ? _EmptyState()
                  : _LogsTable(logs: state.logs),
            ),
          ),

          // ─── Pagination ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Página ${state.pageNumber}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                enabled: state.offset > 0 && !state.isLoading,
                onPressed: notifier.prevPage,
                child: const Icon(Icons.chevron_left, size: 16),
              ),
              const SizedBox(width: 6),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                enabled: state.hasMore && !state.isLoading,
                onPressed: notifier.nextPage,
                child: const Icon(Icons.chevron_right, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _actionFilterLabel(String v) => switch (v) {
      'create_sale' => 'Creó venta',
      'delete_sale' => 'Eliminó venta',
      'register_payment' => 'Registró abono',
      'change_date' => 'Cambio de fecha',
      'create_mount' => 'Creó montura',
      'update_mount' => 'Editó montura',
      'delete_mount' => 'Eliminó montura',
      _ => v,
    };

IconData _actionIcon(String action) => switch (action) {
      'create_sale' => Icons.point_of_sale_outlined,
      'delete_sale' => Icons.remove_shopping_cart_outlined,
      'register_payment' => Icons.payments_outlined,
      'change_date' => Icons.edit_calendar_outlined,
      'create_mount' => Icons.add_box_outlined,
      'update_mount' => Icons.edit_outlined,
      'delete_mount' => Icons.delete_outline,
      _ => Icons.history_rounded,
    };

// ─── Table ────────────────────────────────────────────────────────────────────

class _LogsTable extends StatelessWidget {
  const _LogsTable({required this.logs});
  final List<AuditLogModel> logs;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: logs.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) => _LogTile(log: logs[i]),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});
  final AuditLogModel log;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        spacing: 14,
        children: [
          // ─ Ícono ───────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _actionIcon(log.action),
              size: 16,
              color: AppColors.primary,
            ),
          ),

          // ─ Info ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Text(
                      log.userEmail,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc900,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.actionLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  switch (log.entity) {
                    'mount' => log.summary,
                    'payment' => 'Remisión ${log.entityId}',
                    _ => 'Folio ${log.entityId}',
                  },
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.zinc500,
                  ),
                ),
                if (log.isValueChange)
                  Row(
                    spacing: 6,
                    children: [
                      _Chip(log.oldValue, isNew: false),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: AppColors.zinc500,
                      ),
                      _Chip(log.newValue, isNew: true),
                    ],
                  ),

                // Update mount → per-field before→after diff
                if (log.action == 'update_mount')
                  ...log.mountChanges.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        spacing: 6,
                        children: [
                          Text(
                            '${c.label}:',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.zinc600,
                            ),
                          ),
                          _Chip(c.oldValue.isEmpty ? '—' : c.oldValue,
                              isNew: false),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
                            color: AppColors.zinc500,
                          ),
                          _Chip(c.newValue.isEmpty ? '—' : c.newValue,
                              isNew: true),
                        ],
                      ),
                    ),
                  ),

                // Create / delete mount → full field list (what was added/removed)
                if (log.action == 'create_mount' ||
                    log.action == 'delete_mount')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: log.mountFields
                          .map((f) => _FieldChip(label: f.label, value: f.value))
                          .toList(),
                    ),
                  ),

                // Sale / payment → recorded field chips
                if (log.infoChips.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: log.infoChips
                          .map((f) => _FieldChip(label: f.label, value: f.value))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),

          // ─ Fecha ───────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              Text(
                timeago.format(log.createdAt, locale: 'es'),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.zinc400,
                ),
              ),
              Text(
                _formatDate(log.createdAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.zinc300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text, {required this.isNew});
  final String text;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNew ? AppColors.successBg : AppColors.zinc100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isNew ? AppColors.successDark : AppColors.zinc600,
        ),
      ),
    );
  }
}

class _FieldChip extends StatelessWidget {
  const _FieldChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.zinc500,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.zinc700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(Icons.history_rounded, size: 36, color: Colors.grey.shade300),
          Text(
            'Sin registros de auditoría',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
