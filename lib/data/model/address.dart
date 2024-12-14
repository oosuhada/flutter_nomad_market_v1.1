class Address {
  int id;
  String fullName;

  String displayNameEN;
  String displayNameKR;
  String city;
  final String state;
  final String country;
  bool? defaultYn;

  Address({
    required this.id,
    required this.fullName,
    required this.displayNameEN,
    required this.displayNameKR,
    required this.city,
    required this.state,
    required this.country,
    this.defaultYn,
  });

  String get displayName {
    if (country == "대한민국") {
      if (state == "서울특별시") {
        return "$state, $country";
      } else {
        return "$city, $state, $country";
      }
    } else {
      return "$city, $state, $country".replaceAll(RegExp(r', $'), '');
    }
  }

  // JSON 데이터에서 Address 객체 생성
  Address.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        fullName = json['fullName'] ?? '',
        displayNameEN = json['displayNameEN'] ?? '',
        displayNameKR = json['displayNameKR'] ?? '',
        city = json['city'] ?? '',
        state = json['state'] ?? '',
        country = json['country'] ?? '',
        defaultYn = json['defaultYn'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'displayNameEN': displayNameEN,
      'displayNameKR': displayNameKR,
      'city': city,
      'state': state,
      'country': country,
      'defaultYn': defaultYn,
    };
  }

  @override
  String toString() {
    return 'Address(id: $id, fullName: $fullName, displayNameKR: $displayNameKR, displayNameEN: $displayNameEN, city: $city, defaultYn: $defaultYn)';
  }

  Address copyWith({bool? defaultYn}) {
    return Address(
      id: this.id,
      fullName: this.fullName,
      displayNameEN: this.displayNameEN,
      displayNameKR: this.displayNameKR,
      city: this.city,
      state: this.state,
      country: this.country,
      // Use the existing defaultYn value if not provided in the new copy.
      defaultYn: defaultYn ?? this.defaultYn,
    );
  }
}
