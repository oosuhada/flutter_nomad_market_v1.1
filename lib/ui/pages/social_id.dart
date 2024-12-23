import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    signInOption: SignInOption.standard,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserRepository _userInfoRepository = UserRepository();

// 원형 소셜 로그인 버튼들 구현
  Widget buildCircleKakaoButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFFFEE500),
        child: Image.asset(
          'assets/kakao_logo.png',
          width: 35,
          height: 35,
        ),
      ),
    );
  }

  Widget buildCircleNaverButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFF03C75A),
        child: Image.asset(
          'assets/naver_logo.png',
          width: 40,
          height: 40,
        ),
      ),
    );
  }

  Widget buildCircleGoogleButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white,
        child: Image.asset(
          'assets/google_logo.png',
          width: 28,
          height: 28,
        ),
      ),
    );
  }

  Widget buildCircleFacebookButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFF1877F2),
        child: Icon(
          Icons.facebook,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget buildCircleAppleButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        child: Icon(
          Icons.apple,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // 모든 원형 소셜 로그인 버튼을 포함하는 그룹 위젯
  Widget buildCircleSocialButtons(
    BuildContext context, {
    required Function() onKakaoTap,
    required Function() onNaverTap,
    required Function() onGoogleTap,
    required Function() onFacebookTap,
    required Function() onAppleTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            '간편 소셜 로그인',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCircleKakaoButton(context, onTap: onKakaoTap),
              SizedBox(width: 16),
              buildCircleNaverButton(context, onTap: onNaverTap),
              SizedBox(width: 16),
              buildCircleGoogleButton(context, onTap: onGoogleTap),
              SizedBox(width: 16),
              buildCircleFacebookButton(context, onTap: onFacebookTap),
              SizedBox(width: 16),
              if (isAppleSignInAvailable())
                buildCircleAppleButton(context, onTap: onAppleTap),
            ],
          ),
        ],
      ),
    );
  }

// 애플 소셜 회원가입
  Future<bool> onAppleSignUp(
    BuildContext context, {
    required String language,
    required String currency,
    required String addressFullName,
  }) async {
    try {
      print("애플 회원가입 시작");
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.email == null) {
        print("회원가입 취소됨");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('애플 회원가입이 취소되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }

      final oAuthProvider = firebase.OAuthProvider('apple.com');
      final credentialAuth = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final firebase.UserCredential authResult =
          await _auth.signInWithCredential(credentialAuth);
      final firebase.User? user = authResult.user;

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
        String displayName = '';
        if (credential.givenName != null || credential.familyName != null) {
          displayName =
              '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                  .trim();
        }

        await _firestore.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'email': credential.email,
          'password': null,
          'nickname': displayName.isNotEmpty
              ? displayName
              : 'User${user.uid.substring(0, 5)}',
          'profileImageUrl': user.photoURL ?? '',
          'preferences': {
            'language': language.split(' ')[0].toLowerCase(),
            'currency': currency.split(' ')[0],
            'homeAddress': addressFullName,
          },
          'signInMethod': 'apple',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });

        print('새로운 Apple 사용자 정보가 저장되었습니다.');
        return true;
      }
      return false;
    } catch (error) {
      print('애플 회원가입 중 오류 발생: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

// 애플 소셜 로그인
  Future<bool> onAppleSignIn(BuildContext context) async {
    try {
      print("애플 로그인 시작");
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = firebase.OAuthProvider('apple.com');
      final credentialAuth = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final firebase.UserCredential authResult =
          await _auth.signInWithCredential(credentialAuth);
      final firebase.User? user = authResult.user;

      if (user != null) {
        // UserInfoRepository를 통해 로그인 처리
        final loginResult = await _userInfoRepository.login(
          email: user.email!,
          signInMethod: 'apple',
          password: 'null',
        );

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
      return false;
    } catch (error) {
      print('애플 로그인 중 오류 발생: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

// 애플 로그인 가능 여부 체크
  bool isAppleSignInAvailable() {
    return Platform.isIOS;
  }

// 애플 로그인 버튼 위젯 생성 메서드
  Widget buildAppleSignInButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    if (!isAppleSignInAvailable()) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 52,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.black,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[100]
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.25),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apple, size: 24, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '애플 아이디로 계속하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 구글 소셜 회원가입
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
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase.UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final firebase.User? user = authResult.user;

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

  // 구글 소셜 로그인
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
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase.UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final firebase.User? user = authResult.user;

      if (user != null) {
        // UserInfoRepository를 통해 로그인 처리
        final loginResult = await _userInfoRepository.login(
          email: user.email!,
          signInMethod: 'google',
          password: 'null',
        );

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

  // 페이스북 소셜 회원가입
  Future<bool> onFacebookSignUp(
    BuildContext context, {
    required String language,
    required String currency,
    required String addressFullName,
  }) async {
    try {
      print("페이스북 회원가입 시작");
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (loginResult.status != LoginStatus.success) {
        print("회원가입 취소됨");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('페이스북 회원가입이 취소되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }

      // 페이스북 유저 정보 가져오기
      final userData = await FacebookAuth.instance.getUserData();

      // Firebase credential 생성
      final AccessToken? accessToken = loginResult.accessToken;
      final firebase.OAuthCredential facebookAuthCredential =
          firebase.FacebookAuthProvider.credential(
        accessToken?.toJson()['token'] ?? '',
      );

      final firebase.UserCredential authResult =
          await _auth.signInWithCredential(facebookAuthCredential);
      final firebase.User? user = authResult.user;

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
          'email': userData['email'] ?? user.email,
          'password': null,
          'nickname': userData['name'] ?? 'User${user.uid.substring(0, 5)}',
          'profileImageUrl':
              userData['picture']?['data']?['url'] ?? user.photoURL ?? '',
          'preferences': {
            'language': language.split(' ')[0].toLowerCase(),
            'currency': currency.split(' ')[0],
            'homeAddress': addressFullName,
          },
          'signInMethod': 'facebook',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });

        print('새로운 Facebook 사용자 정보가 저장되었습니다.');
        return true;
      }
      return false;
    } catch (error) {
      print('페이스북 회원가입 중 오류 발생: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

// 페이스북 소셜 로그인
  Future<bool> onFacebookSignIn(BuildContext context) async {
    try {
      print("페이스북 로그인 시작");
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (loginResult.status != LoginStatus.success) {
        print("로그인 취소됨");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('페이스북 로그인이 취소되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }

      // Firebase credential 생성
      final AccessToken? accessToken = loginResult.accessToken;
      final firebase.OAuthCredential facebookAuthCredential =
          firebase.FacebookAuthProvider.credential(
        accessToken?.toJson()['token'] ?? '',
      );

      final firebase.UserCredential authResult =
          await _auth.signInWithCredential(facebookAuthCredential);
      final firebase.User? user = authResult.user;

      if (user != null) {
        // UserInfoRepository를 통해 로그인 처리
        final loginResult = await _userInfoRepository.login(
          email: user.email!,
          signInMethod: 'facebook',
          password: 'null',
        );

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
      return false;
    } catch (error) {
      print('페이스북 로그인 중 오류 발생: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

// Kakao SignIn Method
  Future<bool> onKakaoSignIn(BuildContext context) async {
    try {
      print("카카오 로그인 시작");

      if (await kakao.isKakaoTalkInstalled()) {
        try {
          await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          print('카카오톡으로 로그인 실패: $error');
          await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 카카오 사용자 정보 가져오기
      final kakaoUser = await kakao.UserApi.instance.me();

      // Firebase Custom Token 생성 (백엔드 구현 필요)
      // final token = await _getFirebaseCustomToken(kakaoUser.id);
      // final authResult = await _auth.signInWithCustomToken(token);
      final firebase.User? user = _auth.currentUser;

      if (user != null) {
        // UserInfoRepository를 통해 로그인 처리
        final loginResult = await _userInfoRepository.login(
          email: kakaoUser.kakaoAccount?.email ?? '',
          signInMethod: 'kakao',
          password: 'null',
        );

        if (loginResult != null) {
          print("로그인 성공: ${kakaoUser.kakaoAccount?.email}");

          // 마지막 로그인 시간 업데이트
          await _firestore.collection('users').doc(user.uid).update({
            'lastLoginAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${kakaoUser.kakaoAccount?.profile?.nickname ?? "사용자"}님, 환영합니다!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return true;
        }
      }
      return false;
    } catch (error) {
      print('카카오 로그인 중 오류 발생: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  // Kakao SignUp Method
  Future<bool> onKakaoSignUp(
    BuildContext context, {
    required String language,
    required String currency,
    required String addressFullName,
  }) async {
    try {
      print("카카오 회원가입 시작");

      if (await kakao.isKakaoTalkInstalled()) {
        try {
          await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          print('카카오톡으로 로그인 실패: $error');
          await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 카카오 사용자 정보 가져오기
      final kakaoUser = await kakao.UserApi.instance.me();

      // Firebase Custom Token 생성 (백엔드 구현 필요)
      // final token = await _getFirebaseCustomToken(kakaoUser.id);
      // final authResult = await _auth.signInWithCustomToken(token);
      final firebase.User? user = _auth.currentUser;

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
          'email': kakaoUser.kakaoAccount?.email,
          'password': null,
          'nickname': kakaoUser.kakaoAccount?.profile?.nickname ??
              'User${user.uid.substring(0, 5)}',
          'profileImageUrl':
              kakaoUser.kakaoAccount?.profile?.profileImageUrl ?? '',
          'preferences': {
            'language': language.split(' ')[0].toLowerCase(),
            'currency': currency.split(' ')[0],
            'homeAddress': addressFullName,
          },
          'signInMethod': 'kakao',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });

        print('새로운 Kakao 사용자 정보가 저장되었습니다.');
        return true;
      }
      return false;
    } catch (error) {
      print('카카오 회원가입 중 오류 발생: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  // Naver SignUp
  Future<bool> onNaverSignUp(
    BuildContext context, {
    required String language,
    required String currency,
    required String addressFullName,
  }) async {
    try {
      print("네이버 회원가입 시작");

      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        final NaverAccountResult account =
            await FlutterNaverLogin.currentAccount();

        // Firebase Custom Token 생성 (백엔드 구현 필요)
        // final token = await _getFirebaseCustomToken(account.id);
        // final UserCredential authResult = await _auth.signInWithCustomToken(token);
        final firebase.User? user = _auth.currentUser;

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
            'email': account.email,
            'password': null,
            'nickname': account.name,
            'profileImageUrl': account.profileImage,
            'preferences': {
              'language': language.split(' ')[0].toLowerCase(),
              'currency': currency.split(' ')[0],
              'homeAddress': addressFullName,
            },
            'signInMethod': 'naver',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'status': 'active',
          });

          print('새로운 Naver 사용자 정보가 저장되었습니다.');
          return true;
        }
      } else if (result.status == NaverLoginStatus.cancelledByUser) {
        print("사용자가 네이버 로그인을 취소했습니다.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('네이버 회원가입이 취소되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    } catch (error) {
      print('네이버 회원가입 중 오류 발생: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  // Naver Login Method
  Future<bool> onNaverSignIn(BuildContext context) async {
    try {
      print("네이버 로그인 시작");

      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        final NaverAccountResult account =
            await FlutterNaverLogin.currentAccount();

        // Firebase Custom Token 생성 (백엔드 구현 필요)
        // final token = await _getFirebaseCustomToken(account.id);
        // final UserCredential authResult = await _auth.signInWithCustomToken(token);
        final firebase.User? user = _auth.currentUser;

        if (user != null) {
          // UserInfoRepository를 통해 로그인 처리
          final loginResult = await _userInfoRepository.login(
            email: account.email,
            signInMethod: 'naver',
            password: 'null',
          );

          print("로그인 성공: ${account.email}");

          // 마지막 로그인 시간 업데이트
          await _firestore.collection('users').doc(user.uid).update({
            'lastLoginAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${account.name}님, 환영합니다!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return true;
        }
      } else if (result.status == NaverLoginStatus.cancelledByUser) {
        print("사용자가 네이버 로그인을 취소했습니다.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('네이버 로그인이 취소되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    } catch (error) {
      print('네이버 로그인 중 오류 발생: $error');
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
