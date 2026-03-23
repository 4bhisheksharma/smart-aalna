import 'package:flutter/material.dart';
import 'package:smart_aalna/features/home/screens/add_clothes_screen.dart';
import 'package:smart_aalna/features/home/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String addClothes = '/add-clothes';
  static const String customerHome = '/customer-home';
}

class AppRouter {
  static MaterialPageRoute onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
      case AppRoutes.customerHome:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.addClothes:
        return MaterialPageRoute(
          builder: (_) => const AddClothesScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }
}
