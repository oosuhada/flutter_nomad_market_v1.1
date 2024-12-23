// join_state.dart
class JoinState {
  // 로딩 상태를 나타내는 변수
  final bool isLoading;
  // 에러 메시지를 저장하는 변수 (에러가 없을 경우 null)
  final String? error;
  // 회원가입 성공 여부를 나타내는 변수
  final bool? joinSuccess;
  // 프로필 이미지 URL을 저장하는 변수
  final String? imageUrl;
  final bool isConsistencyChecking; // 데이터 일관성 체크 상태 추가

  // 상태 클래스 생성자
  const JoinState({
    this.isLoading = false,
    this.error,
    this.joinSuccess,
    this.imageUrl,
    this.isConsistencyChecking = false,
  });

  // 불변성을 유지하면서 상태를 업데이트하는 메서드
  JoinState copyWith({
    bool? isLoading,
    String? error,
    bool? joinSuccess,
    String? imageUrl,
    bool? isConsistencyChecking,
  }) {
    return JoinState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      joinSuccess: joinSuccess ?? this.joinSuccess,
      imageUrl: imageUrl ?? this.imageUrl,
      isConsistencyChecking:
          isConsistencyChecking ?? this.isConsistencyChecking,
    );
  }
}
