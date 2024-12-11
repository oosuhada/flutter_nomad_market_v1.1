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
