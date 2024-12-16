import 'package:flutter/material.dart';
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

  Future<void> onGoogleSignIn(BuildContext context) async {
    try {
      // 구글 로그인 프로세스 시작
      print("구글 로그인 시작");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // 사용자가 로그인을 취소한 경우
        print("로그인 취소됨");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구글 로그인이 취소되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // 구글 인증 자격 증명 가져오기
      print("구글 계정 선택 완료: ${googleUser.email}");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 인증 자격 증명 생성
      print("구글 인증 완료");
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      print("Firebase 로그인 시도");
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // 로그인 성공 시 홈페이지로 이동
      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${userCredential.user!.displayName}님, 환영합니다!'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 스낵바 표시 후 잠시 대기
        print("스낵바 표시 후 2초 대기 시작"); // 디버깅 로그 추가
        await Future.delayed(Duration(seconds: 2));
        print("대기 완료, HomePage 이동 시도");

        // MaterialApp이 있는지 확인
        if (context.mounted) {
          // context가 여전히 유효한지 확인
          try {
            // 홈페이지로 이동하고 이전 스택 모두 제거
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) {
                  print("HomePage 빌드 시도"); // 디버깅 로그 추가
                  return HomePage();
                },
              ),
              (route) => false,
            );
            print("HomePage 이동 완료"); // 디버깅 로그 추가
          } catch (e) {
            print("네비게이션 오류 발생: $e"); // 네비게이션 오류 캐치
          }
        } else {
          print("context가 더 이상 유효하지 않음"); // 디버깅 로그 추가
        }
      } else {
        print("Firebase 로그인 실패: user가 null"); // 디버깅 로그 추가
      }
    } catch (error) {
      print('구글 로그인 중 오류 발생: $error'); // 더 자세한 에러 로그
      print('에러 스택트레이스: ${StackTrace.current}'); // 스택트레이스 추가

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 중 오류가 발생했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Riverpod Provider로 AuthService 제공
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 페이스북 로그인 핸들러
void onFacebookSignIn(WidgetRef ref) {
  print('페이스북 로그인 시도');
}
