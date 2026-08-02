import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _values = {
    'ar': {
      'appTitle': 'AI Core OS',
      'dashboard': 'الرئيسية',
      'memory': 'الذاكرة',
      'chat': 'الشات',
      'knowledge': 'المعرفة',
      'decisions': 'القرارات',
      'system': 'النظام',
      'search': 'بحث',
      'goodEvening': 'مساء الخير',
      'activeMemories': 'الذكريات النشطة',
    },
    'en': {
      'appTitle': 'AI Core OS',
      'dashboard': 'Dashboard',
      'memory': 'Memory',
      'chat': 'Chat',
      'knowledge': 'Knowledge',
      'decisions': 'Decisions',
      'system': 'System',
      'search': 'Search',
      'goodEvening': 'Good Evening',
      'activeMemories': 'Active Memories',
    }
  };

  String translate(String key) => _values[locale.languageCode]?[key] ?? _values['ar']?[key] ?? key;
  String get dashboard => translate('dashboard');
  String get memory => translate('memory');
  String get chat => translate('chat');
  String get knowledge => translate('knowledge');
  String get decisions => translate('decisions');
  String get system => translate('system');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);
  @override Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar', 'EG');
  Locale get locale => _locale;
  void setLocale(Locale l) { _locale = l; notifyListeners(); }
  void toggle() { _locale = _locale.languageCode == 'ar' ? const Locale('en', 'US') : const Locale('ar', 'EG'); notifyListeners(); }
}
