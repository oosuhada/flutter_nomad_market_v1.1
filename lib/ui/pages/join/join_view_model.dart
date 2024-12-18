// join_view_model.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_market_app/ui/pages/join/join_state.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_market_app/data/repository/file_repository.dart';

class JoinViewModel extends StateNotifier<JoinState> {
  final UserRepository userRepository;
  final FileRepository fileRepository;

  JoinViewModel({
    required this.userRepository,
    required this.fileRepository,
  }) : super(const JoinState());

  Future<void> uploadProfileImage(String imagePath) async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('파일이 존재하지 않습니다');
      }

      final bytes = await file.readAsBytes();
      final filename = imagePath.split('/').last;

      final fileModel = await fileRepository.upload(
        bytes: bytes,
        filename: filename,
        mimeType: 'image/jpeg',
      );

      if (!mounted) return;

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
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        error: '이미지 업로드 중 오류가 발생했습니다',
      );
    }
  }

  Future<void> join({
    required String nickname,
    required String email,
    required String password,
    required String addressFullName,
    required String language,
    required String currency,
  }) async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        joinSuccess: null,
      );

      // 계정 생성
      final accountCreated = await userRepository.createAuthAccount(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (accountCreated == null) {
        throw Exception('계정 생성 실패');
      }

      // 사용자 정보 저장
      final result = await userRepository.join(
        nickname: nickname,
        email: email,
        password: password,
        addressFullName: addressFullName,
        profileImageUrl: state.imageUrl ?? '',
        language: language,
        currency: currency,
      );

      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        joinSuccess: result,
        error: result ? null : '회원가입에 실패했습니다.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = '이미 사용 중인 이메일입니다.';
          break;
        case 'invalid-email':
          errorMessage = '유효하지 않은 이메일 형식입니다.';
          break;
        case 'operation-not-allowed':
          errorMessage = '이메일/비밀번호 로그인이 비활성화되어 있습니다.';
          break;
        case 'weak-password':
          errorMessage = '비밀번호가 너무 약합니다.';
          break;
        default:
          errorMessage = '회원가입 중 오류가 발생했습니다.';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        joinSuccess: false,
      );
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        error: '회원가입 중 오류가 발생했습니다',
        joinSuccess: false,
      );
    }
  }

  void resetState() {
    if (mounted) {
      state = const JoinState();
    }
  }
}

final fileRepositoryProvider = Provider((ref) => FileRepository());

final joinViewModelProvider =
    StateNotifierProvider.autoDispose<JoinViewModel, JoinState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final fileRepository = ref.watch(fileRepositoryProvider);
  return JoinViewModel(
    userRepository: userRepository,
    fileRepository: fileRepository,
  );
});
