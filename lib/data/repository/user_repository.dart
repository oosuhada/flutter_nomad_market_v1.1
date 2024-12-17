import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_market_app/data/model/user.dart';

/// UserRepository는 사용자 인증 및 데이터 관리를 담당하는 클래스입니다.
/// Firebase Authentication과 Firestore를 사용하여 사용자 정보를 관리합니다.
class UserRepository {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 현재 로그인된 사용자의 ID를 반환합니다.
  String? get currentUserId => _auth.currentUser?.uid;

  /// 사용자 데이터를 보강하는 헬퍼 메서드
  /// Firestore 데이터와 User 모델 간의 필드 불일치를 해결합니다.
  Map<String, dynamic> _enrichUserData(
      Map<String, dynamic> userData, String documentId) {
    print("데이터 보강 시작:");
    print("- 원본 데이터: $userData");

    final enrichedData = {
      ...userData,
      'userId': documentId,
      'profileImageUrl': userData['profileImageUrl'] ?? '',
      'preferences': userData['preferences'] ??
          {'language': 'ko', 'currency': 'KRW', 'homeAddress': ''},
      'signInMethod': userData['signInMethod'] ?? 'email',
      'status': userData['status'] ?? 'active',
      'address': userData['address'] ??
          {'fullName': userData['preferences']?['homeAddress'] ?? ''}
    };

    print("- 보강된 데이터: $enrichedData");
    return enrichedData;
  }

  /// 이메일과 비밀번호로 로그인을 수행합니다.
  /// 성공 시 true, 실패 시 false를 반환합니다.
  Future<bool> login({
    required String email,
    required String password,
    String signInMethod = 'email',
  }) async {
    try {
      print("로그인 시도:");
      print("- 이메일: $email");
      print("- 로그인 방식: $signInMethod");

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        print("Firebase Auth 로그인 성공");
        // 마지막 로그인 시간 업데이트
        await _firestore.collection('users').doc(credential.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        print("마지막 로그인 시간 업데이트 완료");
        return true;
      }
      print("로그인 실패: 사용자 정보가 null입니다");
      return false;
    } catch (e) {
      print('로그인 실패: $e');
      return false;
    }
  }

  /// 이메일 중복 여부를 확인합니다.
  /// 사용 가능한 경우 true, 이미 사용 중인 경우 false를 반환합니다.
  Future<bool> isEmailAvailable(String email) async {
    try {
      print("이메일 중복 확인 시작: $email");
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      final isAvailable = result.docs.isEmpty;
      print("이메일 사용 가능 여부: $isAvailable");
      return isAvailable;
    } catch (e) {
      print('이메일 중복 확인 실패: $e');
      return false;
    }
  }

  /// 닉네임 중복 여부를 확인합니다.
  /// 사용 가능한 경우 true, 이미 사용 중인 경우 false를 반환합니다.
  Future<bool> isNicknameAvailable(String nickname) async {
    try {
      print("닉네임 중복 확인 시작: $nickname");
      final result = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .get();

      final isAvailable = result.docs.isEmpty;
      print("닉네임 사용 가능 여부: $isAvailable");
      return isAvailable;
    } catch (e) {
      print('닉네임 중복 확인 실패: $e');
      return false;
    }
  }

  /// ID로 사용자 정보를 조회합니다.
  Future<User?> getUserById(String userId) async {
    try {
      print("ID로 사용자 조회 시작: $userId");
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (docSnapshot.exists) {
        print("사용자 문서 찾음");
        final enrichedData =
            _enrichUserData(docSnapshot.data()!, docSnapshot.id);
        return User.fromJson(enrichedData);
      }

      print("해당 ID의 사용자 문서가 존재하지 않음");
      return null;
    } catch (e, stackTrace) {
      print('ID로 사용자 조회 실패:');
      print('- 에러: $e');
      print('- 스택트레이스: $stackTrace');
      return null;
    }
  }

  /// 이메일로 사용자 정보를 조회합니다.
  Future<User?> getUserByEmail(String email) async {
    try {
      print("이메일로 사용자 조회 시작: $email");
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        print("사용자 문서 찾음");
        final enrichedData = _enrichUserData(doc.data(), doc.id);
        return User.fromJson(enrichedData);
      }

      print("해당 이메일의 사용자를 찾을 수 없음");
      return null;
    } catch (e, stackTrace) {
      print("이메일로 사용자 조회 실패:");
      print("- 에러: $e");
      print("- 스택트레이스: $stackTrace");
      return null;
    }
  }

  /// 닉네임으로 사용자 정보를 조회합니다.
  Future<User?> getUserByNickname(String nickname) async {
    try {
      print("닉네임으로 사용자 조회 시작: $nickname");
      final querySnapshot = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        print("사용자 문서 찾음");
        final enrichedData = _enrichUserData(doc.data(), doc.id);
        return User.fromJson(enrichedData);
      }

      print("해당 닉네임의 사용자를 찾을 수 없음");
      return null;
    } catch (e, stackTrace) {
      print("닉네임으로 사용자 조회 실패:");
      print("- 에러: $e");
      print("- 스택트레이스: $stackTrace");
      return null;
    }
  }

  /// 현재 로그인된 사용자의 정보를 조회합니다.
  /// UID, 이메일, 닉네임 순으로 시도하여 정보를 찾습니다.
  Future<User?> getCurrentUserInfo() async {
    try {
      final authUser = _auth.currentUser;
      print("현재 Firebase Auth 사용자 상태 확인:");
      print("- 인증된 사용자: ${authUser != null}");
      print("- 이메일: ${authUser?.email}");
      print("- UID: ${authUser?.uid}");

      if (authUser == null) {
        print("Firebase Auth에 로그인된 사용자가 없음");
        return null;
      }

      // 1. UID로 조회 시도
      print("1단계: UID로 사용자 조회 시도");
      final docSnapshot =
          await _firestore.collection('users').doc(authUser.uid).get();

      if (docSnapshot.exists) {
        print("UID로 사용자 문서 찾음");
        final enrichedData =
            _enrichUserData(docSnapshot.data()!, docSnapshot.id);
        return User.fromJson(enrichedData);
      }

      // 2. 이메일로 조회 시도
      if (authUser.email != null) {
        print("2단계: 이메일로 사용자 조회 시도");
        final userByEmail = await getUserByEmail(authUser.email!);
        if (userByEmail != null) {
          print("이메일로 사용자 정보 조회 성공");
          return userByEmail;
        }

        // 3. 닉네임으로 조회 시도
        print("3단계: 닉네임으로 사용자 조회 시도");
        final emailQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: authUser.email)
            .limit(1)
            .get();

        if (emailQuery.docs.isNotEmpty) {
          final doc = emailQuery.docs.first;
          final userData = doc.data();
          final nickname = userData['nickname'];

          if (nickname != null) {
            print("닉네임으로 재시도: $nickname");
            final userByNickname = await getUserByNickname(nickname);
            if (userByNickname != null) {
              print("닉네임으로 사용자 정보 조회 성공");
              return userByNickname;
            }
          }
        }
      }

      print("모든 조회 방법 실패 (UID, 이메일, 닉네임)");
      return null;
    } catch (e, stackTrace) {
      print("사용자 정보 조회 중 에러 발생:");
      print("- 에러: $e");
      print("- 스택트레이스: $stackTrace");
      return null;
    }
  }

  /// 새로운 사용자를 등록합니다.
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
      print("회원가입 시작:");
      print("- 이메일: $email");
      print("- 닉네임: $nickname");

      // 중복 확인
      if (!await isEmailAvailable(email)) {
        print('회원가입 실패: 이메일 중복');
        return false;
      }
      if (!await isNicknameAvailable(nickname)) {
        print('회원가입 실패: 닉네임 중복');
        return false;
      }

      // Firebase Auth에 사용자 생성
      print("Firebase Auth 계정 생성 시도");
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        print("Firebase Auth 계정 생성 실패");
        return false;
      }

      // Firestore에 사용자 정보 저장
      print("Firestore에 사용자 정보 저장 시도");
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

      print("회원가입 성공");
      return true;
    } catch (e, stackTrace) {
      print('회원가입 실패:');
      print('- 에러: $e');
      print('- 스택트레이스: $stackTrace');
      return false;
    }
  }

  /// 사용자 프로필을 업데이트합니다.
  Future<bool> updateProfile({
    required String userId,
    required String nickname,
    String? profileImageUrl,
  }) async {
    try {
      print("프로필 업데이트 시작:");
      print("- 사용자 ID: $userId");
      print("- 새 닉네임: $nickname");

      // 닉네임 중복 확인 (현재 사용자 제외)
      final nicknameQuery = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .where('userId', isNotEqualTo: userId)
          .get();

      if (nicknameQuery.docs.isNotEmpty) {
        print('프로필 업데이트 실패: 닉네임 중복');
        return false;
      }

      final updateData = {
        'nickname': nickname,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).update(updateData);
      print("프로필 업데이트 성공");
      return true;
    } catch (e, stackTrace) {
      print('프로필 업데이트 실패:');
      print('- 에러: $e');
      print('- 스택트레이스: $stackTrace');
      return false;
    }
  }

  /// 현재 로그인된 사용자를 로그아웃합니다.
  Future<void> signOut() async {
    print("로그아웃 시도");
    try {
      await _auth.signOut();
      print("로그아웃 성공");
    } catch (e) {
      print("로그아웃 실패: $e");
    }
  }
}

//   // 현재 로그인한 사용자 정보 조회 수정
//   Future<User?> myInfo() async {
//     try {
//       final currentUser = _auth.currentUser;
//       if (currentUser == null) {
//         print("로그인된 사용자 없음");
//         return null;
//       }

//       // 이메일로 사용자 정보 조회
//       final user = await getUserByEmail(currentUser.email!);
//       if (user != null) {
//         print("현재 사용자 정보 조회 성공:");
//         print("- 이메일: ${user.email}");
//         print("- 닉네임: ${user.nickname}");
//         print("- 주소: ${user.address?.fullName}");
//         return user;
//       }

//       return null;
//     } catch (e) {
//       print("현재 사용자 정보 조회 실패: $e");
//       return null;
//     }
//   }

// // 현재 로그인한 사용자 정보 조회
//   Future<User?> myInfo() async {
//     try {
//       if (currentUserId == null) return null;

//       final doc = await _firestore.collection('users').doc(currentUserId).get();
//       if (!doc.exists) return null;

//       return User.fromJson(doc.data()!);
//     } catch (e) {
//       print('사용자 정보 조회 실패: $e');
//       return null;
//     }
//   }


// 주요 변경사항:
// 1. Firebase Auth와 Firestore 기능을 하나의 클래스로 통합
// 2. 중복된 메서드 제거 및 통합 (이메일/닉네임 체크 등)
// 3. 메서드 이름을 더 명확하게 변경 (예: emailCheck → isEmailAvailable)
// 4. 일관된 에러 핸들링과 로깅 추가
// 5. 프로필 업데이트 시 닉네임 중복 체크 로직 개선
// 6. 로그아웃 기능 추가