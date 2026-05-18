import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/features/settings/viewmodels/app_features_state.dart';

const _kChangeDate = 'feature_change_date';

final appFeaturesProvider =
    NotifierProvider<AppFeaturesNotifier, AppFeaturesState>(
  AppFeaturesNotifier.new,
);

class AppFeaturesNotifier extends Notifier<AppFeaturesState> {
  @override
  AppFeaturesState build() {
    _load();
    return const AppFeaturesState();
  }

  Future<void> _load() async {
    final result =
        await ref.read(appConfigRepositoryProvider).getAll();
    result.fold(
      (_) {},
      (config) => state = AppFeaturesState(
        changeDateEnabled: config[_kChangeDate] != 'false',
      ),
    );
  }

  Future<void> toggleChangeDate() async {
    final next = !state.changeDateEnabled;
    state = state.copyWith(changeDateEnabled: next, isLoading: true);
    final result = await ref
        .read(appConfigRepositoryProvider)
        .setValue(_kChangeDate, next.toString());
    result.fold(
      (_) => state = state.copyWith(
        changeDateEnabled: !next,
        isLoading: false,
      ),
      (_) => state = state.copyWith(isLoading: false),
    );
  }
}
