import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';

const kDefaultRingtoneUriKey = 'default_ringtone_uri';
const kDefaultRingtoneTitleKey = 'default_ringtone_title';

class RingtoneData {
  final String? uri;
  final String? title;

  const RingtoneData({this.uri, this.title});

  bool get isSet => uri != null && uri!.isNotEmpty;
}

final defaultRingtoneProvider =
    StateNotifierProvider<DefaultRingtoneNotifier, RingtoneData>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DefaultRingtoneNotifier(prefs);
});

class DefaultRingtoneNotifier extends StateNotifier<RingtoneData> {
  final SharedPreferences _prefs;

  DefaultRingtoneNotifier(this._prefs)
      : super(
          RingtoneData(
            uri: _prefs.getString(kDefaultRingtoneUriKey),
            title: _prefs.getString(kDefaultRingtoneTitleKey),
          ),
        );

  Future<void> setRingtone(String? uri, String? title) async {
    state = RingtoneData(uri: uri, title: title);
    if (uri == null || uri.isEmpty) {
      await _prefs.remove(kDefaultRingtoneUriKey);
      await _prefs.remove(kDefaultRingtoneTitleKey);
    } else {
      await _prefs.setString(kDefaultRingtoneUriKey, uri);
      if (title != null && title.isNotEmpty) {
        await _prefs.setString(kDefaultRingtoneTitleKey, title);
      } else {
        await _prefs.remove(kDefaultRingtoneTitleKey);
      }
    }
  }

  Future<void> reset() async {
    await setRingtone(null, null);
  }
}
