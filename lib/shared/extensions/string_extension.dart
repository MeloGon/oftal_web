extension StringExtension on String? {
  /// Verifica si el String es nulo o vacío
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Verifica si el String es nulo, vacío o solo contiene espacios en blanco
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// Verifica si el String tiene contenido (no es nulo, vacío o solo espacios)
  bool get isNotNullOrBlank => this != null && this!.trim().isNotEmpty;

  /// Retorna el String o un valor por defecto si es nulo/vacío
  String orDefault(String defaultValue) => isNullOrEmpty ? defaultValue : this!;

  /// Retorna el String o 'N/A' si es nulo/vacío
  String get orNA => orDefault('N/A');
}

extension StringNotNullExtension on String {
  /// Verifica si el String está vacío
  bool get isEmpty => this.isEmpty;

  /// Verifica si el String solo contiene espacios en blanco
  bool get isBlank => trim().isEmpty;

  /// Verifica si el String tiene contenido
  bool get isNotEmpty => this.isNotEmpty;
}
