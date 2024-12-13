import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfoRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 이메일 중복 확인 메서드
  Future<bool> isEmailDuplicate(String email) async {
    final emailQuery = await firestore
        .collection('posts')
        .where('email', isEqualTo: email)
        .get();
    return emailQuery.docs.isNotEmpty;
  }

  // 닉네임 중복 확인 메서드
  Future<bool> isNicknameDuplicate(String nickname) async {
    final nicknameQuery = await firestore
        .collection('posts')
        .where('nickname', isEqualTo: nickname)
        .get();
    return nicknameQuery.docs.isNotEmpty;
  }

  // 로그인
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // Firestore 인스턴스 가져오기
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Firestore에서 `posts` 컬렉션 쿼리
      final querySnapshot = await firestore
          .collection('posts')
          .where('email', isEqualTo: email) // 이메일 필터
          .where('password', isEqualTo: password) // 비밀번호 필터
          .get();

      // 쿼리 결과가 있으면 로그인 성공
      if (querySnapshot.docs.isNotEmpty) {
        print('로그인 성공: ${querySnapshot.docs[0].data()}');
        return true;
      } else {
        // 쿼리 결과가 없으면 로그인 실패
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
      // Firestore 인스턴스 가져오기
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 이메일 중복 확인
      final emailQuery = await firestore
          .collection('posts')
          .where('email', isEqualTo: email)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        print('회원가입 실패: 이메일이 이미 사용 중입니다.');
        return false; // 이메일 중복
      }

      // 닉네임 중복 확인
      final nicknameQuery = await firestore
          .collection('posts')
          .where('nickname', isEqualTo: nickname)
          .get();

      if (nicknameQuery.docs.isNotEmpty) {
        print('회원가입 실패: 닉네임이 이미 사용 중입니다.');
        return false; // 닉네임 중복
      }

      // 중복 확인 후 데이터 저장
      final collectionRef = firestore.collection('posts');
      final docRef = collectionRef.doc(); // 자동 ID 할당
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
