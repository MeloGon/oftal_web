class PaymentModel {
  final int? id;
  final String idRemision;
  final double monto;
  final String fechaPago;
  final String? metodoPago;
  final String? registradoPor;
  final String? notas;
  final String? creadoEl;

  const PaymentModel({
    this.id,
    required this.idRemision,
    required this.monto,
    required this.fechaPago,
    this.metodoPago,
    this.registradoPor,
    this.notas,
    this.creadoEl,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'] as int?,
    idRemision: json['id_remision'] as String,
    monto: (json['monto'] as num).toDouble(),
    fechaPago: (json['fecha_pago'] as String?) ?? '',
    metodoPago: json['metodo_pago'] as String?,
    registradoPor: json['registrado_por'] as String?,
    notas: json['notas'] as String?,
    creadoEl: json['creado_el'] as String?,
  );

  Map<String, dynamic> toInsertJson() => {
    'id_remision': idRemision,
    'monto': monto,
    'fecha_pago': fechaPago,
    if (metodoPago != null) 'metodo_pago': metodoPago,
    if (registradoPor != null) 'registrado_por': registradoPor,
    if (notas != null && notas!.isNotEmpty) 'notas': notas,
  };
}
