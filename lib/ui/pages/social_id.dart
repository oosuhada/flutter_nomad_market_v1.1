import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_market_app/ui/pages/home/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    signInOption: SignInOption.standard,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserRepository _userInfoRepository = UserRepository();

  // 소셜 회원가입
  Future<bool> onGoogleSignUp(
    BuildContext context, {
    required String language,
    required String currency,
    required String addressFullName,
  }) async {
    try {
      print("구글 회원가입 시작");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("회원가입 취소됨");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구글 회원가입이 취소되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        // 이미 가입된 사용자인지 확인
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          print("이미 가입된 사용자입니다.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('이미 가입된 계정입니다. 로그인을 진행해주세요.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false;
        }

        // 신규 사용자 정보 저장
        await _firestore.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'email': user.email,
          'password': null,
          'nickname': user.displayName ?? 'User${user.uid.substring(0, 5)}',
          'profileImageUrl': user.photoURL ?? '',
          'preferences': {
            'language': language.split(' ')[0].toLowerCase(),
            'currency': currency.split(' ')[0],
            'homeAddress': addressFullName,
          },
          'signInMethod': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });

        print('새로운 Google 사용자 정보가 저장되었습니다.');
        return true;
      }
      return false;
    } catch (error) {
      print('구글 회원가입 중 오류 발생: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  // 소셜 로그인
  Future<bool> onGoogleSignIn(BuildContext context) async {
    try {
      print("구글 로그인 시작");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("로그인 취소됨");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구글 로그인이 취소되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        // UserInfoRepository를 통해 로그인 처리
        final loginResult = await _userInfoRepository.login(
          email: user.email!,
          signInMethod: 'google',
          password: 'null',
        );

        if (loginResult != null) {
          print("로그인 성공: ${user.email}");

          // 마지막 로그인 시간 업데이트
          await _firestore.collection('users').doc(user.uid).update({
            'lastLoginAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.displayName ?? "사용자"}님, 환영합니다!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return true;
        }
      }
      return false;
    } catch (error) {
      print('구글 로그인 중 오류 발생: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }
}

final authServiceProvider = Provider((ref) => AuthService());

// 페이스북 로그인 핸들러
void onFacebookSignIn(WidgetRef ref) {
  print('페이스북 로그인 시도');
}
