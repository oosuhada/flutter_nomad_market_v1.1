// address_search_repository.dart
import 'package:flutter/material.dart';
import 'package:flutter_market_app/data/model/address.dart'; // Address 모델 재사용

class AddressSearchRepository {
  Future<List<Address>> findByName(String query, BuildContext context) async {
    Address? selectedAddress =
        await findByCountrySelection(context); // context를 전달
    return selectedAddress != null ? [selectedAddress] : [];
  }

  // CountryPickerPlus의 선택 콜백에서 Country 객체가 아닌 단순 문자열로 반환될 수 있음
  Future<Address?> findByCountrySelection(BuildContext context) async {
    String? selectedCountry = '';

    if (selectedCountry != null && selectedCountry.isNotEmpty) {
      return Address(
        id: '',
        fullName: '',
        displayNameEN: '',
        displayNameKR: '',
        state: '',
        country: selectedCountry,
        city: '',
      );
    }
  }
}
