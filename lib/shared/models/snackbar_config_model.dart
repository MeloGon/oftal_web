import 'package:oftal_web/core/enums/snackbar_enum.dart';

class SnackbarConfigModel {
  final String title;
  final SnackbarEnum type;

  SnackbarConfigModel({
    required this.title,
    required this.type,
  });
}
