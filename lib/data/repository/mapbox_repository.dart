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

//
//

  // findByLatLng related functions

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

    final fullNameKR = _buildFullAddressByLatLng(featureKR);
    final fullNameEN = _buildFullAddressByLatLng(featureEN, isEnglish: true);

    return [
      Address(
        id: '',
        fullName: fullNameKR,
        displayNameEN: fullNameEN,
        displayNameKR: fullNameKR,
        city: _extractCityByLatLng(featureKR),
        state: '',
        country: '',
        defaultYn: true,
      )
    ];
  }

  String _buildFullAddressByLatLng(Map<String, dynamic> feature,
      {bool isEnglish = false}) {
    final List<String> addressParts = [];
    final context = feature['context'] as List?;
    final languageSuffix = isEnglish ? 'en' : 'ko';

    String? cityName;
    String? regionName;
    String countryName = isEnglish ? 'South Korea' : '대한민국';

    if (context != null) {
      for (var item in context) {
        final itemId = item['id'].toString();
        final itemText = item['text_$languageSuffix'] ?? item['text'];

        if (itemId.startsWith('place') && cityName == null) {
          cityName = itemText;
        } else if (itemId.startsWith('region') && regionName == null) {
          regionName = itemText;
        }
      }
    }

    if (cityName != null) {
      addressParts.add(cityName);
    }

    if (regionName != null && regionName != cityName) {
      addressParts.add(regionName);
    }

    addressParts.add(countryName);

    return addressParts.join(', ');
  }

  String _extractCityByLatLng(Map<String, dynamic> feature) {
    final context = feature['context'] as List?;
    if (context != null) {
      for (var item in context) {
        if (item['id'].startsWith('place')) {
          return item['text_ko'] ?? item['text'];
        }
      }
    }
    return feature['text_ko'] ?? feature['text'];
  }
}
