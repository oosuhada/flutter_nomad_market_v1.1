// 1. 상태클래스 만들기 => X

// 2. 뷰모델 만들기
import 'package:flutter_market_app/data/repository/user_info_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginViewModel {
  final userInfoRepository = UserInfoRepository();
  Future<bool?> login({
    required String email,
    required String password,
  }) async {
    return await userInfoRepository.login(
      email: email,
      password: password,
    );
  }
}

// 3. 뷰모델 관리자 만들기
final loginViewmodel = Provider.autoDispose((ref) {
  return LoginViewModel();
});
