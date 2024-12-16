// lib/ui/pages/user_global_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';

// StateNotifier 클래스 정의
class UserGlobalViewModel extends StateNotifier<User?> {
  final UserRepository userRepository;

  UserGlobalViewModel(this.userRepository) : super(null);

  Future<void> initUserData() async {
    print("===== UserGlobalViewModel initUserData 시작 =====");
    try {
      final userData = await userRepository.myInfo();
      print("사용자 정보 조회 결과:");
      print("- userId: ${userData?.userId}");
      print("- nickname: ${userData?.nickname}");
      state = userData;
    } catch (e) {
      print("사용자 정보 초기화 에러: $e");
    }
  }

  Future<User?> getUserById(String userId) async {
    print("사용자 정보 조회 시도: $userId");
    return await userRepository.getUserById(userId);
  }
}

// Provider 정의 - 여기가 중요합니다
final userGlobalViewModel =
    StateNotifierProvider<UserGlobalViewModel, User?>((ref) {
  return UserGlobalViewModel(UserRepository());
});

// Provider를 통해 repository에 직접 접근할 수 있는 provider도 추가
final userRepositoryProvider = Provider((ref) => UserRepository());
