import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aalna/features/home/model/clothing_item.dart';

class LocalStorage {
  static const String _homeUserNameKey = 'home_user_name';
  static const String _clothesKey = 'saved_clothes';

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
  }
}
