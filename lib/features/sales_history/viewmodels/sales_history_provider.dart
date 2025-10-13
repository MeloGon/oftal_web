import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/widgets.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;

part 'sales_history_provider.g.dart';

@Riverpod(keepAlive: true)
class SalesHistory extends _$SalesHistory {
  final searchController = TextEditingController();
  @override
  SalesHistoryState build() {
    Future.microtask(getSales);
    ref.onDispose(() {
      searchController.dispose();
    });
    return SalesHistoryState();
  }

  final mask = MaskTextInputFormatter(
    mask: '####-##-##',
    filter: {
      '#': RegExp(r'[0-9]'),
    },
  );

  Future<void> getSales() async {
    if (searchController.text.isNotEmpty) {
      state = state.copyWith(isLoading: true);
      try {
        final filter = _getFilter();
        final response =
            (state.selectedFilter == FilterToSalesHistory.date)
                ? await Supabase.instance.client
                    .from('ventas cortas')
                    .select()
                    .eq(filter, searchController.text)
                    .order('fecha_actualizada', ascending: false)
                : await Supabase.instance.client
                    .from('ventas cortas')
                    .select()
                    .textSearch(
                      filter,
                      '%${searchController.text}%',
                      type: TextSearchType.plain,
                    );
        state = state.copyWith(
          sales: response.map((json) => SalesModel.fromJson(json)).toList(),
        );
      } catch (e) {
        state = state.copyWith(
          errorMessage: e.toString(),
          snackbarConfig: SnackbarConfigModel(
            title: 'Error',
            type: SnackbarEnum.error,
          ),
        );
      } finally {
        state = state.copyWith(isLoading: false);
      }
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final response = await Supabase.instance.client
          .from('ventas cortas')
          .select()
          .limit(10)
          .order('fecha_actualizada', ascending: false);
      state = state.copyWith(
        sales: response.map((json) => SalesModel.fromJson(json)).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  String _getFilter() {
    switch (state.selectedFilter) {
      case FilterToSalesHistory.patient:
        return 'PACIENTE';
      case FilterToSalesHistory.folio:
        return 'FOLIO REMISION';
      case FilterToSalesHistory.date:
        return 'fecha_actualizada';
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
    try {
      final response = await Supabase.instance.client
          .from('ventas')
          .select()
          .eq('FOLIO DE VENTA', state.saleSelectedForDetails!.folioSale!);
      state = state.copyWith(
        saleDetails:
            response.map((json) => SalesDetailsModel.fromJson(json)).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void closeSaleDetails() {
    state = state.copyWith(saleSelectedForDetails: SalesModel.empty());
  }

  void changeRowsPerPage(int value) {
    state = state.copyWith(rowsPerPage: value);
  }

  void selectFilter(FilterToSalesHistory filter) {
    state = state.copyWith(selectedFilter: filter);
    searchController.clear();
    getSales();
  }

  void exportPatientsToCsv(List<SalesModel> sales) {
    final rows = [
      ['Nombre', 'Fecha'],
      ...sales.map((p) => [p.patient, p.date]),
    ];

    final csv = const ListToCsvConverter().convert(rows);

    // ↓ Crear y descargar el archivo en Web
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute("download", "pacientes.csv")
          ..click();
    html.Url.revokeObjectUrl(url);
  }
}
