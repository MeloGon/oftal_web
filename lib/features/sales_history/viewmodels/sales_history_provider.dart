import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/services/receipt_pdf_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sales_history_provider.g.dart';

@Riverpod(keepAlive: true)
class SalesHistory extends _$SalesHistory {
  final searchController = TextEditingController();

  void updateSearchDate(DateTime date) {
    state = state.copyWith(searchDate: date, offset: 0);
    searchController.text = DateFormat('yyyy-MM-dd').format(date);
    getSales();
  }

  @override
  SalesHistoryState build() {
    searchController.addListener(() {
      state = state.copyWith(searchText: searchController.text);
    });
    Future.microtask(getSales);
    ref.onDispose(() {
      searchController.dispose();
    });
    return const SalesHistoryState();
  }

  Future<void> getSales() async {
    state = state.copyWith(isLoading: true);
    final hasQuery = searchController.text.isNotEmpty;
    final result = await ref
        .read(saleRepositoryProvider)
        .getSalesPage(
          filter: hasQuery ? _getFilter() : null,
          query: hasQuery ? searchController.text : null,
          isDate:
              state.selectedFilter == FilterToSalesHistory.date ||
              state.selectedFilter == FilterToSalesHistory.seller,
          onlyPending: state.onlyPending,
          offset: state.offset,
          limit: state.pageSize,
        );
    result.fold(
      (failure) =>
          state = state.copyWith(
            errorMessage: failure.message,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
            isLoading: false,
          ),
      (data) =>
          state = state.copyWith(
            sales: data.items,
            hasMore: data.hasMore,
            isLoading: false,
          ),
    );
  }

  /// Runs a new search from the first page.
  void search() {
    state = state.copyWith(offset: 0);
    getSales();
  }

  void nextPage() {
    if (!state.hasMore) return;
    state = state.copyWith(offset: state.offset + state.pageSize);
    getSales();
  }

  void prevPage() {
    if (state.offset == 0) return;
    final newOffset = (state.offset - state.pageSize).clamp(0, 1 << 31);
    state = state.copyWith(offset: newOffset);
    getSales();
  }

  void togglePending() {
    state = state.copyWith(onlyPending: !state.onlyPending, offset: 0);
    getSales();
  }

  Future<void> updateSaleDate(SalesModel sale, DateTime date) async {
    if (sale.folioSale == null) return;
    state = state.copyWith(isLoading: true);
    final fecha = DateFormat('dd-MMM-yy', 'en_US').format(date);
    final fechaActualizada = DateFormat('yyyy-MM-dd').format(date);
    final result = await ref
        .read(saleRepositoryProvider)
        .updateSaleDate(sale.folioSale!, fecha, fechaActualizada, sale.id!);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (_) async {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Fecha actualizada correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
        );
        // Audit log handled server-side by trigger trg_audit_sale_date.
        getSales();
      },
    );
  }

  void clearFilters() {
    searchController.clear();
    state = state.copyWith(
      selectedFilter: null,
      onlyPending: false,
      searchDate: null,
      offset: 0,
    );
    getSales();
  }

  String _getFilter() {
    switch (state.selectedFilter) {
      case FilterToSalesHistory.patient:
        return 'PACIENTE';
      case FilterToSalesHistory.folio:
        return 'FOLIO REMISION';
      case FilterToSalesHistory.date:
        return 'fecha_actualizada';
      case FilterToSalesHistory.seller:
        return 'AUTOR NOMBRE';
      case null:
        return 'PACIENTE';
    }
  }

  void selectSaleForDetails(SalesModel sale) {
    state = state.copyWith(saleSelectedForDetails: sale);
    getSalesDetails();
  }

  Future<void> getSalesDetails() async {
    if (state.saleSelectedForDetails == null) return;
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(saleRepositoryProvider)
        .getSaleDetails(state.saleSelectedForDetails!.folioSale!);
    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
      (details) =>
          state = state.copyWith(
            saleDetails: details,
            isLoading: false,
          ),
    );
  }

  void closeSaleDetails() {
    state = state.copyWith(saleSelectedForDetails: null);
  }

  void selectFilter(FilterToSalesHistory filter) {
    state = state.copyWith(selectedFilter: filter, offset: 0);
    searchController.clear();
    getSales();
  }

  void exportPatientsToCsv(List<SalesModel> sales) {
    // final rows = [
    //   ['Nombre', 'Fecha'],
    //   ...sales.map((sale) => [sale.patient, sale.date]),
    // ];
    // final csv = const ListToCsvConverter().convert(rows);
    // final bytes = utf8.encode(csv);
    // final blob = html.Blob([bytes]);
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor =
    //     html.AnchorElement(href: url)
    //       ..setAttribute("download", "pacientes.csv")
    //       ..click();
    // html.Url.revokeObjectUrl(url);
  }

  Future<void> deleteSale(SalesModel sale) async {
    state = state.copyWith(isLoading: true);
    if (sale.folioSale == null) return;

    final detailsResult = await ref
        .read(saleRepositoryProvider)
        .getSaleDetails(sale.folioSale!);
    await detailsResult.fold(
      (failure) async {},
      (details) async {
        for (final detail in details) {
          final mountId = detail.idMount;
          if (mountId != null && mountId != 0) {
            await ref.read(mountRepositoryProvider).incrementStock(mountId);
          }
        }
      },
    );

    if (sale.id != null) {
      await ref
          .read(paymentRepositoryProvider)
          .deletePaymentsByRemision(sale.id!);
    }

    final result = await ref
        .read(saleRepositoryProvider)
        .deleteSale(sale.folioSale!);
    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
      (_) async {
        state = state.copyWith(
          isLoading: false,
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
          errorMessage: 'Venta eliminada correctamente',
        );
        await getSales();
      },
    );
  }

  Future<void> finalizeSale(SalesModel sale) async {
    state = state.copyWith(isLoading: true);
    final remainingRest = sale.rest ?? 0;
    final updated = SalesModel(
      id: sale.id,
      branch: sale.branch,
      date: sale.date,
      patient: sale.patient,
      authorName: sale.authorName,
      total: sale.total,
      discount: sale.discount,
      totalWithDiscount: sale.totalWithDiscount,
      account: sale.totalWithDiscount,
      rest: 0,
      folioSale: sale.folioSale,
      updatedDate: sale.updatedDate,
    );
    final result = await ref
        .read(saleRepositoryProvider)
        .updateShortSale(updated);
    await result.fold(
      (failure) async =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
      (_) async {
        if (remainingRest > 0 && sale.id != null) {
          final userId = ref.read(authProvider).profile?.id;
          final payment = PaymentModel(
            idRemision: sale.id!,
            monto: remainingRest,
            fechaPago: DateTime.now().toIso8601String().substring(0, 10),
            metodoPago: 'otro',
            registradoPor: userId,
            notas: 'Liquidación de venta',
          );
          await ref.read(paymentRepositoryProvider).insertPayment(payment);
        }
        getSales();
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Venta finalizada correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
        );
      },
    );
  }

  Future<void> registerPayment({
    required SalesModel sale,
    required double monto,
    required String fechaPago,
    required String metodoPago,
    String? notas,
  }) async {
    state = state.copyWith(isLoading: true);
    final userId = ref.read(authProvider).profile?.id;
    final payment = PaymentModel(
      idRemision: sale.id!,
      monto: monto,
      fechaPago: fechaPago,
      metodoPago: metodoPago,
      registradoPor: userId,
      notas: notas,
    );
    final insertResult = await ref
        .read(paymentRepositoryProvider)
        .insertPayment(payment);
    await insertResult.fold(
      (failure) async =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
      (_) async {
        final newAccount = (sale.account ?? 0) + monto;
        final newRest =
            ((sale.totalWithDiscount ?? 0) - newAccount)
                .clamp(
                  0,
                  double.infinity,
                )
                .toDouble();
        final updateResult = await ref
            .read(saleRepositoryProvider)
            .updateAccountPayment(sale.id!, newAccount, newRest, fechaPago);
        updateResult.fold(
          (failure) =>
              state = state.copyWith(
                isLoading: false,
                errorMessage: failure.message,
                snackbarConfig: SnackbarConfigModel(
                  title: 'Error',
                  type: SnackbarEnum.error,
                ),
              ),
          (_) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: 'Abono registrado correctamente',
              snackbarConfig: SnackbarConfigModel(
                title: 'Aviso',
                type: SnackbarEnum.success,
              ),
            );
            getSales();
          },
        );
      },
    );
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }

  void clearSaleSelectedForDetails() {
    state = state.copyWith(saleSelectedForDetails: null);
  }

  Future<void> generatePdf(SalesModel sale) async {
    final saleDetails = state.saleDetails;
    await ReceiptPdfService.generateAndDownloadReceipt(
      sale: sale,
      details: saleDetails,
    );
  }
}
