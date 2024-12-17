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

      // 사용자 정보에서 주소 조회
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
      final homeAddress = userData['preferences']?['homeAddress'] as String?;

      if (homeAddress == null) {
        print("사용자의 주소 정보가 없음");
        return [];
      }

      print("주소 정보 찾음: $homeAddress");

      // Address 객체로 변환
      final address = Address(
          city: homeAddress.split(',')[0].trim(),
          fullName: homeAddress,
          defaultYn: true,
          id: '',
          displayNameEN: '',
          displayNameKR: '',
          state: '',
          country: '');

      return [address];
    } catch (e) {
      print("주소 목록 조회 중 에러: $e");
      return [];
    }
  }
}
