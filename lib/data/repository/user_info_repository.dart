import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfoRepository {
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

  //회원가입
  Future<bool?> join({
    required String nickname,
    required String email,
    required String password,
    required String addressFullName,
    required String profileImageUrl,
  }) async {
    try {
      // 1) Firestore 인스턴스 가져오기
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // 2) 컬렉션 참조 가져오기
      final collectionRef = firestore.collection('posts');
      // 3) 새 문서 참조 생성 (자동 ID 할당)
      final docRef = collectionRef.doc();
      // 4) 데이터 저장
      await docRef.set({
        'nickname': nickname,
        'email': email,
        'password': password,
        'addressFullName': addressFullName,
        'profileImageUrl': profileImageUrl,
      });

      // 생성된 문서의 ID 반환
      return true;
      ;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
