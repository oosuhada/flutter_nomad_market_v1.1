import 'package:flutter_market_app/data/repository/address_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AddressRepository : getMyAddress test', () async {
    final addressRepository = AddressRepository();
    final userRepository = UserRepository();
    // 로그인 안했을 때! => null 리턴
    final addressList1 = await addressRepository.getMyAddressList();
    expect(addressList1 == null, true);

    // 로그인 했을 때 => null이 아니고, 리스트가 비어있지 않음
    await userRepository.login(username: 'tester', password: '1111');

    final addressList2 = await addressRepository.getMyAddressList();
    expect(addressList2 == null, false);
    expect(addressList2!.isNotEmpty, true);
    print(addressList2.first.toJson());
  });
}
