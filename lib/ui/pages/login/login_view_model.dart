// login_view_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_market_app/ui/pages/login/login_state.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  final UserRepository userRepository;

  LoginViewModel({required this.userRepository}) : super(const LoginState());

  Future login({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: null, loginSuccess: null);

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
      String errorMessage = _getErrorMessage(e.code);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        loginSuccess: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: '로그인 중 오류가 발생했습니다: ${e.toString()}',
        loginSuccess: false,
      );
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return '존재하지 않는 이메일입니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      default:
        return '로그인 중 오류가 발생했습니다.';
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
