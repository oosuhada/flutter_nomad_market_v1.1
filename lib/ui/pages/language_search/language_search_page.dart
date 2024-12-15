import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/ui/pages/address_search/address_search_page.dart';

class LanguageSearchPage extends ConsumerStatefulWidget {
  const LanguageSearchPage({Key? key}) : super(key: key);

  @override
  _LanguageSearchPageState createState() => _LanguageSearchPageState();
}

class _LanguageSearchPageState extends ConsumerState<LanguageSearchPage> {
  final List<Map<String, String>> allLanguages = [
    {'name': '한국어', 'flag': '🇰🇷', 'english': 'Korean'},
    {'name': 'English', 'flag': '🇺🇸', 'english': 'English'},
    {'name': '日本語', 'flag': '🇯🇵', 'english': 'Japanese'},
    {'name': '中文', 'flag': '🇨🇳', 'english': 'Chinese'},
    {'name': 'Español', 'flag': '🇪🇸', 'english': 'Spanish'},
    {'name': 'Français', 'flag': '🇫🇷', 'english': 'French'},
    {'name': 'Italiano', 'flag': '🇮🇹', 'english': 'Italian'},
    {'name': 'العربية', 'flag': '🇦🇪', 'english': 'Arabic'},
    {'name': 'Deutsch', 'flag': '🇩🇪', 'english': 'German'},
    {'name': 'Português', 'flag': '🇵🇹', 'english': 'Portuguese'},
    {'name': 'Русский', 'flag': '🇷🇺', 'english': 'Russian'},
  ];

  List<Map<String, String>> displayedLanguages = [];

  @override
  void initState() {
    super.initState();
    displayedLanguages = List.from(allLanguages);
  }

  void filterLanguages(String query) {
    setState(() {
      displayedLanguages = allLanguages
          .where((language) =>
              language['name']!
                  .toLowerCase()
                  .contains(query.toLowerCase()) || // 이름 필드 검색
              language['english']!
                  .toLowerCase()
                  .contains(query.toLowerCase())) // 영어 이름 필드 검색
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('언어 선택')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // 좌우 여백 추가
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '언어 검색',
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
                onChanged: filterLanguages,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: displayedLanguages.length,
                itemBuilder: (context, index) {
                  final language = displayedLanguages[index];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.only(left: 20.0), // 왼쪽 여백 추가
                    leading: Text(
                      language['flag'] ?? '',
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // 텍스트가 같은 높이에 위치하도록 설정
                      children: [
                        Flexible(
                          child: Text(
                            language['name'] ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8), // 텍스트 간 간격 추가
                        Text(
                          language['english'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressSearchPage(
                            selectedLanguage: language['name'] ?? '',
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
