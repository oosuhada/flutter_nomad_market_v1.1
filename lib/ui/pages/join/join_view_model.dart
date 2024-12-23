import 'dart:io';

import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/repository/file_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_market_app/ui/pages/join/join_state.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JoinViewModel extends StateNotifier<JoinState> {
  final UserRepository userRepository;
  final FileRepository fileRepository;

  // 생성자에서 초기 상태 설정
  JoinViewModel({
    required this.userRepository,
    required this.fileRepository,
  }) : super(const JoinState());

  // 프로필 이미지 업로드 메서드
  Future<void> uploadProfileImage(String imagePath) async {
    if (state.isLoading) return; // 이미 로딩 중이면 중복 실행 방지

    try {
      state = state.copyWith(isLoading: true, error: null);
      // 파일 존재 여부 확인
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('파일이 존재하지 않습니다');
      }

      // 파일 업로드 처리
      final bytes = await file.readAsBytes();
      final filename = imagePath.split('/').last;
      final fileModel = await fileRepository.upload(
        bytes: bytes,
        filename: filename,
        mimeType: 'image/jpeg',
      );

      if (fileModel != null) {
        state = state.copyWith(
          isLoading: false,
          imageUrl: fileModel.url,
          error: null,
        );
      } else {
        throw Exception('이미지 업로드 실패');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '이미지 업로드 중 오류가 발생했습니다',
      );
    }
  }

  // 회원가입 처리 메서드
  Future<void> join({
    required String nickname,
    required String email,
    required String password,
    required String addressFullName,
    required String language,
    required String currency,
    required String profileImageUrl,
  }) async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, error: null, joinSuccess: null);

      // 데이터 일관성 체크 추가
      final isConsistent = await userRepository.checkUserDataConsistency(email);
      if (!isConsistent) {
        // 불일치하는 데이터 정리
        await userRepository.cleanupAuthAccount(email);
      }

      // 이메일 중복 체크
      final isEmailAvailable = await userRepository.isEmailAvailable(email);
      if (!isEmailAvailable) {
        state = state.copyWith(
          isLoading: false,
          error: '이미 사용 중인 이메일입니다',
          joinSuccess: false,
        );
        return;
      }

      // Firebase Auth 계정 생성
      final accountCreated = await userRepository.createAuthAccount(
        email: email,
        password: password,
      );

      if (accountCreated == null) {
        state = state.copyWith(
          isLoading: false,
          error: '계정 생성에 실패했습니다',
          joinSuccess: false,
        );
        return;
      }

      // Firestore에 사용자 정보 저장
      final result = await userRepository.join(
        nickname: nickname,
        email: email,
        password: password,
        addressFullName: addressFullName,
        profileImageUrl: state.imageUrl ?? '',
        language: language,
        currency: currency,
      );

      if (!result) {
        try {
          await userRepository.deleteAuthAccount();
          await userRepository.cleanupAuthAccount(email);
        } catch (e) {
          print("계정 정리 실패: $e");
        }
        state = state.copyWith(
          isLoading: false,
          error: '사용자 정보 저장에 실패했습니다',
          joinSuccess: false,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        joinSuccess: true,
        error: null,
      );
    } catch (e) {
      // 에러 처리 코드 동일
    }
  }

  void resetState() {
    state = const JoinState();
  }
}

// Firebase Auth 에러 코드를 사용자 친화적인 메시지로 변환하는 메서드
String _getErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'email-already-in-use':
      return '이미 사용 중인 이메일입니다.';
    case 'invalid-email':
      return '유효하지 않은 이메일 형식입니다.';
    case 'operation-not-allowed':
      return '이메일/비밀번호 로그인이 비활성화되어 있습니다.';
    case 'weak-password':
      return '비밀번호가 너무 약합니다.';
    default:
      return '회원가입 중 오류가 발생했습니다.';
  }
}

// 이 구조의 주요 장점들:

// 상태 관리가 체계적이고 예측 가능
// 비즈니스 로직과 UI 로직의 명확한 분리
// 의존성 주입을 통한 테스트 용이성
// 코드의 재사용성과 유지보수성 향상

// // 상태를 초기화하는 메서드
// void resetState() {
//   state = const JoinState();
// }

// Provider 정의 부분

// FileRepository 제공을 위한 Provider
final fileRepositoryProvider = Provider((ref) => FileRepository());

// 파일 업로드 관련 ViewModel Provider
final fileViewModelProvider =
    StateNotifierProvider<FileViewModel, AsyncValue<FileModel?>>((ref) {
  // fileRepositoryProvider로부터 repository 인스턴스를 가져옴
  final repository = ref.watch(fileRepositoryProvider);
  return FileViewModel(fileRepository: repository);
});

// 회원가입 관련 ViewModel Provider
final joinViewModelProvider =
    StateNotifierProvider<JoinViewModel, JoinState>((ref) {
  // 필요한 repository들을 가져옴
  final userRepository = ref.watch(userRepositoryProvider);
  final fileRepository = ref.watch(fileRepositoryProvider);

  // JoinViewModel 인스턴스 생성 및 반환
  return JoinViewModel(
    userRepository: userRepository,
    fileRepository: fileRepository,
  );
});

// 실제 데이터 흐름은 다음과 같습니다:
// UI -> JoinViewModel -> FileRepository -> FirebaseRepository -> Firebase Services
// 예를 들어 파일 업로드 시:

// UI에서 이미지 선택
// JoinViewModel에서 fileRepository.upload() 호출
// FileRepository(Firebase Storage 관련 로직)에서 처리
// FirebaseRepository의 기본 인스턴스들 활용

// 이런 구조의 장점은:

// 테스트 용이성 (Repository를 모의 객체로 대체 가능)
// 코드 재사용성 (다른 ViewModel에서도 동일한 Repository 사용 가능)
// 관심사 분리 (저장소 로직과 UI 로직 분리)



// 주요 포인트:

// StateNotifier<JoinState>를 상속받아 상태 타입을 지정
// super(const JoinState())로 초기 상태 설정
// state 속성은 StateNotifier에서 자동으로 제공
// copyWith 패턴으로 불변성 유지

// 이렇게 구현하면 state를 통해 상태를 관리할 수 있고, UI에서는 다음과 같이 사용할 수 있습니다:


// // UI에서 사용 예시
// final joinState = ref.watch(joinViewModelProvider);
// final viewModel = ref.read(joinViewModelProvider.notifier);

// // 상태 확인
// if (joinState.isLoading) {
//   // 로딩 중 처리
// }

// // 메서드 호출
// await viewModel.join(
//   nickname: nickname,
//   email: email,
//   password: password,
//   // ...
// );