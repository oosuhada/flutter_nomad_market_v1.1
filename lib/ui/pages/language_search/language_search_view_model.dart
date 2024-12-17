import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageSearchViewModel extends StateNotifier<List<Map<String, String>>> {
  LanguageSearchViewModel() : super(_allLanguages);

  static final List<Map<String, String>> _allLanguages = [
    {'name': '한국어', 'flag': '🇰🇷'},
    {'name': 'English', 'flag': '🇺🇸'},
    {'name': '日本語', 'flag': '🇯🇵'},
    {'name': '中文', 'flag': '🇨🇳'},
    {'name': 'Español', 'flag': '🇪🇸'},
    {'name': 'Français', 'flag': '🇫🇷'},
    {'name': 'Italiano', 'flag': '🇮🇹'},
    {'name': 'العربية', 'flag': '🇦🇪'},
    {'name': 'Deutsch', 'flag': '🇩🇪'},
    {'name': 'Português', 'flag': '🇵🇹'},
    {'name': 'Русский', 'flag': '🇷🇺'},
  ];

  void searchLanguage(String query) {
    state = _allLanguages
        .where((language) =>
            language['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void selectLanguage(Map<String, String> language) {
    print('선택된 언어: ${language['name']}');
  }
}

final languageSearchViewModel =
    StateNotifierProvider<LanguageSearchViewModel, List<Map<String, String>>>(
  (ref) => LanguageSearchViewModel(),
);
