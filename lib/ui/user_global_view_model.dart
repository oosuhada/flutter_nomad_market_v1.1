// lib/ui/pages/user_global_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';

// StateNotifier 클래스 정의
class UserGlobalViewModel extends StateNotifier<User?> {
  final UserRepository userRepository;

  UserGlobalViewModel(this.userRepository) : super(null);

  Future<User?> initUserData() async {
    print("===== UserGlobalViewModel initUserData 시작 =====");
    try {
      final userData = await userRepository.getCurrentUserInfo();
      if (userData != null) {
        print("사용자 정보 조회 성공:");
        print("- userId: ${userData.userId}");
        print("- email: ${userData.email}");
        print("- nickname: ${userData.nickname}");
        print("- address: ${userData.address.fullName}");

        // 상태 업데이트
        state = userData;
        return state;
      } else {
        print("사용자 정보 조회 실패: null 반환됨");
        // 상태 초기화
        state = null;
        return null;
      }
    } catch (e, stackTrace) {
      print("사용자 정보 초기화 에러:");
      print("- 에러: $e");
      print("- 스택트레이스: $stackTrace");
      // 에러 발생 시 상태 초기화
      state = null;
      return null;
    }
  }
}

// Provider 정의 - 여기가 중요합니다
final userGlobalViewModel =
    StateNotifierProvider<UserGlobalViewModel, User?>((ref) {
  return UserGlobalViewModel(UserRepository());
});

// Provider를 통해 repository에 직접 접근할 수 있는 provider도 추가
final userRepositoryProvider = Provider((ref) => UserRepository());
