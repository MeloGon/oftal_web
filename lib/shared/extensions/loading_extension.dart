import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/shared/widgets/loading_dialog.dart';

extension LoadingListener on WidgetRef {
  /// Escucha cambios en [isLoadingProvider] y muestra/oculta el [LoadingDialog]
  /// automáticamente. [onHidden] se ejecuta justo después de cerrar el dialog.
  void listenLoading(
    ProviderListenable<bool> isLoadingProvider,
    BuildContext context, {
    VoidCallback? onHidden,
  }) {
    listen<bool>(isLoadingProvider, (previous, next) {
      if (next && !(previous ?? false)) {
        LoadingDialog().show(context);
      }
      if (!next && (previous ?? false)) {
        if (context.mounted) {
          context.pop();
          onHidden?.call();
        }
      }
    });
  }
}
