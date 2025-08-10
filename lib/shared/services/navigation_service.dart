import 'package:flutter/cupertino.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static navigateTo(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }

  static navigateToWithData(String routeName, dynamic data) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: data);
  }
}
