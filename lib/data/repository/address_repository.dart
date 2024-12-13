import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/repository/base_remote_repository.dart';

class AddressRepository extends BaseRemoteRepository {
  Future<List<Address>?> getMyAddressList() async {
    final response = await client.get('/api/address');
    if (response.statusCode == 200) {
      final content = response.data['content'];
      return List<Address>.from(content.map((e) => Address.fromJson(e)));
    }
    return null;
  }
}
