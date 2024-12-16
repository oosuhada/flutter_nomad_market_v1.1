import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfoRepository {
  // Firestore 인스턴스 생성
  final firestore = FirebaseFirestore.instance;
  // 이메일 중복 확인
  Future<bool> isEmailInUse(String email) async {
    try {
      final emailQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return emailQuery.docs.isNotEmpty; // true: 중복, false: 사용 가능
    } catch (e) {
      print('이메일 중복 확인 오류: $e');
      return true; // 오류 시 중복으로 간주
    }
  }

  // 닉네임 중복 확인
  Future<bool> isNicknameInUse(String nickname) async {
    try {
      final nicknameQuery = await firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .get();
      return nicknameQuery.docs.isNotEmpty; // true: 중복, false: 사용 가능
    } catch (e) {
      print('닉네임 중복 확인 오류: $e');
      return true; // 오류 시 중복으로 간주
    }
  }

  // 로그인
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        print('로그인 성공: ${querySnapshot.docs[0].data()}');
        return true;
      } else {
        print('로그인 실패: 이메일 또는 비밀번호가 잘못되었습니다.');
        return false;
      }
    } catch (e) {
      print('오류 발생: $e');
      return false;
    }
  }

  // 회원가입
  Future<bool?> join({
    required String nickname,
    required String email,
    required String password,
    required String addressFullName,
    required String profileImageUrl,
  }) async {
    try {
      // 이메일 중복 확인
      if (await isEmailInUse(email)) {
        print('회원가입 실패: 이메일이 이미 사용 중입니다.');
        return false;
      }
      // 닉네임 중복 확인
      if (await isNicknameInUse(nickname)) {
        print('회원가입 실패: 닉네임이 이미 사용 중입니다.');
        return false;
      }

      final collectionRef = firestore.collection('users');
      final docRef = collectionRef.doc();

      await docRef.set({
        'nickname': nickname,
        'email': email,
        'password': password,
        'addressFullName': addressFullName,
        'profileImageUrl': profileImageUrl,
      });
      print('회원가입 성공!');
      return true;
    } catch (e) {
      print('오류 발생: $e');
      return null;
    }
  }
}
