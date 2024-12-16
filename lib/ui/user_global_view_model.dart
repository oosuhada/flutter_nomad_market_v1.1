import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';

class UserGlobalViewModel extends StateNotifier<User?> {
  final UserRepository userRepository;

  UserGlobalViewModel(this.userRepository) : super(null);

  Future<void> initUserData() async {
    final userData = await userRepository.myInfo();
    state = userData;
  }

  Future<User?> getUserById(String userId) async {
    return await userRepository.getUserById(userId);
  }
}

final userGlobalViewModel =
    StateNotifierProvider<UserGlobalViewModel, User?>((ref) {
  return UserGlobalViewModel(UserRepository());
});
