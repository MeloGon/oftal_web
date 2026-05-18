class AuditLogModel {
  const AuditLogModel({
    required this.id,
    required this.action,
    required this.entity,
    required this.entityId,
    required this.userEmail,
    required this.detail,
    required this.createdAt,
  });

  final String id;
  final String action;
  final String entity;
  final String entityId;
  final String userEmail;
  final Map<String, dynamic> detail;
  final DateTime createdAt;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String,
      action: json['action'] as String,
      entity: json['entity'] as String,
      entityId: json['entity_id'] as String,
      userEmail: json['user_email'] as String,
      detail: Map<String, dynamic>.from(json['detail'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  String get oldValue => (detail['old_value'] ?? detail['old'])?.toString() ?? '—';
  String get newValue => (detail['new_value'] ?? detail['new'])?.toString() ?? '—';

  String get actionLabel => switch (action) {
        'change_date' => 'Cambió fecha',
        'delete_sale' => 'Eliminó venta',
        'register_payment' => 'Registró abono',
        'finalize_sale' => 'Finalizó venta',
        _ => action,
      };
}
