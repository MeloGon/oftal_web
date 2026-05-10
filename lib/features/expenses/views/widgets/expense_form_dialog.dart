import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/expenses/viewmodels/expenses_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ExpenseFormDialog {
  Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    ExpenseModel? expense,
  }) {
    return showShadDialog(
      context: context,
      builder: (_) => _ExpenseFormContent(expense: expense),
    );
  }
}

class _ExpenseFormContent extends ConsumerStatefulWidget {
  const _ExpenseFormContent({this.expense});
  final ExpenseModel? expense;

  @override
  ConsumerState<_ExpenseFormContent> createState() =>
      _ExpenseFormContentState();
}

class _ExpenseFormContentState extends ConsumerState<_ExpenseFormContent> {
  late DateTime _selectedDate;
  late final TextEditingController _fechaCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _montoCtrl;
  late final TextEditingController _comprobanteCtrl;
  late final TextEditingController _notasCtrl;

  PaymentMethodEnum _method = PaymentMethodEnum.efectivo;
  int _categoriaId = -1; // -1 = sin categoría
  String? _sucursal;
  String? _montoError;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    final fechaTexto = e?.fecha ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fechaCtrl = TextEditingController(text: fechaTexto);
    try {
      _selectedDate = DateFormat('yyyy-MM-dd').parse(fechaTexto);
    } catch (_) {
      _selectedDate = DateTime.now();
    }
    _descCtrl = TextEditingController(text: e?.descripcion ?? '');
    _montoCtrl = TextEditingController(
      text: e != null ? e.monto.toStringAsFixed(2) : '',
    );
    _comprobanteCtrl = TextEditingController(text: e?.comprobante ?? '');
    _notasCtrl = TextEditingController(text: e?.notas ?? '');
    _categoriaId = e?.categoriaId ?? -1;
    _sucursal = e?.sucursal ?? '';
    if (e?.metodoPago != null) {
      _method = PaymentMethodEnum.values.firstWhere(
        (m) => m.value == e!.metodoPago,
        orElse: () => PaymentMethodEnum.efectivo,
      );
    }
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _descCtrl.dispose();
    _montoCtrl.dispose();
    _comprobanteCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final monto = double.tryParse(_montoCtrl.text);
    if (monto == null || monto <= 0) {
      setState(() => _montoError = 'Ingresa un monto válido');
      return;
    }
    if (_descCtrl.text.trim().isEmpty) return;

    final expense = ExpenseModel(
      id: widget.expense?.id,
      fecha: _fechaCtrl.text,
      categoriaId: _categoriaId == -1 ? null : _categoriaId,
      descripcion: _descCtrl.text.trim(),
      monto: monto,
      metodoPago: _method.value,
      comprobante: _comprobanteCtrl.text.trim().isEmpty
          ? null
          : _comprobanteCtrl.text.trim(),
      sucursal: _sucursal?.isEmpty == true ? null : _sucursal,
      notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
    );

    context.pop();

    if (_isEditing) {
      ref.read(expensesProvider.notifier).updateExpense(expense);
    } else {
      ref.read(expensesProvider.notifier).insertExpense(expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final categories = ref.watch(expensesProvider).categories;

    return ShadDialog(
      constraints: BoxConstraints(
        maxWidth: size.width * 0.5,
        minWidth: 340,
        maxHeight: size.height * 0.9,
      ),
      closeIcon: ShadIconButton(
        icon: const Icon(Icons.close, size: 16),
        onPressed: () => context.pop(),
      ),
      title: Text(_isEditing ? 'Editar egreso' : 'Nuevo egreso'),
      actions: [
        ShadButton.outline(
          onPressed: () => context.pop(),
          child: const Text('Cancelar'),
        ),
        ShadButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Guardar cambios' : 'Registrar'),
        ),
      ],
      child: Flexible(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14,
            children: [
              // ── Fecha + Monto ─────────────────────────────────
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppDatePickerButton(
                    label: 'Fecha *',
                    selectedDate: _selectedDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                        _fechaCtrl.text = DateFormat('yyyy-MM-dd').format(date);
                      });
                    },
                  ),
                  _Field(
                    label: 'Monto *',
                    error: _montoError,
                    child: ShadInput(
                      controller: _montoCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      placeholder: const Text('0.00'),
                      onChanged: (_) => setState(() => _montoError = null),
                    ).constrained(width: 130),
                  ),
                ],
              ),

              // ── Categoría + Método de pago ────────────────────
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Field(
                    label: 'Categoría',
                    child: ShadSelect<int>(
                      placeholder: const Text('Sin categoría'),
                      initialValue: _categoriaId,
                      selectedOptionBuilder: (ctx, v) => Text(
                        v == -1
                            ? 'Sin categoría'
                            : (categories
                                    .where((c) => c.id == v)
                                    .firstOrNull
                                    ?.nombre ??
                                'Sin categoría'),
                      ),
                      options: [
                        const ShadOption(value: -1, child: Text('Sin categoría')),
                        ...categories
                            .where((c) => c.id != null)
                            .map(
                              (c) => ShadOption(value: c.id!, child: Text(c.nombre)),
                            ),
                      ],
                      onChanged: (v) => setState(() => _categoriaId = v ?? -1),
                    ).constrained(width: 200),
                  ),
                  _Field(
                    label: 'Método de pago',
                    child: ShadSelect<PaymentMethodEnum>(
                      initialValue: _method,
                      selectedOptionBuilder: (ctx, v) => Text(v.label),
                      options: PaymentMethodEnum.values
                          .map(
                            (m) => ShadOption(value: m, child: Text(m.label)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _method = v);
                      },
                    ).constrained(width: 160),
                  ),
                ],
              ),

              // ── Descripción ───────────────────────────────────
              _Field(
                label: 'Descripción *',
                child: ShadInput(
                  controller: _descCtrl,
                  placeholder: const Text('Describe el gasto...'),
                ),
              ),

              // ── Comprobante + Sucursal ────────────────────────
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Field(
                    label: 'Comprobante (opcional)',
                    child: ShadInput(
                      controller: _comprobanteCtrl,
                      placeholder: const Text('N° factura / recibo'),
                    ).constrained(width: 180),
                  ),
                  _Field(
                    label: 'Sucursal',
                    child: ShadSelect<String>(
                      placeholder: const Text('Global'),
                      initialValue: _sucursal ?? '',
                      selectedOptionBuilder: (ctx, v) =>
                          Text(v.isEmpty ? 'Global' : v),
                      options: [
                        const ShadOption(value: '', child: Text('Global')),
                        ...BranchEnum.values.map(
                          (b) =>
                              ShadOption(value: b.name, child: Text(b.name)),
                        ),
                      ],
                      onChanged: (v) => setState(
                        () => _sucursal = v,
                      ),
                    ).constrained(width: 160),
                  ),
                ],
              ),

              // ── Notas ─────────────────────────────────────────
              _Field(
                label: 'Notas (opcional)',
                child: ShadInput(
                  controller: _notasCtrl,
                  maxLines: 2,
                  placeholder: const Text('Observaciones adicionales...'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.error});
  final String label;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xff52525B),
          ),
        ),
        child,
        if (error != null)
          Text(
            error!,
            style: const TextStyle(fontSize: 11, color: Color(0xffEF4444)),
          ),
      ],
    );
  }
}
