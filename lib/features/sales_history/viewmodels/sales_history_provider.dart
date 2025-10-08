import 'package:flutter/widgets.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> getSales() async {
    if (searchController.text.isNotEmpty) {
      state = state.copyWith(isLoading: true);
      try {
        final response = await Supabase.instance.client
            .from('ventas cortas')
            .select()
            .textSearch(
              '"PACIENTE"',
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
          .limit(5)
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
}
