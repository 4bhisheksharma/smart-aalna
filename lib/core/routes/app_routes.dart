import 'package:flutter/material.dart';
import 'package:smart_aalna/features/home/screens/add_clothes_screen.dart';
import 'package:smart_aalna/features/home/screens/added_clothes_screen.dart';
import 'package:smart_aalna/features/home/screens/added_clothes_desc_scree.dart';
import 'package:smart_aalna/features/home/screens/home_screen.dart';
import 'package:smart_aalna/features/home/screens/main_screen.dart';
import 'package:smart_aalna/features/home/model/clothing_item.dart';

class AppRoutes {
  static const String home = '/';
  static const String addClothes = '/add-clothes';
  static const String customerHome = '/customer-home';
  static const String addedClothes = '/added-clothes';
  static const String addedClothesDesc = '/added-clothes-desc';
}

class AppRouter {
  static MaterialPageRoute onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
      case AppRoutes.customerHome:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );

      case AppRoutes.addClothes:
        return MaterialPageRoute(
          builder: (_) => const AddClothesScreen(),
          settings: settings,
        );

      case AppRoutes.addedClothes:
        return MaterialPageRoute(
          builder: (_) => const AddedClothesScreen(),
          settings: settings,
        );

      case AppRoutes.addedClothesDesc:
        final item = settings.arguments as ClothingItem;
        return MaterialPageRoute(
          builder: (_) => AddedClothesDescScree(item: item),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );
    }
  }
}
