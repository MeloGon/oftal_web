class ExpenseModel {
  final String? id;
  final String fecha;
  final int? categoriaId;
  final String? categoriaNombre;
  final String? categoriaColor;
  final String descripcion;
  final double monto;
  final String metodoPago;
  final String? comprobante;
  final String? sucursal;
  final String? registradoPor;
  final String? notas;
  final String? createdAt;

  const ExpenseModel({
    this.id,
    required this.fecha,
    this.categoriaId,
    this.categoriaNombre,
    this.categoriaColor,
    required this.descripcion,
    required this.monto,
    required this.metodoPago,
    this.comprobante,
    this.sucursal,
    this.registradoPor,
    this.notas,
    this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final cat = json['categorias_egresos'] as Map<String, dynamic>?;
    return ExpenseModel(
      id: json['id'] as String?,
      fecha: json['fecha'] as String? ?? '',
      categoriaId: json['categoria_id'] as int?,
      categoriaNombre: cat?['nombre'] as String?,
      categoriaColor: cat?['color'] as String?,
      descripcion: json['descripcion'] as String? ?? '',
      monto: _toDouble(json['monto']),
      metodoPago: json['metodo_pago'] as String? ?? 'efectivo',
      comprobante: json['comprobante'] as String?,
      sucursal: json['sucursal'] as String?,
      registradoPor: json['registrado_por'] as String?,
      notas: json['notas'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'fecha': fecha,
    'categoria_id': categoriaId,
    'descripcion': descripcion,
    'monto': monto,
    'metodo_pago': metodoPago,
    if (comprobante != null && comprobante!.isNotEmpty) 'comprobante': comprobante,
    if (sucursal != null) 'sucursal': sucursal,
    if (registradoPor != null) 'registrado_por': registradoPor,
    if (notas != null && notas!.isNotEmpty) 'notas': notas,
  };

  ExpenseModel copyWith({
    String? id,
    String? fecha,
    int? categoriaId,
    String? categoriaNombre,
    String? categoriaColor,
    String? descripcion,
    double? monto,
    String? metodoPago,
    String? comprobante,
    String? sucursal,
    String? registradoPor,
    String? notas,
  }) => ExpenseModel(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    categoriaId: categoriaId ?? this.categoriaId,
    categoriaNombre: categoriaNombre ?? this.categoriaNombre,
    categoriaColor: categoriaColor ?? this.categoriaColor,
    descripcion: descripcion ?? this.descripcion,
    monto: monto ?? this.monto,
    metodoPago: metodoPago ?? this.metodoPago,
    comprobante: comprobante ?? this.comprobante,
    sucursal: sucursal ?? this.sucursal,
    registradoPor: registradoPor ?? this.registradoPor,
    notas: notas ?? this.notas,
    createdAt: createdAt,
  );
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
