extension StringToCurrencyExtension on double {
  String toCurrency() {
    return 's/.${toStringAsFixed(2)}';
  }
}
