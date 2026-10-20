
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class LocalStore {
  static const _itemsKey = 'dayflow.items.v1';
  static const _themeKey = 'dayflow.theme.v1';

  Future<List<OrganizerItem>> loadItems() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_itemsKey);

    if (raw == null || raw.isEmpty) return [];

    try {
      return OrganizerItem.decodeList(raw);
    } on FormatException {
      // Keep the app usable if a saved value is malformed.
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> saveItems(List<OrganizerItem> items) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _itemsKey,
      OrganizerItem.encodeList(items),
    );

    if (!saved) {
      throw StateError('Unable to save organizer data.');
    }
  }

  Future<String> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_themeKey) ?? 'system';
  }

  Future<void> saveThemeMode(String value) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_themeKey, value);

    if (!saved) {
      throw StateError('Unable to save theme preference.');
    }
  }
}
