import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                        color: Color(0xff18181B),
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
                      ShadOption(value: 'change_date', child: Text('Cambio de fecha')),
                    ],
                    selectedOptionBuilder: (ctx, v) => Text(
                      v == 'change_date' ? 'Cambio de fecha' : v,
                    ),
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
        ],
      ),
    );
  }
}

// ─── Table ────────────────────────────────────────────────────────────────────

class _LogsTable extends StatelessWidget {
  const _LogsTable({required this.logs});
  final List<AuditLogModel> logs;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
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
              color: const Color(0xffEEECFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_calendar_outlined,
              size: 16,
              color: Color(0xff7A6BF5),
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
                        color: Color(0xff18181B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffEEECFE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.actionLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff7A6BF5),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Folio ${log.entityId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff71717A),
                  ),
                ),
                Row(
                  spacing: 6,
                  children: [
                    _Chip(log.oldValue, isNew: false),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: Color(0xff71717A),
                    ),
                    _Chip(log.newValue, isNew: true),
                  ],
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
                  color: Color(0xffA1A1AA),
                ),
              ),
              Text(
                _formatDate(log.createdAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xffD4D4D8),
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
        color: isNew ? const Color(0xffDCFCE7) : const Color(0xffF4F4F5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isNew ? const Color(0xff16A34A) : const Color(0xff52525B),
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
