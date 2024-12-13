import 'package:flutter/material.dart';
import 'locale_setting.dart';

class LanguageSetting extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelect;

  const LanguageSetting({
    Key? key,
    required this.onLanguageSelect,
    this.selectedLanguage = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> languages = [
      {'name': '한국어', 'flag': 'KR'},
      {'name': 'English', 'flag': 'US'},
      {'name': '日本語', 'flag': 'JP'},
      {'name': '中文', 'flag': 'CN'},
      {'name': 'Español', 'flag': 'ES'},
      {'name': 'Français', 'flag': 'FR'},
      {'name': 'Italiano', 'flag': 'IT'},
      {'name': 'العربية', 'flag': 'AE'},
      {'name': 'Deutsch', 'flag': 'DE'},
      {'name': 'Português', 'flag': 'PT'},
      {'name': 'Русский', 'flag': 'RU'},
    ];

    return GenericSettingPage(
      title: '언어 선택',
      items: languages,
      initialSelection: selectedLanguage,
      onSelect: onLanguageSelect,
    );
  }
}
