enum ReportPeriodFilter {
  day('Día'),
  month('Mes'),
  range('Rango');

  const ReportPeriodFilter(this.label);
  final String label;
}
