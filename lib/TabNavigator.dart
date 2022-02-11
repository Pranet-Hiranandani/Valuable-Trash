import 'package:flutter/material.dart';
import 'package:val_trash/profile.dart';
import 'package:val_trash/Classify.dart';
import 'package:val_trash/home.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({required this.navigatorKey, required this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  @override
  Widget build(BuildContext context) {
    Widget child = Home();
    if (tabItem == "Home")
      child = Home();
    else if (tabItem == "Reuse")
      child = ClassifyImage(
        recycle: false,
      );
    else if (tabItem == "Recycle") 
      child = ClassifyImage(
        recycle: true,
      );
    else if (tabItem == "ProfilePage") child = ProfilePage();

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
