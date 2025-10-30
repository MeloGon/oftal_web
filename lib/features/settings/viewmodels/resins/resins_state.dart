import 'package:oftal_web/shared/models/shared_models.dart';

class ResinsState {
  final bool isLoading;
  final String errorMessage;
  final List<ResinModel> resins;
  final int rowsPerPage;
  final int totalCount;
  final int offset;
  final bool hasMore;
  final SnackbarConfigModel? snackbarConfig;

  ResinsState({
    this.isLoading = false,
    this.errorMessage = '',
    this.resins = const [],
    this.rowsPerPage = 5,
    this.totalCount = 0,
    this.offset = 0,
    this.hasMore = true,
    this.snackbarConfig,
  });

  ResinsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ResinModel>? resins,
    int? rowsPerPage,
    int? totalCount,
    int? offset,
    bool? hasMore,
    SnackbarConfigModel? snackbarConfig,
  }) {
    return ResinsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      resins: resins ?? this.resins,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      totalCount: totalCount ?? this.totalCount,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
    );
  }
}
