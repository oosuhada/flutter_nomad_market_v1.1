import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/repository/mapbox_repository.dart';
import 'package:flutter_market_app/data/repository/address_search_repository.dart';

class AddressSearchViewModel extends AutoDisposeNotifier<List<Address>> {
  @override
  List<Address> build() {
    return [];
  }

  final addressSearchRepository = AddressSearchRepository();
  final mapboxRepository = MapboxRepository();

  // 선택된 위치 저장 변수
  LatLng? _selectedLocation;

  // 선택된 위치 가져오기
  LatLng? get selectedLocation => _selectedLocation;

  // 선택된 위치 설정
  void setSelectedLocation(double lat, double lng) {
    _selectedLocation = LatLng(lat, lng);

    // 상태 변경을 위해 state를 직접 업데이트
    // 선택된 위치를 기반으로 하는 데이터가 있으면 state를 변경
    state = [...state]; // 새로운 상태로 트리거
  }

  Future<List<Address>> searchByName(String query, BuildContext context) async {
    try {
      List<Address> result =
          await addressSearchRepository.findByName(query, context);
      if (result.isEmpty) {
        print('검색 결과가 없습니다.');
      }
      state = result;
      return result;
    } catch (e) {
      print('검색 중 오류 발생: $e');
      state = [];
      return [];
    }
  }

  void searchByLocation(double lat, double lng) async {
    try {
      final result = await mapboxRepository.findByLatLng(lat, lng);
      if (result.isEmpty) {
        print('위치에 대한 결과가 없습니다.');
      }
      state = result;
    } catch (e) {
      print('위치 검색 중 오류 발생: $e');
      state = [];
    }
  }
}

// LatLng 모델 추가
class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

final addressSearchViewModel =
    NotifierProvider.autoDispose<AddressSearchViewModel, List<Address>>(() {
  return AddressSearchViewModel();
});
