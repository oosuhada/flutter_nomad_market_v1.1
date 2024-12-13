import 'package:flutter/material.dart';
import 'locale_setting.dart';

class CitySelection extends StatelessWidget {
  final String selectedCity;
  final Function(String) onCitySelect;

  const CitySelection({
    Key? key,
    required this.onCitySelect,
    this.selectedCity = '',
  }) : super(key: key);

  static List<Map<String, dynamic>> getCities() {
    return [
      {'name': '서울, 대한민국', 'flag': 'KR'},
      {'name': '뉴욕, 미국', 'flag': 'US'},
      {'name': '파리, 프랑스', 'flag': 'FR'},
      {'name': '도쿄, 일본', 'flag': 'JP'},
      {'name': '런던, 영국', 'flag': 'GB'},
      {'name': '바르셀로나, 스페인', 'flag': 'ES'},
      {'name': '밀라노, 이탈리아', 'flag': 'IT'},
      {'name': '이스탄불, 터키', 'flag': 'TR'},
      {'name': '암스테르담, 네덜란드', 'flag': 'NL'},
      {'name': '프랑크푸르트, 독일', 'flag': 'DE'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GenericSettingPage(
      title: '도시 선택',
      items: getCities(),
      initialSelection: selectedCity,
      onSelect: onCitySelect,
    );
  }
}
