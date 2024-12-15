import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/product_summary.dart';
import 'package:flutter_market_app/data/repository/address_repository.dart';
import 'package:flutter_market_app/data/repository/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTabState {
  List<Address> addresses;
  List<ProductSummary> products;

  HomeTabState({
    required this.addresses,
    required this.products,
  });
}

class HomeTabViewModel extends AutoDisposeNotifier<HomeTabState> {
  @override
  HomeTabState build() {
    fetchAddresses().then((_) {
      fetchProducts();
    });

    return HomeTabState(
      addresses: [],
      products: [],
    );
  }

  final addressRepository = AddressRepository();
  final productRepository = ProductRepository();

  // 내 동네 리스트 가져오기
  Future<void> fetchAddresses() async {
    final addresses = await addressRepository.getMyAddressList();
    state = HomeTabState(
      addresses: addresses ?? [],
      products: [],
    );
  }

  // updateDefaultAddress: city 값으로 기본 주소 업데이트
  Future<void> updateDefaultAddress(String cityName) async {
    // 모든 주소의 defaultYn을 false로 초기화
    final updatedAddresses = state.addresses.map((address) {
      return address.copyWith(defaultYn: false);
    }).toList();

    // city 값을 기반으로 새로운 기본 주소 찾기
    final index =
        updatedAddresses.indexWhere((address) => address.city == cityName);

    if (index != -1) {
      updatedAddresses[index] =
          updatedAddresses[index].copyWith(defaultYn: true);
    } else {
      print('해당 도시를 찾을 수 없습니다: $cityName');
    }

    // 상태 업데이트
    state = HomeTabState(
      addresses: updatedAddresses,
      products: state.products,
    );

    // 새 기본 주소에 따른 상품 목록 업데이트
    await fetchProducts();
  }

  // 상품 목록 불러오기
  Future<void> fetchProducts() async {
    final addresses = state.addresses;
    final target = addresses.where((e) => e.defaultYn ?? false).toList();
    if (target.isEmpty) {
      return;
    }
    final products =
        await productRepository.getProductSummaryList(target.first.id);
    state = HomeTabState(
      addresses: addresses,
      products: products ?? [],
    );
  }
}

final homeTabViewModel =
    NotifierProvider.autoDispose<HomeTabViewModel, HomeTabState>(() {
  return HomeTabViewModel();
});
