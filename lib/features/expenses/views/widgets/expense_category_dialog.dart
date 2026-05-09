import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/features/expenses/viewmodels/expenses_provider.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const _kPresetColors = [
  '#6366F1',
  '#EF4444',
  '#F59E0B',
  '#10B981',
  '#0EA5E9',
  '#8B5CF6',
  '#EC4899',
  '#14B8A6',
  '#F97316',
  '#D97706',
];

class ExpenseCategoryDialog {
  Future<void> show(BuildContext context, WidgetRef ref) {
    return showShadDialog(
      context: context,
      builder: (_) => const _CategoryContent(),
    );
  }
}

class _CategoryContent extends ConsumerStatefulWidget {
  const _CategoryContent();

  @override
  ConsumerState<_CategoryContent> createState() => _CategoryContentState();
}

class _CategoryContentState extends ConsumerState<_CategoryContent> {
  final _nombreCtrl = TextEditingController();
  String _selectedColor = _kPresetColors.first;
  bool _showForm = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    if (_nombreCtrl.text.trim().isEmpty) return;
    await ref.read(expensesProvider.notifier).insertCategory(
      ExpenseCategoryModel(
        nombre: _nombreCtrl.text.trim(),
        color: _selectedColor,
      ),
    );
    _nombreCtrl.clear();
    setState(() {
      _showForm = false;
      _selectedColor = _kPresetColors.first;
    });
  }

  Future<void> _deleteCategory(ExpenseCategoryModel cat) async {
    if (cat.id == null) return;
    final confirm = await showShadDialog<bool>(
      context: context,
      builder: (_) => ShadDialog.alert(
        title: const Text('Eliminar categoría'),
        description: Text(
          '¿Eliminar "${cat.nombre}"? Los egresos con esta categoría quedarán sin categoría.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(expensesProvider.notifier).deleteCategory(cat.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final categories = ref.watch(expensesProvider).categories;

    return ShadDialog(
      constraints: BoxConstraints(
        maxWidth: size.width * 0.4,
        minWidth: 320,
        maxHeight: size.height * 0.85,
      ),
      closeIcon: ShadIconButton(
        icon: const Icon(Icons.close, size: 16),
        onPressed: () => context.pop(),
      ),
      title: const Text('Gestionar categorías'),
      actions: [
        ShadButton.outline(
          onPressed: () => context.pop(),
          child: const Text('Cerrar'),
        ),
      ],
      child: Flexible(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              // ── Lista de categorías ────────────────────────────
              if (categories.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No hay categorías. Agrega una a continuación.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                )
              else
                ...categories.map(
                  (cat) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffFAFAFA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffE4E4E7)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _hexToColor(cat.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cat.nombre,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Color(0xffEF4444),
                          ),
                          onPressed: () => _deleteCategory(cat),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),

              const Divider(height: 1),

              // ── Toggle formulario ──────────────────────────────
              if (!_showForm)
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  onPressed: () => setState(() => _showForm = true),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      Icon(Icons.add, size: 14),
                      Text('Nueva categoría'),
                    ],
                  ),
                )
              else ...[
                // ── Formulario ─────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    const Text(
                      'Nombre',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff52525B),
                      ),
                    ),
                    ShadInput(
                      controller: _nombreCtrl,
                      placeholder: const Text('Ej: Servicios externos'),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    const Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff52525B),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _kPresetColors.map((hex) {
                        final color = _hexToColor(hex);
                        final selected = hex == _selectedColor;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColor = hex),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? const Color(0xff18181B)
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: selected
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    ShadButton.outline(
                      size: ShadButtonSize.sm,
                      onPressed: () => setState(() => _showForm = false),
                      child: const Text('Cancelar'),
                    ),
                    ShadButton(
                      size: ShadButtonSize.sm,
                      onPressed: _addCategory,
                      child: const Text('Agregar'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Color _hexToColor(String hex) {
  final clean = hex.replaceFirst('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}
