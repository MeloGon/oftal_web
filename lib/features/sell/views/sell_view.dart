import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_state.dart';
import 'package:oftal_web/features/sell/views/widgets/page_header.dart';
import 'package:oftal_web/features/sell/views/widgets/patient_result_list.dart';
import 'package:oftal_web/features/sell/views/widgets/sell_catalog_tiles.dart';
import 'package:oftal_web/features/sell/views/widgets/sell_item_card.dart';
import 'package:oftal_web/features/sell/views/widgets/step_card.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SellView extends ConsumerStatefulWidget {
  const SellView({super.key});

  @override
  ConsumerState<SellView> createState() => _SellViewState();
}

class _SellViewState extends ConsumerState<SellView> {
  String _selectedMountBranch = BranchEnum.oftalvision.name;

  @override
  void initState() {
    super.initState();
    final branch = ref.read(authProvider).profile?.branchName ?? '';
    _selectedMountBranch =
        branch.isNotEmpty ? branch : BranchEnum.oftalvision.name;
  }

  @override
  Widget build(BuildContext context) {
    final sellNotifier = ref.watch(sellProvider.notifier);
    final sellState = ref.watch(sellProvider);
    final size = MediaQuery.sizeOf(context);

    ref.listenLoading(sellProvider.select((s) => s.isLoading), context);

    ref.listen<SellState>(sellProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(sellProvider.notifier).clearErrorMessage(),
        );
      }
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            // ─── Page header ─────────────────────────────────
            const PageHeader(),

            // ─── Step 1: Patient search ───────────────────────
            StepCard(
              step: 1,
              title: 'Seleccionar paciente',
              subtitle:
                  sellState.selectedPatient != null
                      ? 'Paciente: ${sellState.selectedPatient!.name}'
                      : 'Busca al paciente al que deseas vender',
              isCompleted: sellState.selectedPatient != null,
              action:
                  sellState.selectedPatient != null
                      ? ShadButton.outline(
                        height: 32,
                        onPressed: sellNotifier.cancelSale,
                        child: const Row(
                          spacing: 6,
                          children: [
                            Icon(LucideIcons.x, size: 14),
                            Text('Cambiar paciente'),
                          ],
                        ),
                      )
                      : null,
              child:
                  sellState.selectedPatient != null
                      ? const SizedBox.shrink()
                      : Column(
                        spacing: 10,
                        children: [
                          ShadInput(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            placeholder: const Text(
                              'Ingrese el nombre del paciente a vender',
                            ),
                            leading: const Icon(LucideIcons.search, size: 16),
                            controller: sellNotifier.searchController,
                            trailing: ShadButton(
                              height: 30,
                              onPressed: sellNotifier.searchPatient,
                              child: Text(AppStrings.search),
                            ),
                            onSubmitted: (_) => sellNotifier.searchPatient(),
                          ),
                          if (sellState.patients.isNotEmpty &&
                              !sellState.isLoading)
                            PatientResultList(
                              patients: sellState.patients,
                              onSelect: (patient) {
                                sellNotifier.selectPatient(patient);
                                sellNotifier.selectItemOption(
                                  SellItemOptionsEnum.sell,
                                );
                              },
                            ),
                          if (sellState.patients.isEmpty &&
                              !sellState.isLoading)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  AppStrings.noPatientsFound,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
            ),

            // ─── Step 2: Product selection ────────────────────
            if (sellState.selectedPatient != null &&
                sellState.selectedItemOption == SellItemOptionsEnum.sell) ...[
              StepCard(
                step: 2,
                title: 'Seleccionar productos',
                subtitle: 'Elige la categoría y busca el producto',
                isCompleted: sellState.itemsToSell.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            const Text(
                              'Clasificación',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.zinc600,
                              ),
                            ),
                            ShadSelect<String>(
                              placeholder: Text(AppStrings.select),
                              selectedOptionBuilder:
                                  (context, value) => Text(value),
                              options:
                                  OptionsToSellEnum.values
                                      .map(
                                        (e) => ShadOption(
                                          value: e.name,
                                          child: Text(e.name),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  sellNotifier.selectOptionToSell(
                                    OptionsToSellEnum.values.firstWhere(
                                      (e) => e.name == value,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        if (sellState.selectedOptionToSell ==
                            OptionsToSellEnum.mount)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6,
                            children: [
                              const Text(
                                'Sucursal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.zinc600,
                                ),
                              ),
                              ShadSelect<String>(
                                initialValue: _selectedMountBranch,
                                selectedOptionBuilder:
                                    (context, value) => Text(value),
                                options:
                                    BranchEnum.values
                                        .map(
                                          (b) => ShadOption(
                                            value: b.name,
                                            child: Text(b.name),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(
                                      () => _selectedMountBranch = value,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                size.width < 700
                                    ? size.width - 48
                                    : size.width * 0.5,
                          ),
                          child: ShadInputFormField(
                            placeholder: const Text(
                              'Nombre del producto a buscar',
                            ),
                            label: const Text('Producto'),
                            controller: sellNotifier.searchItemToSellController,
                            onSubmitted: (_) {
                              if (sellState.selectedOptionToSell ==
                                  OptionsToSellEnum.mount) {
                                sellNotifier.getMounts();
                              } else if (sellState.selectedOptionToSell ==
                                  OptionsToSellEnum.resin) {
                                sellNotifier.getResin();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (sellState.mounts.isNotEmpty && !sellState.isLoading)
                      Builder(
                        builder: (context) {
                          final filteredMounts =
                              sellState.mounts.where((m) {
                                final optic =
                                    m.opticName.trim().isEmpty
                                        ? BranchEnum.oftalvision.name
                                        : m.opticName.trim();
                                return optic.toUpperCase() ==
                                    _selectedMountBranch.toUpperCase();
                              }).toList();
                          return SizedBox(
                            width: double.infinity,
                            height: 420,
                            child: ClientPagedList<MountModel>(
                              items: filteredMounts,
                              pageSize: 5,
                              emptyLabel: 'Sin monturas en esta sucursal',
                              emptyIcon: Icons.visibility_off_outlined,
                              itemBuilder: (_, m) => MountSellTile(
                                mount: m,
                                onAdd: () => sellNotifier.selectItemToSell(m),
                              ),
                            ),
                          );
                        },
                      ),
                    if (sellState.resins.isNotEmpty && !sellState.isLoading)
                      SizedBox(
                        width: double.infinity,
                        height: 420,
                        child: ClientPagedList<ResinModel>(
                          items: sellState.resins,
                          pageSize: 5,
                          emptyLabel: 'Sin resinas',
                          emptyIcon: Icons.lens_outlined,
                          itemBuilder: (_, r) => ResinSellTile(
                            resin: r,
                            onAdd: () => sellNotifier.selectItemToSell(r),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ─── Step 3: Invoice ──────────────────────────
              StepCard(
                step: 3,
                title: 'Nota de venta',
                subtitle: 'Revisa los productos y confirma la venta',
                isCompleted: false,
                action: AppDatePickerButton(
                  label: 'Fecha',
                  selectedDate: sellNotifier.selectedDate,
                  lastDate: DateTime.now().add(
                    const Duration(days: 365),
                  ),
                  onDateSelected: (date) {
                    sellNotifier.updateDate(date);
                    setState(() {});
                  },
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isTwoColumns = constraints.maxWidth >= 860;

                    // ── Columna Izquierda: Datos del pedido y productos ──
                    final leftColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        // Paciente banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.zinc50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.zinc200),
                          ),
                          child: Row(
                            spacing: 12,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 2,
                                  children: [
                                    const Text(
                                      'Paciente',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.zinc500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Text(
                                      sellState.selectedPatient?.name ?? '—',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.zinc900,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Vendedor y Sucursal (grid responsivo)
                        LayoutBuilder(
                          builder: (context, fieldBox) {
                            final isNarrow = fieldBox.maxWidth < 460;
                            final sellerField = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Vendedor',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.zinc700,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (sellState.sellers.isNotEmpty)
                                  ShadSelect<SellerModel>(
                                    placeholder: Text(AppStrings.select),
                                    initialValue: sellState.selectedSeller,
                                    selectedOptionBuilder:
                                        (context, value) => Text(value.name),
                                    options: sellState.sellers
                                        .map(
                                          (e) => ShadOption(
                                            value: e,
                                            child: Text(e.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: sellNotifier.updateSelectedSeller,
                                  )
                                else
                                  const Text(
                                    'Sin vendedores disponibles',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.zinc400,
                                    ),
                                  ),
                              ],
                            );

                            final branchField = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Sucursal de venta',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.zinc700,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ShadSelect<BranchEnum>(
                                  placeholder: Text(AppStrings.select),
                                  initialValue: sellState.selectedBranch,
                                  selectedOptionBuilder:
                                      (context, value) => Text(value.name),
                                  options: BranchEnum.values
                                      .map(
                                        (e) => ShadOption(
                                          value: e,
                                          child: Text(e.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: sellNotifier.updateSelectedBranch,
                                ),
                              ],
                            );

                            return isNarrow
                                ? Column(
                                    spacing: 12,
                                    children: [sellerField, branchField],
                                  )
                                : Row(
                                    spacing: 12,
                                    children: [
                                      Expanded(child: sellerField),
                                      Expanded(child: branchField),
                                    ],
                                  );
                          },
                        ),

                        const Divider(height: 1),

                        // Lista de productos
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Productos en la nota (${sellState.itemsToSell.length})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.zinc800,
                              ),
                            ),
                            if (sellState.itemsToSell.isNotEmpty)
                              const Text(
                                'Precio unitario editable',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.zinc400,
                                ),
                              ),
                          ],
                        ),

                        if (sellState.itemsToSell.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemCount: sellState.itemsToSell.length,
                            itemBuilder: (context, index) {
                              final item = sellState.itemsToSell[index];
                              return SellItemCard(
                                key: ValueKey(item.id),
                                item: item,
                                onRemove: () {
                                  sellNotifier.removeItemToSell(index);
                                  setState(() {});
                                },
                                onPriceChanged: (price) {
                                  sellNotifier.updateItemPrice(index, price);
                                  setState(() {});
                                },
                              );
                            },
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: AppColors.zinc50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.zinc200),
                            ),
                            child: const Center(
                              child: Text(
                                'Aún no has agregado productos a la nota',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.zinc400,
                                ),
                              ),
                            ),
                          ),

                        // Descuento especial integrado
                        if (sellState.itemsToSell.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.violetBgLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.indigoBorder.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      spacing: 6,
                                      children: [
                                        Icon(
                                          Icons.discount_outlined,
                                          size: 15,
                                          color: AppColors.indigo,
                                        ),
                                        Text(
                                          'Descuento especial',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.indigo,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Opcional',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.indigo.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: ShadSelect<String>(
                                        placeholder: const Text(
                                          'Motivo de descuento',
                                        ),
                                        selectedOptionBuilder:
                                            (context, value) => Text(value),
                                        options: DiscountReasonEnum.values
                                            .map(
                                              (e) => ShadOption(
                                                value: e.name,
                                                child: Text(e.name),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            sellNotifier.selectDiscountReason(
                                              DiscountReasonEnum.values
                                                  .firstWhere(
                                                (e) => e.name == value,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          if (!hasFocus) {
                                            sellNotifier.applyDiscount();
                                            setState(() {});
                                          }
                                        },
                                        child: ShadInput(
                                          controller:
                                              sellNotifier.discountController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          onSubmitted: (_) {
                                            sellNotifier.applyDiscount();
                                            setState(() {});
                                          },
                                          placeholder: const Text('0.00'),
                                          leading: const Padding(
                                            padding: EdgeInsets.only(right: 2),
                                            child: Text(
                                              '- S/.',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.indigo,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    );

                    // ── Columna Derecha: Tarjeta de cobro tipo ticket ──
                    final rightColumn = _buildCheckoutSummary(
                      context,
                      sellState,
                      sellNotifier,
                    );

                    if (isTwoColumns) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: leftColumn),
                          const SizedBox(width: 24),
                          Expanded(flex: 5, child: rightColumn),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 20,
                        children: [
                          leftColumn,
                          const Divider(height: 1),
                          rightColumn,
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Helpers para Nota de Venta (Resumen de cobro POS) ────────────

  Widget _buildCheckoutSummary(
    BuildContext context,
    SellState sellState,
    dynamic sellNotifier,
  ) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        sellNotifier.importController,
        sellNotifier.discountController,
        sellNotifier.totalController,
        sellNotifier.accountController,
        sellNotifier.restController,
      ]),
      builder: (context, _) {
        final importVal =
            double.tryParse(sellNotifier.importController.text) ?? 0.0;
        final discountVal =
            double.tryParse(sellNotifier.discountController.text) ?? 0.0;
        final totalVal =
            double.tryParse(sellNotifier.totalController.text) ?? 0.0;
        final restVal =
            double.tryParse(sellNotifier.restController.text) ?? 0.0;
        final hasPendingRest = restVal > 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.zinc50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.zinc200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14,
            children: [
              // Header del Ticket
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    spacing: 6,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 16,
                        color: AppColors.zinc700,
                      ),
                      Text(
                        'Resumen de cobro',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.zinc200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${sellState.itemsToSell.length} ${sellState.itemsToSell.length == 1 ? "item" : "items"}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc700,
                      ),
                    ),
                  ),
                ],
              ),

              // Desglose de montos
              Column(
                spacing: 6,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Importe bruto',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.zinc500,
                        ),
                      ),
                      Text(
                        importVal.toCurrency(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  if (discountVal > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Descuento',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.indigo,
                          ),
                        ),
                        Text(
                          '- ${discountVal.toCurrency()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.indigo,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a pagar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc900,
                        ),
                      ),
                      Text(
                        totalVal.toCurrency(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.zinc900,
                          letterSpacing: -0.3,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Divider(height: 1),

              // A cuenta con botones de atajo rápido
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  const Text(
                    'A cuenta (abono inicial):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zinc800,
                    ),
                  ),
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        sellNotifier.leaveAccount();
                        setState(() {});
                      }
                    },
                    child: ShadInput(
                      enabled: sellState.itemsToSell.isNotEmpty,
                      controller: sellNotifier.accountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onSubmitted: (_) {
                        sellNotifier.leaveAccount();
                        setState(() {});
                      },
                      leading: const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Text(
                          'S/.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.zinc500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    spacing: 6,
                    children: [
                      Expanded(
                        child: _buildPresetButton(
                          label: 'Total (100%)',
                          onTap: () {
                            sellNotifier.accountController.text =
                                totalVal.toStringAsFixed(2);
                            sellNotifier.leaveAccount();
                            setState(() {});
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildPresetButton(
                          label: '50% Inicial',
                          onTap: () {
                            sellNotifier.accountController.text =
                                (totalVal / 2).toStringAsFixed(2);
                            sellNotifier.leaveAccount();
                            setState(() {});
                          },
                        ),
                      ),
                      _buildPresetButton(
                        label: 'S/. 0',
                        onTap: () {
                          sellNotifier.accountController.text = '0';
                          sellNotifier.leaveAccount();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // Selector visual de Método de Pago
              _buildPaymentMethodSelector(sellState, sellNotifier),

              // Saldo restante destacado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: hasPendingRest
                      ? AppColors.warningBg.withValues(alpha: 0.5)
                      : AppColors.successBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasPendingRest
                        ? AppColors.warningDark.withValues(alpha: 0.3)
                        : AppColors.successDark.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hasPendingRest ? 'Saldo por cobrar:' : 'Venta liquidada:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: hasPendingRest
                            ? AppColors.warningDark
                            : AppColors.successDark,
                      ),
                    ),
                    Text(
                      restVal.toCurrency(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: hasPendingRest
                            ? AppColors.error
                            : AppColors.successDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Botones de acción
              Column(
                spacing: 8,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton(
                      size: ShadButtonSize.lg,
                      enabled: sellState.itemsToSell.isNotEmpty,
                      onPressed: () {
                        if (sellState.selectedInitialPaymentMethod == null) {
                          _showSnackbar(
                            context,
                            SnackbarConfigModel(
                              title: 'Campo requerido',
                              type: SnackbarEnum.error,
                            ),
                            'Selecciona un método de pago antes de crear la venta',
                          );
                          return;
                        }
                        sellNotifier.createSale();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(Icons.check_circle_outline, size: 16),
                          Text('Confirmar y Crear Venta'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton.outline(
                      size: ShadButtonSize.lg,
                      onPressed: sellNotifier.cancelSale,
                      child: const Text('Cancelar venta'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodSelector(
    SellState sellState,
    dynamic sellNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Método de pago',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.zinc800,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: PaymentMethodEnum.values.map((method) {
            final isSelected =
                sellState.selectedInitialPaymentMethod == method;
            final color = _getPaymentColor(method);
            final icon = _getPaymentIcon(method);

            return InkWell(
              onTap: () => sellNotifier.selectInitialPaymentMethod(method),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? color : AppColors.zinc200,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Icon(
                      icon,
                      size: 13,
                      color: isSelected ? color : AppColors.zinc500,
                    ),
                    Text(
                      method.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? color : AppColors.zinc700,
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_rounded, size: 12, color: color),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getPaymentColor(PaymentMethodEnum method) {
    switch (method) {
      case PaymentMethodEnum.efectivo:
        return AppColors.efectivo;
      case PaymentMethodEnum.tarjeta:
        return AppColors.tarjeta;
      case PaymentMethodEnum.transferencia:
        return AppColors.transferencia;
      case PaymentMethodEnum.yape:
        return AppColors.yape;
      case PaymentMethodEnum.nomina:
        return AppColors.indigo;
      case PaymentMethodEnum.otro:
        return AppColors.zinc600;
    }
  }

  IconData _getPaymentIcon(PaymentMethodEnum method) {
    switch (method) {
      case PaymentMethodEnum.efectivo:
        return Icons.payments_outlined;
      case PaymentMethodEnum.tarjeta:
        return Icons.credit_card_outlined;
      case PaymentMethodEnum.transferencia:
        return Icons.account_balance_outlined;
      case PaymentMethodEnum.yape:
        return Icons.qr_code_2_rounded;
      case PaymentMethodEnum.nomina:
        return Icons.badge_outlined;
      case PaymentMethodEnum.otro:
        return Icons.more_horiz_rounded;
    }
  }

  Widget _buildPresetButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.zinc200),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.zinc700,
            ),
          ),
        ),
      ),
    );
  }
}

void _showSnackbar(
  BuildContext context,
  SnackbarConfigModel? snackbarConfig,
  String errorMessage,
) {
  CustomSnackbar().show(
    context,
    snackbarConfig ??
        SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
    errorMessage,
  );
}
