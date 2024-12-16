import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_market_app/data/model/user.dart';

class UserRepository {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // 이메일/비밀번호로 로그인
  Future<bool> login({
    required String email,
    required String password,
    String signInMethod = 'email',
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('로그인 실패: $e');
      return false;
    }
  }

  // 현재 로그인한 사용자 정보 조회
  Future<User?> myInfo() async {
    try {
      if (currentUserId == null) return null;

      final doc = await _firestore.collection('users').doc(currentUserId).get();
      if (!doc.exists) return null;

      return User.fromJson(doc.data()!);
    } catch (e) {
      print('사용자 정보 조회 실패: $e');
      return null;
    }
  }

  // 이메일 중복 확인
  Future<bool> isEmailAvailable(String email) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return result.docs.isEmpty; // true면 사용 가능
    } catch (e) {
      print('이메일 중복 확인 실패: $e');
      return false;
    }
  }

  // 닉네임 중복 확인
  Future<bool> isNicknameAvailable(String nickname) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .get();
      return result.docs.isEmpty; // true면 사용 가능
    } catch (e) {
      print('닉네임 중복 확인 실패: $e');
      return false;
    }
  }

  // ID로 사용자 정보 조회
  Future<User?> getUserById(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return User.fromJson(docSnapshot.data()!);
      }
    } catch (e) {
      print('사용자 정보 조회 실패: $e');
    }
    return null;
  }

  // 회원가입
  Future<bool> join({
    required String email,
    required String nickname,
    required String password,
    required String addressFullName,
    required String profileImageUrl,
    required String language,
    required String currency,
  }) async {
    try {
      // 중복 확인
      if (!await isEmailAvailable(email)) {
        print('회원가입 실패: 이메일이 이미 사용 중입니다.');
        return false;
      }
      if (!await isNicknameAvailable(nickname)) {
        print('회원가입 실패: 닉네임이 이미 사용 중입니다.');
        return false;
      }

      // Firebase Auth에 사용자 생성
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return false;

      // Firestore에 사용자 정보 저장
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'userId': credential.user!.uid,
        'email': email,
        'nickname': nickname,
        'profileImageUrl': profileImageUrl,
        'preferences': {
          'language': language.split(' ')[0].toLowerCase(),
          'currency': currency.split(' ')[0],
          'homeAddress': addressFullName,
        },
        'signInMethod': 'email',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      return true;
    } catch (e) {
      print('회원가입 실패: $e');
      return false;
    }
  }

  // 프로필 업데이트
  Future<bool> updateProfile({
    required String userId,
    required String nickname,
    String? profileImageUrl,
  }) async {
    try {
      // 닉네임 중복 확인 (현재 사용자 제외)
      final nicknameQuery = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .where('userId', isNotEqualTo: userId)
          .get();

      if (nicknameQuery.docs.isNotEmpty) {
        print('프로필 업데이트 실패: 닉네임이 이미 사용 중입니다.');
        return false;
      }

      final updateData = {
        'nickname': nickname,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).update(updateData);
      return true;
    } catch (e) {
      print('프로필 업데이트 실패: $e');
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }
}


// 주요 변경사항:
// 1. Firebase Auth와 Firestore 기능을 하나의 클래스로 통합
// 2. 중복된 메서드 제거 및 통합 (이메일/닉네임 체크 등)
// 3. 메서드 이름을 더 명확하게 변경 (예: emailCheck → isEmailAvailable)
// 4. 일관된 에러 핸들링과 로깅 추가
// 5. 프로필 업데이트 시 닉네임 중복 체크 로직 개선
// 6. 로그아웃 기능 추가