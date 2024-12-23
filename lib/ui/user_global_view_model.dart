import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';

// 사용자 전역 상태 클래스
class UserGlobalState {
  final User? user; // 현재 사용자 정보
  final bool isLoading; // 로딩 상태
  final String? error; // 에러 메시지

  const UserGlobalState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserGlobalState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserGlobalState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserGlobalViewModel extends StateNotifier<UserGlobalState> {
  final UserRepository userRepository;
  StreamSubscription? _userSubscription;

  UserGlobalViewModel(this.userRepository) : super(const UserGlobalState()) {
    // 생성자에서 자동으로 초기 데이터 로드
    _initializeUserStream();
  }

  // 사용자 정보 스트림 초기화 및 구독
  Future<void> _initializeUserStream() async {
    state = state.copyWith(isLoading: true);

    try {
      // 기존 구독 취소
      await _userSubscription?.cancel();

      // 새로운 스트림 구독
      _userSubscription = userRepository
          .getUserStream()
          .distinct() // 중복 이벤트 필터링
          .listen(
        (userData) {
          if (userData != null) {
            state = state.copyWith(
              user: userData,
              isLoading: false,
            );
            _logUserInfo(userData); // 디버깅용 로그
          }
        },
        onError: (error) {
          state = state.copyWith(
            error: error.toString(),
            isLoading: false,
          );
          print("사용자 정보 스트림 에러: $error");
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      print("사용자 정보 초기화 에러: $e");
    }
  }

  // 사용자 정보 수동 새로고침
  Future<void> refreshUserData() async {
    try {
      state = state.copyWith(isLoading: true);
      final userData = await userRepository.getCurrentUserInfo();
      if (userData != null) {
        state = state.copyWith(
          user: userData,
          isLoading: false,
        );
        _logUserInfo(userData);
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      print("사용자 정보 새로고침 에러: $e");
    }
  }

  // 디버깅용 로그 출력 메소드
  void _logUserInfo(User user) {
    print("===== 사용자 정보 업데이트 =====");
    print("- userId: ${user.userId}");
    print("- email: ${user.email}");
    print("- nickname: ${user.nickname}");
    print("- address: ${user.address.fullNameKR}");
  }

// 계정 정리 메서드 추가
  Future<void> cleanupInconsistentAccounts() async {
    try {
      state = state.copyWith(isLoading: true);
      final currentUser = userRepository.currentUserId;
      if (currentUser != null) {
        final userData = await userRepository.getCurrentUserInfo();
        if (userData != null) {
          final isConsistent =
              await userRepository.checkUserDataConsistency(userData.email);
          if (!isConsistent) {
            await userRepository.cleanupAuthAccount(userData.email);
          }
        }
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      print("계정 정리 중 에러: $e");
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}

// Provider 정의
final userRepositoryProvider = Provider((ref) => UserRepository());

final userGlobalViewModel =
    StateNotifierProvider<UserGlobalViewModel, UserGlobalState>((ref) {
  return UserGlobalViewModel(ref.watch(userRepositoryProvider));
});
