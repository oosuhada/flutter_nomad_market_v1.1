import 'package:flutter_market_app/data/repository/address_repository.dart';
import 'package:flutter_market_app/data/repository/product_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //
  final userRepository = UserRepository();
  final productRepository = ProductRepository();

  test('ProductRepository : getProductSummaryList test', () async {
    final result1 = await productRepository.getProductSummaryList(1);
    expect(result1, null);

    final addressRepository = AddressRepository();

    await userRepository.login(username: 'tester', password: '1111');

    final addresses = await addressRepository.getMyAddressList();
    final result2 =
        await productRepository.getProductSummaryList(addresses!.first.id);

    expect(result2 != null, true);
    for (var v in result2!) {
      print(v.toJson());
    }
  });

  test('ProductRepository : fetchDetail test', () async {
    // 1
    await userRepository.login(username: 'tester', password: '1111');
    final product = await productRepository.fetchDetail(1);
    expect(product == null, false);
    print(product?.toJson());
  });
}
