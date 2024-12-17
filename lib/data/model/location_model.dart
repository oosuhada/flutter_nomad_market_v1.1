class LocationModel {
  final String address; // 주소 문자열
  final double? latitude; // 위도 (옵션)
  final double? longitude; // 경도 (옵션)

  LocationModel({
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
