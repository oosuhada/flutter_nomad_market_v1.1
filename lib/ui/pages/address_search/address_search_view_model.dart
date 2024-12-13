import 'package:flutter_market_app/data/repository/vworld_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/model/address.dart';

class AddressSearchViewModel extends AutoDisposeNotifier<List<Address>> {
  @override
  List<Address> build() {
    return [];
  }

  final vworldRepository = MapboxRepository();

  void searchByName(String query) async {
    final result = await vworldRepository.findByName(query);
    state = result
        .map((e) => Address(
              id: 0,
              fullName: e,
              displayName: e.split(' ').last,
            ))
        .toList();
  }

  void searchByLocation(double lat, double lng) async {
    final result = await vworldRepository.findByLatLng(lat, lng);
    state = result
        .map((e) => Address(
              id: 0,
              fullName: e,
              displayName: e.split(' ').last,
            ))
        .toList();
  }
}

final addressSearchViewModel =
    NotifierProvider.autoDispose<AddressSearchViewModel, List<Address>>(() {
  return AddressSearchViewModel();
});
