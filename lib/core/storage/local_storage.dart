import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aalna/features/home/model/clothing_item.dart';

class LocalStorage {
  static const String _homeUserNameKey = 'home_user_name';
  static const String _clothesKey = 'saved_clothes';
  static const String _dailyOutfitDateKey = 'daily_outfit_date';
  static const String _dailyOutfitMsgKey = 'daily_outfit_msg';
  static const String _dailyOutfitItemsKey = 'daily_outfit_items';

  static final ValueNotifier<int> clothesUpdateNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<String> userNameNotifier = ValueNotifier<String>(
    '',
  );

  Future<List<ClothingItem>> getClothes() async {
    final preferences = await SharedPreferences.getInstance();
    final List<String>? clothesJson = preferences.getStringList(_clothesKey);
    if (clothesJson == null) return [];
    return clothesJson
        .map((jsonStr) => ClothingItem.fromJson(jsonStr))
        .toList();
  }

  Future<void> saveCloth(ClothingItem item) async {
    final preferences = await SharedPreferences.getInstance();
    final List<String> clothesJson =
        preferences.getStringList(_clothesKey) ?? [];
    clothesJson.add(item.toJson());
    await preferences.setStringList(_clothesKey, clothesJson);
    clothesUpdateNotifier.value++;
  }

  Future<void> deleteCloth(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final List<String> clothesJson =
        preferences.getStringList(_clothesKey) ?? [];

    final updatedList = clothesJson.where((jsonStr) {
      final item = ClothingItem.fromJson(jsonStr);
      return item.id != id;
    }).toList();

    await preferences.setStringList(_clothesKey, updatedList);
    clothesUpdateNotifier.value++;
  }

  Future<void> updateCloth(ClothingItem updatedItem) async {
    final preferences = await SharedPreferences.getInstance();
    final List<String> clothesJson =
        preferences.getStringList(_clothesKey) ?? [];

    final updatedList = clothesJson.map((jsonStr) {
      final item = ClothingItem.fromJson(jsonStr);
      if (item.id == updatedItem.id) {
        return updatedItem.toJson();
      }
      return jsonStr;
    }).toList();

    await preferences.setStringList(_clothesKey, updatedList);
    clothesUpdateNotifier.value++;
  }

  Future<String?> getHomeUserName() async {
    final preferences = await SharedPreferences.getInstance();
    final savedName = preferences.getString(_homeUserNameKey);

    if (savedName == null) {
      return null;
    }

    final cleanedName = savedName.trim();
    if (cleanedName.isEmpty) {
      return null;
    }

    return cleanedName;
  }

  Future<void> setHomeUserName(String value) async {
    final cleanedName = value.trim();
    if (cleanedName.isEmpty) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_homeUserNameKey, cleanedName);
    userNameNotifier.value = cleanedName;
  }

  Future<Map<String, dynamic>?> getDailyOutfit() async {
    final preferences = await SharedPreferences.getInstance();
    final date = preferences.getString(_dailyOutfitDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (date == today) {
      final msg = preferences.getString(_dailyOutfitMsgKey);
      final items = preferences.getStringList(_dailyOutfitItemsKey);
      if (msg != null && items != null) {
        return {'message': msg, 'items': items};
      }
    }
    return null;
  }

  Future<void> saveDailyOutfit(String message, List<String> itemIds) async {
    final preferences = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await preferences.setString(_dailyOutfitDateKey, today);
    await preferences.setString(_dailyOutfitMsgKey, message);
    await preferences.setStringList(_dailyOutfitItemsKey, itemIds);
  }
}
