import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencySearchViewModel extends StateNotifier<List<String>> {
  CurrencySearchViewModel() : super([]);

  final List<String> allCurrencies = ['USD', 'KRW', 'JPY', 'CNY'];

  void searchCurrency(String query) {
    state = allCurrencies
        .where(
            (currency) => currency.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void selectCurrency(String currency) {
    // 선택된 통화 처리 로직
    print('선택된 통화: $currency');
  }
}

final currencySearchViewModel =
    StateNotifierProvider<CurrencySearchViewModel, List<String>>(
  (ref) => CurrencySearchViewModel(),
);
