import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/ui/pages/join/join_page.dart';

class CurrencySearchPage extends ConsumerStatefulWidget {
  final String selectedLanguage;
  final String selectedAddress;

  const CurrencySearchPage({
    Key? key,
    required this.selectedLanguage,
    required this.selectedAddress,
  }) : super(key: key);

  @override
  _CurrencySearchPageState createState() => _CurrencySearchPageState();
}

class _CurrencySearchPageState extends ConsumerState<CurrencySearchPage> {
  final List<Map<String, String>> allCurrencies = [
    {
      'name': 'KRW (₩)',
      'flag': '🇰🇷',
      'labels': 'Korean Won,KR,Won,원,한국,대한민국'
    },
    {'name': 'USD (\$)', 'flag': '🇺🇸', 'labels': 'US Dollar,US,Dollar,달러,미국'},
    {'name': 'EUR (€)', 'flag': '🇪🇺', 'labels': 'Euro,EU,유로,유럽연합'},
    {'name': 'JPY (¥)', 'flag': '🇯🇵', 'labels': 'Japanese Yen,JP,Yen,엔,일본'},
    {
      'name': 'GBP (£)',
      'flag': '🇬🇧',
      'labels': 'British Pound,GB,Pound,파운드,영국'
    },
    {'name': 'CNY (¥)', 'flag': '🇨🇳', 'labels': 'Chinese Yuan,CN,Yuan,위안,중국'},
    {
      'name': 'AUD (\$)',
      'flag': '🇦🇺',
      'labels': 'Australian Dollar,AU,호주 달러,호주'
    },
    {
      'name': 'CAD (\$)',
      'flag': '🇨🇦',
      'labels': 'Canadian Dollar,CA,캐나다 달러,캐나다'
    }
  ];

  List<Map<String, String>> displayedCurrencies = [];

  @override
  void initState() {
    super.initState();
    displayedCurrencies = List.from(allCurrencies);
  }

  void filterCurrencies(String query) {
    setState(() {
      displayedCurrencies = allCurrencies
          .where((currency) =>
              (currency['name'] ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (currency['labels'] ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('통화 선택')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '통화 검색',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
                onChanged: filterCurrencies,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: displayedCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = displayedCurrencies[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.only(left: 20.0),
                    leading: Text(
                      currency['flag'] ?? '',
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      currency['name'] ?? '',
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JoinPage(
                            language: widget.selectedLanguage,
                            address: widget.selectedAddress,
                            currency: (currency['name'] ?? '').toString(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
