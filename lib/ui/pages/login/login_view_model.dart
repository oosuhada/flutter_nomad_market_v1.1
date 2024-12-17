// 1. 상태클래스 만들기 => X

// 2. 뷰모델 만들기
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginViewModel {
  final userInfoRepository = UserRepository();
  Future<bool?> login({
    required String email,
    required String password,
  }) async {
    return await userInfoRepository.login(
      email: email,
      password: password,
      signInMethod: '',
    );
  }
}

// 3. 뷰모델 관리자 만들기
final loginViewmodel = Provider.autoDispose((ref) {
  return LoginViewModel();
});
