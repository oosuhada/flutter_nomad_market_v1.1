import 'dart:async';
import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';

// 사용자 전역 상태 클래스
class UserGlobalState {
  final User user;
  final bool isLoading;
  final String? error;

  const UserGlobalState({
    required this.user,
    this.isLoading = false,
    this.error,
  });

  String? get profileImageUrl => user?.profileImageUrl;
  String get nickname => user.nickname;
  String get userId => user.userId;
  Address get address => user.address;

  UserGlobalState copyWith({
    required User user,
    bool? isLoading,
    String? error,
  }) {
    return UserGlobalState(
      user: user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserGlobalViewModel extends StateNotifier<UserGlobalState> {
  final UserRepository userRepository;
  StreamSubscription? _userSubscription;

  UserGlobalViewModel(this.userRepository)
      : super(UserGlobalState(
            user: User(
          userId: '',
          email: '',
          nickname: '',
          profileImageUrl: '',
          preferences: Preferences(
            language: '',
            currency: '',
            homeAddress: '',
          ),
          signInMethod: '',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          status: '',
          address: Address(
            id: '',
            fullNameKR: '',
            fullNameEN: '',
            cityKR: '',
            cityEN: '',
            countryKR: '',
            countryEN: '',
            isServiceAvailable: false,
          ),
        ))) {
    // 생성자에서 자동으로 초기 데이터 로드
    _initializeUserStream();
  }

  // 사용자 정보 스트림 초기화 및 구독
  Future<void> _initializeUserStream() async {
    state = state.copyWith(isLoading: true, user: state.user);

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
            user: state.user,
          );
          print("사용자 정보 스트림 에러: $error");
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        user: state.user,
      );
      print("사용자 정보 초기화 에러: $e");
    }
  }

  // 사용자 정보 수동 새로고침
  Future<void> refreshUserData() async {
    try {
      state = state.copyWith(isLoading: true, user: state.user);
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
        user: state.user,
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
