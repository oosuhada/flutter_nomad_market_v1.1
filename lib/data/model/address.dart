// [
//     {
//       "id": 1,
//       "fullName": "부산광역시 동래구 온천동",
//       "displayName": "온천동",
//       "defaultYn": true
//     }
//   ]

class Address {
  int id;
  String fullName;
  String displayName;
  bool? defaultYn;

  Address({
    required this.id,
    required this.fullName,
    required this.displayName,
    required this.defaultYn,
  });

  Address.fromJson(Map<String, dynamic> map)
      : this(
          id: map['id'],
          fullName: map['fullName'],
          displayName: map['displayName'],
          defaultYn: map['defaultYn'],
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'displayName': displayName,
      'defaultYn': defaultYn,
    };
  }
}
