enum FilterToSalesHistory {
  folio('Folio'),
  patient('Paciente'),
  date('Fecha'),
  seller('Vendedor');

  final String label;

  const FilterToSalesHistory(this.label);
}
