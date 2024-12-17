class Address {
  String id;
  String fullNameKR;
  String fullNameEN;
  String cityKR;
  String cityEN;
  String countryKR;
  String countryEN;
  bool? defaultYn;
  bool isServiceAvailable;

  Address({
    required this.id,
    required this.fullNameKR,
    required this.fullNameEN,
    required this.cityKR,
    required this.cityEN,
    required this.countryKR,
    required this.countryEN,
    this.defaultYn,
    required this.isServiceAvailable,
  });

  // Available service areas
  static final List<Map<String, String>> serviceableAreas = [
    {
      'cityKR': '서울',
      'countryKR': '대한민국',
      'cityEN': 'Seoul',
      'countryEN': 'USA',
      'flag': 'KR'
    },
    {
      'cityKR': '뉴욕',
      'countryKR': '미국',
      'cityEN': 'New York',
      'countryEN': 'USA',
      'flag': 'US'
    },
    {
      'cityKR': '파리',
      'countryKR': '프랑스',
      'cityEN': 'Paris',
      'countryEN': 'France',
      'flag': 'FR'
    },
    {
      'cityKR': '도쿄',
      'countryKR': '일본',
      'cityEN': 'Tokyo',
      'countryEN': 'Japan',
      'flag': 'JP'
    },
    {
      'cityKR': '런던',
      'countryKR': '영국',
      'cityEN': 'London',
      'countryEN': 'UK',
      'flag': 'GB'
    },
    {
      'cityKR': '바르셀로나',
      'countryKR': '스페인',
      'cityEN': 'Barcelona',
      'countryEN': 'Spain',
      'flag': 'ES'
    },
    {
      'cityKR': '밀라노',
      'countryKR': '이탈리아',
      'cityEN': 'Milan',
      'countryEN': 'Italy',
      'flag': 'IT'
    },
    {
      'cityKR': '이스탄불',
      'countryKR': '터키',
      'cityEN': 'Istanbul',
      'countryEN': 'Turkey',
      'flag': 'TR'
    },
    {
      'cityKR': '암스테르담',
      'countryKR': '네덜란드',
      'cityEN': 'Amsterdam',
      'countryEN': 'Netherlands',
      'flag': 'NL'
    },
    {
      'cityKR': '프랑크푸르트',
      'countryKR': '독일',
      'cityEN': 'Frankfurt',
      'countryEN': 'Germany',
      'flag': 'DE'
    },
  ];

  static bool checkServiceAvailability(String fullCity, String country) {
    // 도시명에서 '시', '특별시', '광역시' 등의 접미사를 제거하고 비교
    String normalizedCity = fullCity
        .replaceAll('특별시', '')
        .replaceAll('광역시', '')
        .replaceAll('시', '')
        .trim();

    return serviceableAreas.any((area) =>
        area['cityKR']?.contains(normalizedCity) == true &&
        area['countryKR'] == country);
  }

  // 위치 정보 정제를 위한 유틸리티 메서드
  static Map<String, String> processLocationInfo(
      String cityWithState, String country,
      {bool isKorean = true}) {
    String city = cityWithState.split(',')[0].trim();

    // 한국 도시의 경우 '시' 접미사 처리
    if (isKorean) {
      city = city.replaceAll('특별시', '').replaceAll('광역시', '').trim();
      if (!city.endsWith('시')) {
        city = city.replaceAll('시', '').trim();
      }
    }

    return {'city': city, 'country': country.trim()};
  }

  String getDisplayName(String locale) {
    return locale.startsWith('ko') ? fullNameKR : fullNameEN;
  }

  // JSON 데이터에서 Address 객체 생성
  Address.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        fullNameKR = json['fullNameKR'] ?? '',
        fullNameEN = json['fullNameEN'] ?? '',
        cityKR = json['cityKR'] ?? '',
        cityEN = json['cityEN'] ?? '',
        countryKR = json['countryKR'] ?? '',
        countryEN = json['countryEN'] ?? '',
        defaultYn = json['defaultYn'] ?? false,
        isServiceAvailable = json['isServiceAvailable'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullNameKR': fullNameKR,
      'fullNameEN': fullNameEN,
      'cityKR': cityKR,
      'cityEN': cityEN,
      'countryKR': countryKR,
      'countryEN': countryEN,
      'defaultYn': defaultYn,
      'isServiceAvailable': isServiceAvailable,
    };
  }

  @override
  String toString() {
    return 'Address(id: $id, fullNameKR: $fullNameKR, fullNameEN: $fullNameEN, cityKR: $cityKR, cityEN: $cityEN, isServiceAvailable: $isServiceAvailable)';
  }

  Address copyWith({
    String? id,
    String? fullNameKR,
    String? fullNameEN,
    String? cityKR,
    String? cityEN,
    String? countryKR,
    String? countryEN,
    bool? defaultYn,
    bool? isServiceAvailable,
  }) {
    return Address(
      id: id ?? this.id,
      fullNameKR: fullNameKR ?? this.fullNameKR,
      fullNameEN: fullNameEN ?? this.fullNameEN,
      cityKR: cityKR ?? this.cityKR,
      cityEN: cityEN ?? this.cityEN,
      countryKR: countryKR ?? this.countryKR,
      countryEN: countryEN ?? this.countryEN,
      defaultYn: defaultYn ?? this.defaultYn,
      isServiceAvailable: isServiceAvailable ?? this.isServiceAvailable,
    );
  }
}
