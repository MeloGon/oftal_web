enum FilterToSalesHistory {
  folio('Folio'),
  patient('Paciente'),
  date('Fecha');

  final String label;

  const FilterToSalesHistory(this.label);
}
