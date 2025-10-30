import 'package:oftal_web/shared/models/shared_models.dart';

class MountsState {
  final bool isLoading;
  final String errorMessage;
  final List<MountModel> mounts;
  final int rowsPerPage;
  final int totalCount; // total de filas en servidor
  final int offset; // índice inicial de la página actual
  final bool hasMore; // si el servidor tiene más filas por cargar
  final SnackbarConfigModel? snackbarConfig;

  MountsState({
    this.isLoading = false,
    this.errorMessage = '',
    this.mounts = const [],
    this.rowsPerPage = 10,
    this.totalCount = 0,
    this.offset = 0,
    this.hasMore = true,
    this.snackbarConfig,
  });

  MountsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MountModel>? mounts,
    int? rowsPerPage,
    int? totalCount,
    int? offset,
    bool? hasMore,
    SnackbarConfigModel? snackbarConfig,
  }) {
    return MountsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      mounts: mounts ?? this.mounts,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      totalCount: totalCount ?? this.totalCount,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
    );
  }
}
