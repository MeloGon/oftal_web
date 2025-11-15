import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/mounts/mounts_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'mounts_provider.g.dart';

@riverpod
class Mounts extends _$Mounts {
  @override
  MountsState build() {
    Future.microtask(() async {
      final rowsPerPage = state.rowsPerPage;
      await fetchPage(offset: 0, limit: rowsPerPage);
    });
    return MountsState();
  }

  Future<void> fetchPage({required int offset, required int limit}) async {
    state = state.copyWith(isLoading: true);
    try {
      final end = offset + limit - 1;
      final response = await Supabase.instance.client
          .from('armazones')
          .select()
          .range(offset, end);
      final items = response.map((json) => MountModel.fromJson(json)).toList();
      final bool hasMore = items.length == limit;
      final int estimatedTotal =
          hasMore ? offset + items.length + limit : offset + items.length;
      state = state.copyWith(
        mounts: items,
        offset: offset,
        totalCount: estimatedTotal,
        hasMore: hasMore,
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

  void changeRowsPerPage(int newSize) {
    state = state.copyWith(rowsPerPage: newSize);
    fetchPage(offset: 0, limit: newSize);
  }
}
