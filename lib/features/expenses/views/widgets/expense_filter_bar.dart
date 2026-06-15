import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/expenses/viewmodels/expenses_provider.dart';
import 'package:oftal_web/features/expenses/viewmodels/expenses_state.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sellers_list_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ExpenseFilterBar extends ConsumerWidget {
  const ExpenseFilterBar({
    super.key,
    required this.state,
    required this.onSearchChanged,
  });

  final ExpensesState state;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(expensesProvider.notifier);

    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: ShadInput(
              placeholder: const Text('Buscar por descripción o comprobante'),
              leading:
                  const Icon(Icons.search, size: 14, color: AppColors.zinc500),
              onChanged: onSearchChanged,
            ),
          ),
          SizedBox(
            width: 200,
            child: ShadSelect<String>(
              placeholder: const Text('Sucursal'),
              initialValue: state.filterBranch,
              onChanged: (v) => notifier.setBranchFilter(
                v == null || v.isEmpty ? null : v,
              ),
              selectedOptionBuilder: (ctx, v) => Text(
                v.isEmpty ? 'Todas' : v,
              ),
              options: [
                const ShadOption(
                    value: '', child: Text('Todas las sucursales')),
                ...BranchEnum.values.map(
                  (b) => ShadOption(value: b.name, child: Text(b.name)),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 220,
            child: ref.watch(sellersListProvider).when(
                  data: (sellers) => ShadSelect<String>(
                    placeholder: const Text('Vendedor'),
                    initialValue: state.filterRegisteredBy,
                    onChanged: (v) => notifier.setRegisteredByFilter(
                      v == null || v.isEmpty ? null : v,
                    ),
                    selectedOptionBuilder: (ctx, v) => Text(
                      v.isEmpty ? 'Todos' : v,
                    ),
                    options: [
                      const ShadOption(
                          value: '', child: Text('Todos los vendedores')),
                      ...sellers.map(
                        (s) =>
                            ShadOption(value: s.name, child: Text(s.name)),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(
                    height: 36,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (_, __) => const Text('Error cargando vendedores'),
                ),
          ),
          ShadButton.outline(
            size: ShadButtonSize.sm,
            onPressed: notifier.clearFilters,
            child: const Row(
              spacing: 6,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_alt_off_outlined, size: 14),
                Text('Limpiar'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
