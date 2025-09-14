import 'package:flutter/material.dart';
import 'package:myapp/data/appPrefrance.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en' );

  Locale get locale => _locale;

  Future<void> loadLocale() async {
    final code = await AppPreferences.getLanguageCode();
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) {
    _locale = locale;
    AppPreferences.saveLanguageCode(locale.languageCode);
    notifyListeners();
  }
}
