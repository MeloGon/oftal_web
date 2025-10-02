import 'package:flutter/material.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CustomSnackbar {
  void show(
    BuildContext context,
    SnackbarConfigModel snackbarConfig,
    String errorMessage,
  ) {
    final Color bgColor;
    switch (snackbarConfig.type) {
      case SnackbarEnum.error:
        bgColor = ShadZincColorScheme.light().destructive;
        break;
      case SnackbarEnum.success:
        bgColor = ShadZincColorScheme.light().primary;
        break;
      case SnackbarEnum.warning:
        bgColor = ShadZincColorScheme.light().primary;
        break;
      case SnackbarEnum.info:
        bgColor = ShadZincColorScheme.light().primary;
        break;
    }

    if (errorMessage == 'Invalid login credentials') {
      errorMessage = 'Credenciales inválidas';
    }

    ShadToaster.of(context).show(
      ShadToast(
        title: Text(
          snackbarConfig.title,
          style: TextStyle(
            color: ShadZincColorScheme.light().primaryForeground,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        description: Text(
          errorMessage,
          style: TextStyle(
            color: ShadZincColorScheme.light().primaryForeground,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: bgColor,
      ),
    );
  }
}
