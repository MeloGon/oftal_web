class ExpenseCategoryModel {
  final int? id;
  final String nombre;
  final String color;

  const ExpenseCategoryModel({
    this.id,
    required this.nombre,
    required this.color,
  });

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) =>
      ExpenseCategoryModel(
        id: json['id'] as int?,
        nombre: json['nombre'] as String? ?? '',
        color: json['color'] as String? ?? '#6366F1',
      );

  Map<String, dynamic> toJson() => {'nombre': nombre, 'color': color};
}
