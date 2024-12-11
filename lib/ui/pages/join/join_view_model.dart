// 1. 상태만들기 FileModel 클래스를 상태클래스로 사용

// 2. 뷰모델만들기
import 'dart:typed_data';

import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/repository/file_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JoinViewModel extends AutoDisposeNotifier<FileModel?> {
  @override
  FileModel? build() {
    return null;
  }

  final fileRepository = FileRepository();
  final userRepository = UserRepository();

  // 사진업로드
  void uploadImage({
    required String filename,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final fileModel = await fileRepository.upload(
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
    state = fileModel;
  }

  // 회원가입
  Future<bool> join({
    required String username,
    required String password,
    required String nickname,
    required String addressFullName,
  }) async {
    // 파일이 업로드 되어있지 않으면 리턴 false
    if (state == null) {
      return false;
    }

    return await userRepository.join(
      username: username,
      nickname: nickname,
      password: password,
      addressFullName: addressFullName,
      profileImageId: state!.id,
    );
  }

  Future<String?> validateName({
    required String username,
    required String nickname,
  }) async {
    final idResult = await userRepository.usernameCk(username);
    if (!idResult) {
      return "사용할 수 없는 아이디 입니다";
    }
    final nickResult = await userRepository.nicknameCk(nickname);
    if (!nickResult) {
      return "사용할 수 없는 닉네임입니다";
    }

    return null;
  }
}

// 3. 뷰모델 관리자 만들기
final joinViewModel =
    NotifierProvider.autoDispose<JoinViewModel, FileModel?>(() {
  return JoinViewModel();
});
