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

  String get oldValue =>
      (detail['old_value'] ?? detail['old'])?.toString() ?? '—';
  String get newValue =>
      (detail['new_value'] ?? detail['new'])?.toString() ?? '—';

  String get actionLabel => switch (action) {
    'change_date' => 'Cambió fecha',
    'create_sale' => 'Creó venta',
    'delete_sale' => 'Eliminó venta',
    'register_payment' => 'Registró abono',
    'finalize_sale' => 'Finalizó venta',

    'create_mount' => 'Creó montura',
    'update_mount' => 'Editó montura',
    'delete_mount' => 'Eliminó montura',
    _ => action,
  };

  /// True when the action represents a before→after value change
  /// (renders old/new chips). Other actions render a plain summary.
  bool get isValueChange => action == 'change_date';

  /// Human summary for non value-change actions (mounts, etc.).
  String get summary {
    final brand = detail['brand']?.toString() ?? '';
    final model = detail['model']?.toString() ?? '';
    final label = '$brand $model'.trim();
    return label.isEmpty ? 'ID $entityId' : label;
  }

  // ─── Mount detail rendering ────────────────────────────────────────────────

  static const Map<String, String> _mountFieldLabels = {
    'brand': 'Marca',
    'model': 'Modelo',
    'color': 'Color',
    'price': 'Precio',
    'stock': 'Stock',
    'opticName': 'Óptica',
  };

  /// Flat field list for create/delete mount (what was added / removed).
  List<({String label, String value})> get mountFields {
    // update stores new values under 'new'; create/delete keep them flat.
    final src =
        action == 'update_mount'
            ? (detail['new'] as Map?)?.cast<String, dynamic>() ?? detail
            : detail;
    return _mountFieldLabels.entries
        .where((e) => src[e.key] != null)
        .map((e) => (label: e.value, value: '${src[e.key]}'))
        .toList();
  }

  /// Field chips for sale / payment actions (what was recorded).
  List<({String label, String value})> get infoChips {
    Map<String, String> labels;
    switch (action) {
      case 'create_sale':
      case 'delete_sale':
        labels = const {
          'paciente': 'Paciente',
          'total': 'Total',
          'sucursal': 'Sucursal',
          'a_cuenta': 'A cuenta',
          'resta': 'Resta',
        };
        break;
      case 'register_payment':
        labels = const {
          'monto': 'Monto',
          'metodo_pago': 'Método',
          'fecha_pago': 'Fecha',
        };
        break;
      default:
        return const [];
    }
    return labels.entries
        .where((e) => detail[e.key] != null)
        .map((e) => (label: e.value, value: '${detail[e.key]}'))
        .toList();
  }

  /// Per-field before→after diff for update_mount (only changed fields).
  List<({String label, String oldValue, String newValue})> get mountChanges {
    final oldM = (detail['old'] as Map?)?.cast<String, dynamic>() ?? const {};
    final newM = (detail['new'] as Map?)?.cast<String, dynamic>() ?? const {};
    final out = <({String label, String oldValue, String newValue})>[];
    for (final e in _mountFieldLabels.entries) {
      final o = '${oldM[e.key] ?? ''}';
      final n = '${newM[e.key] ?? ''}';
      if (o != n) {
        out.add((label: e.value, oldValue: o, newValue: n));
      }
    }
    return out;
  }
}
