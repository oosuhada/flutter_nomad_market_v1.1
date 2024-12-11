// 1. 상태 => User 클래스 사용

// 2. 뷰모델만들기

import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserGlobalViewModel extends Notifier<User?> {
  @override
  User? build() {
    fetchUserInfo();
    return null;
  }

  final userRepository = UserRepository();

  Future<void> fetchUserInfo() async {
    final user = await userRepository.myInfo();
    state = user;
  }
}

// 3. 뷰모델 관리자 만들기
final userGlobalViewModel = NotifierProvider<UserGlobalViewModel, User?>(() {
  return UserGlobalViewModel();
});
