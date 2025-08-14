import 'package:fluro/fluro.dart';
import 'package:oftal_web/router/admin_handlers.dart';
import 'package:oftal_web/router/dashboard_handlers.dart';
import 'package:oftal_web/router/no_page_found_handlers.dart';

class Flurorouter {
  static final FluroRouter router = FluroRouter();

  static String rootRoute = '/';
  static String dashboardRoute = '/dashboard';
  static String addPatientRoute = '/dashboard/add-patient';

  static void configureRoutes() {
    router.define(
      rootRoute,
      handler: AdminHandlers.login,
      transitionType: TransitionType.none,
    );

    router.define(
      dashboardRoute,
      handler: DashboardHandlers.dashboard,
      transitionType: TransitionType.none,
    );

    router.define(
      addPatientRoute,
      handler: DashboardHandlers.addPatient,
      transitionType: TransitionType.none,
    );

    // 404
    router.notFoundHandler = NoPageFoundHandlers.noPageFound;
  }
}
