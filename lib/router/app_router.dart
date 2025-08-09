import 'package:fluro/fluro.dart';
import 'package:oftal_web/router/admin_handlers.dart';
import 'package:oftal_web/router/no_page_found_handlers.dart';

class Flurorouter {
  static final FluroRouter router = FluroRouter();

  static String rootRoute = '/';

  static void configureRoutes() {
    router.define(
      rootRoute,
      handler: AdminHandlers.login,
      transitionType: TransitionType.none,
    );

    // 404
    router.notFoundHandler = NoPageFoundHandlers.noPageFound;
  }
}
