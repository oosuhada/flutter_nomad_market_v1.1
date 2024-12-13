import 'package:dio/dio.dart';

class MapboxRepository {
  final Dio _client = Dio(BaseOptions(
    baseUrl: 'https://api.mapbox.com/geocoding/v5/mapbox.places',
    validateStatus: (status) => true,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // 공개 액세스 토큰 사용 (sk. 로 시작하는 비밀 토큰 대신)
  final String _accessToken =
      'pk.eyJ1Ijoibm9tYWRtYXJrZXQiLCJhIjoiY200bWptcndxMDBiOTJrcHJ0Nm41c3hlNSJ9.mGmhE83zkJuDsX0yaALg5w';

  Future<List<String>> findByName(String query) async {
    print('Starting findByName with query: $query');

    try {
      final response = await _client.get(
        '/$query.json',
        queryParameters: {
          'access_token': _accessToken,
          'types': 'place',
          'limit': 10,
          'language': 'ko',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final features = response.data['features'] as List?;
        print('Features length: ${features?.length}');

        if (features != null && features.isNotEmpty) {
          final results = features
              .map((feature) {
                final context = feature['context'] as List?;
                if (context != null) {
                  final place = context.firstWhere(
                    (item) => (item['id'] as String).startsWith('place'),
                    orElse: () => {'text': feature['place_name']},
                  );
                  return place['text'].toString();
                }
                return feature['place_name'].toString();
              })
              .where((name) => name.isNotEmpty)
              .toList();

          print('Final results: $results');
          return results;
        }
      }

      return [];
    } catch (e) {
      print('Error in findByName: $e');
      return [];
    }
  }

  Future<List<String>> findByLatLng(double lat, double lng) async {
    print('Starting findByLatLng with lat: $lat, lng: $lng');

    try {
      print('Attempting API call to: /$lng,$lat.json');
      final response = await _client.get(
        '/$lng,$lat.json',
        queryParameters: {
          'access_token': _accessToken,
          'types': 'place', // 단일 타입으로 변경
          'limit': 1, // limit를 1로 설정
          'language': 'ko', // 한국어 결과
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final features = response.data['features'] as List?;
        print('Features length: ${features?.length}');

        if (features != null && features.isNotEmpty) {
          final results = features
              .map((feature) {
                final context = feature['context'] as List?;
                if (context != null) {
                  // context에서 place 타입의 데이터 찾기
                  final place = context.firstWhere(
                    (item) => (item['id'] as String).startsWith('place'),
                    orElse: () => {'text': feature['place_name']},
                  );
                  return place['text'].toString();
                }
                return feature['place_name'].toString();
              })
              .where((name) => name.isNotEmpty)
              .toList();

          print('Final results: $results');
          return results;
        }
      }

      return [];
    } catch (e) {
      print('Error in findByLatLng: $e');
      return [];
    }
  }
}
