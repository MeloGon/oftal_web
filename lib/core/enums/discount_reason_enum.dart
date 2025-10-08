enum DiscountReasonEnum {
  especialDiscount('Descuento especial'),
  discount('Temporada'),
  other('Otros');

  const DiscountReasonEnum(this.name);
  final String name;
}
