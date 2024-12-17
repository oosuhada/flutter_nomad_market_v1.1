import 'package:dio/dio.dart';
import 'package:flutter_market_app/data/model/address.dart';

class MapboxRepository {
  final Dio _client = Dio(BaseOptions(
    baseUrl: 'https://api.mapbox.com/geocoding/v5/mapbox.places',
    validateStatus: (status) => true,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  final String _accessToken =
      'pk.eyJ1Ijoibm9tYWRtYXJrZXQiLCJhIjoiY200bWptcndxMDBiOTJrcHJ0Nm41c3hlNSJ9.mGmhE83zkJuDsX0yaALg5w';

  Future<List<Address>> findByLatLng(double lat, double lng) async {
    print('Starting findByLatLng with lat: $lat, lng: $lng');
    try {
      final responseKR = await _getResponseByLatLng('$lng,$lat', 'ko');
      final responseEN = await _getResponseByLatLng('$lng,$lat', 'en');

      if (responseKR.statusCode == 200 && responseEN.statusCode == 200) {
        final featuresKR = responseKR.data['features'] as List?;
        final featuresEN = responseEN.data['features'] as List?;

        if (featuresKR != null &&
            featuresKR.isNotEmpty &&
            featuresEN != null &&
            featuresEN.isNotEmpty) {
          return _processFeaturesByLatLng(featuresKR, featuresEN);
        }
      }

      print('위치에 대한 결과가 없습니다.');
      return [];
    } catch (e) {
      print('Error in findByLatLng: $e');
      return [];
    }
  }

  Future<Response> _getResponseByLatLng(String query, String language) async {
    try {
      return await _client.get(
        '/$query.json',
        queryParameters: {
          'access_token': _accessToken,
          'language': language,
          'types': 'place', // city level results
        },
      );
    } catch (e) {
      print('Error in _getResponseByLatLng: $e');
      rethrow;
    }
  }

  List<Address> _processFeaturesByLatLng(List featuresKR, List featuresEN) {
    if (featuresKR.isEmpty || featuresEN.isEmpty) {
      return [];
    }

    final featureKR = featuresKR[0];
    final featureEN = featuresEN[0];

    // Mapbox 응답에서 context 정보 추출
    final contextKR = featureKR['context'] ?? [];
    final contextEN = featureEN['context'] ?? [];

    // 도시, 국가 정보 추출
    String cityKR = featureKR['text'] ?? '';
    String cityEN = featureEN['text'] ?? '';
    String countryKR = '';
    String countryEN = '';

    // context에서 국가 정보 찾기
    for (var ctx in contextKR) {
      if (ctx['id']?.startsWith('country.') ?? false) {
        countryKR = ctx['text'] ?? '';
        break;
      }
    }
    for (var ctx in contextEN) {
      if (ctx['id']?.startsWith('country.') ?? false) {
        countryEN = ctx['text'] ?? '';
        break;
      }
    }

    // 전체 주소 문자열 생성
    final fullNameKR = '$cityKR, $countryKR';
    final fullNameEN = '$cityEN, $countryEN';

    // 서비스 가능 여부 확인
    bool isServiceAvailable =
        Address.checkServiceAvailability(cityKR, countryKR);

    print('Processed location - KR: $fullNameKR, EN: $fullNameEN');

    return [
      Address(
        id: '',
        fullNameKR: fullNameKR,
        fullNameEN: fullNameEN,
        cityKR: cityKR,
        cityEN: cityEN,
        countryKR: countryKR,
        countryEN: countryEN,
        defaultYn: true,
        isServiceAvailable: isServiceAvailable,
      )
    ];
  }
}
