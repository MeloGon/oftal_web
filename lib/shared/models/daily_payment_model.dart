class DailyPaymentModel {
  final int? id;
  final String idRemision;
  final double monto;
  final String fechaPago;
  final String? metodoPago;
  final String? notas;
  final String? creadoEl;
  final String? paciente;
  final String? folioRemision;
  final String? sucursal;
  final String paymentType;

  const DailyPaymentModel({
    this.id,
    required this.idRemision,
    required this.monto,
    required this.fechaPago,
    this.metodoPago,
    this.notas,
    this.creadoEl,
    this.paciente,
    this.folioRemision,
    this.sucursal,
    this.paymentType = 'abono_saldo',
  });

  bool get isNewSale => paymentType == 'nueva_venta';

  factory DailyPaymentModel.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? saleJson,
  ) => DailyPaymentModel(
    id: json['id'] as int?,
    idRemision: json['id_remision'] as String,
    monto: (json['monto'] as num).toDouble(),
    fechaPago: (json['fecha_pago'] as String?) ?? '',
    metodoPago: json['metodo_pago'] as String?,
    notas: json['notas'] as String?,
    creadoEl: json['creado_el'] as String?,
    paciente: saleJson?['PACIENTE'] as String?,
    folioRemision: saleJson?['FOLIO REMISION'] as String?,
    sucursal: saleJson?['SUCURSAL'] as String?,
    paymentType: (json['tipo_pago'] as String?) ?? 'abono_saldo',
  );
}
