// login_state.dart

// 로그인 상태를 관리하는 클래스
class LoginState {
  final bool isLoading; // 로딩 상태
  final String? error; // 에러 메시지
  final bool? loginSuccess; // 로그인 성공 여부

  const LoginState({
    this.isLoading = false,
    this.error,
    this.loginSuccess,
  });

  // 새로운 상태를 생성하는 copyWith 메서드
  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? loginSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      loginSuccess: loginSuccess ?? this.loginSuccess,
    );
  }
}
