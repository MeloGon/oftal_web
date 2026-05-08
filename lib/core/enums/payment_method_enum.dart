enum PaymentMethodEnum {
  efectivo('efectivo', 'Efectivo'),
  tarjeta('tarjeta', 'Tarjeta'),
  transferencia('transferencia', 'Transferencia'),
  nomina('nomina', 'Nómina'),
  otro('otro', 'Otro');

  const PaymentMethodEnum(this.value, this.label);
  final String value;
  final String label;
}
