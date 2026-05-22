import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/sales_by_seller_state.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';

final salesBySellerProvider =
    AutoDisposeNotifierProvider<SalesBySeller, SalesBySellerState>(
      SalesBySeller.new,
    );

class SalesBySeller extends AutoDisposeNotifier<SalesBySellerState> {
  static final _fmt = DateFormat('yyyy-MM-dd');

  @override
  SalesBySellerState build() {
    final now = DateTime.now();
    Future.microtask(loadSales);
    return SalesBySellerState(
      selectedMonth: DateTime(now.year, now.month),
    );
  }

  Future<void> loadSales() async {
    state = state.copyWith(isLoading: true, sales: [], clearSelectedSellers: true);
    final month = state.selectedMonth;
    final from = _fmt.format(DateTime(month.year, month.month, 1));
    final to = _fmt.format(DateTime(month.year, month.month + 1, 0));

    final result = await ref
        .read(saleRepositoryProvider)
        .getSalesByDateRange(from, to);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (sales) => state = state.copyWith(isLoading: false, sales: sales),
    );
  }

  void selectMonth(DateTime month) {
    state = state.copyWith(selectedMonth: DateTime(month.year, month.month));
    loadSales();
  }

  void toggleSeller(String seller) {
    final available = state.availableSellers;
    // Start from current selection (null = all active)
    final current = state.selectedSellers ?? available.toSet();
    final updated = Set<String>.from(current);
    if (updated.contains(seller)) {
      updated.remove(seller);
    } else {
      updated.add(seller);
    }
    // If all are selected again → reset to null (all)
    final isAll = updated.length == available.length;
    state = state.copyWith(
      selectedSellers: isAll ? null : updated,
      clearSelectedSellers: isAll,
    );
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }
}
