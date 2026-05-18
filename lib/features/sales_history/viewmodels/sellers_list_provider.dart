import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

final sellersListProvider = FutureProvider<List<SellerModel>>((ref) async {
  final result = await ref.read(sellerRepositoryProvider).getSellers();
  return result.fold((_) => [], (sellers) => sellers);
});
