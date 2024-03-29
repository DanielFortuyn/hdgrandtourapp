
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState.popAndPushNamed(routeName);
  }

  bool goBack() {
    // return navigatorKey.currentState.pop();
  }
}
