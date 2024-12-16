import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/address.dart';

class AddressRepository {
  final firestore = FirebaseFirestore.instance;

  Future<List<Address>?> getMyAddressList(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => Address.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching addresses: $e');
      return null;
    }
  }
}
