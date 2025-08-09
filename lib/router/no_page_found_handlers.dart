import 'package:fluro/fluro.dart';
import 'package:oftal_web/shared/layouts/no_page_found_view.dart';

class NoPageFoundHandlers {
  static Handler noPageFound = Handler(
    handlerFunc: (context, params) {
      return const NoPageFoundView();
    },
  );
}
