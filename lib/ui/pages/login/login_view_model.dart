// login_view_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_market_app/ui/pages/home/home_page.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  final bool isLoading;
  final String? error;
  final bool? loginSuccess;

  LoginState({
    this.isLoading = false,
    this.error,
    this.loginSuccess,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? loginSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      loginSuccess: loginSuccess ?? this.loginSuccess,
    );
  }
}

class LoginViewModel extends AutoDisposeNotifier<LoginState> {
  final userInfoRepository = UserRepository();

  @override
  LoginState build() {
    return LoginState();
  }

  // 로그인 처리 비즈니스 로직
  Future<bool?> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await userInfoRepository.login(
        email: email,
        password: password,
        signInMethod: '',
      );

      state = state.copyWith(
        loginSuccess: result,
        error: result == false ? '로그인에 실패했습니다' : null,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        error: '로그인 중 오류가 발생했습니다',
        loginSuccess: false,
      );
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 사용자 데이터 초기화 로직
  Future<void> initUserData(WidgetRef ref) async {
    print("사용자 정보 초기화 시작");
    try {
      final userVM = ref.read(userGlobalViewModel.notifier);
      await userVM.initUserData();
      final userData = ref.read(userGlobalViewModel);
      print("사용자 정보 로드 완료:");
      print("- 사용자 ID: ${userData?.userId}");
      print("- 닉네임: ${userData?.nickname}");
    } catch (e) {
      print("사용자 정보 초기화 중 오류 발생: $e");
      throw e;
    }
  }

  // 홈페이지 이동 처리 로직
  Future<void> navigateToHome(BuildContext context) async {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('로그인에 성공했습니다'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    await Future.delayed(Duration(seconds: 2));

    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOut;
          var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          );
          var scaleAnimation = Tween(begin: 0.1, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          );
          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }

  // 에러 처리 로직
  void handleError(BuildContext context, dynamic error) {
    String errorMessage = '로그인 중 오류가 발생했습니다';

    if (error is FirebaseAuthException) {
      print("===== Firebase 인증 에러 =====");
      print("에러 코드: ${error.code}");
      print("에러 메시지: ${error.message}");

      switch (error.code) {
        case 'user-not-found':
          errorMessage = '등록되지 않은 이메일입니다';
          break;
        case 'wrong-password':
          errorMessage = '잘못된 비밀번호입니다';
          break;
        case 'invalid-email':
          errorMessage = '유효하지 않은 이메일 형식입니다';
          break;
        // 필요한 다른 에러 케이스 추가
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}

final loginViewmodel =
    NotifierProvider.autoDispose<LoginViewModel, LoginState>(() {
  return LoginViewModel();
});
