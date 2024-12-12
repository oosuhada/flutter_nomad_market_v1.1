// 1. 상태클래스 만들기 => X

// 2. 뷰모델 만들기

import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginViewModel {
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final userRepository = UserRepository();
    return await userRepository.login(
      username: username,
      password: password,
    );
  }
}

// 3. 뷰모델 관리자 만들기
final loginViewmodel = Provider.autoDispose((ref) {
  return LoginViewModel();
});

// 구글 로그인 핸들러
void onGoogleSignIn(WidgetRef ref) {
  // TODO: 구글 소셜 로그인 로직 구현
  print('구글 로그인 시도');
  // 로그인 성공 시 홈페이지로 이동하는 로직 추가 필요
}

// 페이스북 로그인 핸들러
void onFacebookSignIn(WidgetRef ref) {
  // TODO: 페이스북 소셜 로그인 로직 구현
  print('페이스북 로그인 시도');
  // 로그인 성공 시 홈페이지로 이동하는 로직 추가 필요
}
