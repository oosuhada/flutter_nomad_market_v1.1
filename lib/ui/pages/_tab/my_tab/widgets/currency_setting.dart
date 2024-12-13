import 'package:flutter/material.dart';
import 'locale_setting.dart';

class CurrencySetting extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onCurrencySelect;

  const CurrencySetting({
    Key? key,
    required this.onCurrencySelect,
    this.selectedCurrency = '',
  }) : super(key: key);

  static List<Map<String, dynamic>> getCurrency() {
    return [
      {'name': 'KRW (₩)', 'flag': 'KR'},
      {'name': 'USD (\$)', 'flag': 'US'},
      {'name': 'EUR (€)', 'flag': 'EU'},
      {'name': 'JPY (¥)', 'flag': 'JP'},
      {'name': 'GBP (£)', 'flag': 'GB'},
      {'name': 'CNY (¥)', 'flag': 'CN'},
      {'name': 'AUD (\$)', 'flag': 'AU'},
      {'name': 'CAD (\$)', 'flag': 'CA'}
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GenericSettingPage(
      title: '선호 통화 선택',
      items: getCurrency(),
      initialSelection: selectedCurrency,
      onSelect: onCurrencySelect,
    );
  }
}
