class JoinState {
  final bool isLoading; // 로딩 상태
  final String? error; // 에러 메시지
  final bool? joinSuccess; // 회원가입 성공 여부
  final String? imageUrl; // 프로필 이미지 URL

  const JoinState({
    this.isLoading = false,
    this.error,
    this.joinSuccess,
    this.imageUrl,
  });

  JoinState copyWith({
    bool? isLoading,
    String? error,
    bool? joinSuccess,
    String? imageUrl,
  }) {
    return JoinState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      joinSuccess: joinSuccess ?? this.joinSuccess,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
