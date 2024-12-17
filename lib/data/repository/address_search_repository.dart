// address_search_repository.dart
import 'package:flutter/material.dart';
import 'package:flutter_market_app/data/model/address.dart'; // Address 모델 재사용

class AddressSearchRepository {
  Future<Address> searchByName(BuildContext context,
      {required String cityWithState,
      required String country,
      String? cityWithStateEN,
      String? countryEN}) async {
    // 한글 주소 정보 정제
    final krLocation =
        Address.processLocationInfo(cityWithState, country, isKorean: true);

    // 영문 주소 정보 정제
    final enLocation = cityWithStateEN != null && countryEN != null
        ? Address.processLocationInfo(cityWithStateEN, countryEN,
            isKorean: false)
        : {'city': '', 'country': ''};

    // 서비스 가능 여부 확인
    bool isServiceAvailable = Address.checkServiceAvailability(
        cityWithState, // '서울특별시'와 같은 원본 도시명 사용
        krLocation['country']!);

    return Address(
      id: '',
      fullNameKR: '${cityWithState}, ${krLocation['country']}', // 원본 도시명 사용
      fullNameEN: enLocation['city']!.isNotEmpty
          ? '${enLocation['city']}, ${enLocation['country']}'
          : '',
      cityKR: cityWithState, // 원본 도시명 사용
      cityEN: enLocation['city']!,
      countryKR: krLocation['country']!,
      countryEN: enLocation['country']!,
      isServiceAvailable: isServiceAvailable,
    );
  }
}
