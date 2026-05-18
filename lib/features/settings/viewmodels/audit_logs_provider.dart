import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/shared/models/audit_log_model.dart';

// ─── Recent (dashboard) ───────────────────────────────────────────────────────

final recentAuditLogsProvider =
    FutureProvider.autoDispose<List<AuditLogModel>>((ref) async {
  final result =
      await ref.read(auditLogRepositoryProvider).getRecent(limit: 5);
  return result.getOrElse((_) => []);
});

// ─── Full list (audit logs view) ─────────────────────────────────────────────

class AuditLogsNotifier extends Notifier<AuditLogsState> {
  @override
  AuditLogsState build() {
    load();
    return const AuditLogsState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(auditLogRepositoryProvider).getAll(
          action: state.filterAction,
          userEmail: state.filterUser.isEmpty ? null : state.filterUser,
          from: state.filterFrom,
          to: state.filterTo,
        );
    result.fold(
      (_) => state = state.copyWith(isLoading: false),
      (logs) => state = state.copyWith(logs: logs, isLoading: false),
    );
  }

  void setActionFilter(String? action) {
    state = state.copyWith(filterAction: action);
    load();
  }

  void setUserFilter(String user) {
    state = state.copyWith(filterUser: user);
    load();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(filterFrom: from, filterTo: to);
    load();
  }

  void clearFilters() {
    state = const AuditLogsState();
    load();
  }
}

final auditLogsProvider =
    NotifierProvider<AuditLogsNotifier, AuditLogsState>(
  AuditLogsNotifier.new,
);

// ─── State ───────────────────────────────────────────────────────────────────

class AuditLogsState {
  const AuditLogsState({
    this.logs = const [],
    this.isLoading = false,
    this.filterAction,
    this.filterUser = '',
    this.filterFrom,
    this.filterTo,
  });

  final List<AuditLogModel> logs;
  final bool isLoading;
  final String? filterAction;
  final String filterUser;
  final DateTime? filterFrom;
  final DateTime? filterTo;

  AuditLogsState copyWith({
    List<AuditLogModel>? logs,
    bool? isLoading,
    String? filterAction,
    String? filterUser,
    DateTime? filterFrom,
    DateTime? filterTo,
  }) {
    return AuditLogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      filterAction: filterAction,
      filterUser: filterUser ?? this.filterUser,
      filterFrom: filterFrom ?? this.filterFrom,
      filterTo: filterTo ?? this.filterTo,
    );
  }
}
