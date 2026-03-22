import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _homeUserNameKey = 'home_user_name';

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
