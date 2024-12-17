import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/address.dart';

class AddressRepository {
  final firestore = FirebaseFirestore.instance;

  Future<List<Address>?> getMyAddressByID(String userId) async {
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

  Future<List<Address>> getMyAddressByEmail(String email) async {
    try {
      print("===== 사용자 주소 목록 조회 시작 =====");
      print("조회 대상 이메일: $email");

      final userDoc = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) {
        print("사용자 정보를 찾을 수 없음");
        return [];
      }

      final userData = userDoc.docs.first.data();
      final homeAddress =
          userData['preferences']?['homeAddress'] as Map<String, dynamic>?;

      if (homeAddress == null) {
        print("사용자의 주소 정보가 없음");
        return [];
      }

      print("주소 정보 찾음: $homeAddress");

      final address = Address(
        id: '',
        fullNameKR: homeAddress['fullNameKR'],
        fullNameEN: homeAddress['fullNameEN'],
        cityKR: homeAddress['cityKR'],
        cityEN: homeAddress['cityEN'],
        countryKR: homeAddress['countryKR'],
        countryEN: homeAddress['countryEN'],
        defaultYn: true,
        isServiceAvailable: Address.checkServiceAvailability(
          homeAddress['cityKR'],
          homeAddress['countryKR'],
        ),
      );

      return [address];
    } catch (e) {
      print("주소 목록 조회 중 에러: $e");
      return [];
    }
  }
}
