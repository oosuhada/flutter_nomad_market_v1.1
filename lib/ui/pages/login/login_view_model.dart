// login_view_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_market_app/ui/pages/login/login_state.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  final UserRepository userRepository;

  LoginViewModel({required this.userRepository}) : super(const LoginState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return; // 이미 로딩 중이면 중복 요청 방지

    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        loginSuccess: null,
      );

      final result = await userRepository.login(
        email: email,
        password: password,
        signInMethod: 'email',
      );

      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        loginSuccess: result,
        error: result ? null : '로그인에 실패했습니다.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = '존재하지 않는 이메일입니다.';
          break;
        case 'wrong-password':
          errorMessage = '잘못된 비밀번호입니다.';
          break;
        case 'invalid-email':
          errorMessage = '유효하지 않은 이메일 형식입니다.';
          break;
        case 'user-disabled':
          errorMessage = '비활성화된 계정입니다.';
          break;
        default:
          errorMessage = '로그인 중 오류가 발생했습니다.';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        loginSuccess: false,
      );
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        error: '로그인 중 오류가 발생했습니다.',
        loginSuccess: false,
      );
    }
  }

  void resetState() {
    if (mounted) {
      state = const LoginState();
    }
  }
}

final loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return LoginViewModel(userRepository: userRepository);
});
