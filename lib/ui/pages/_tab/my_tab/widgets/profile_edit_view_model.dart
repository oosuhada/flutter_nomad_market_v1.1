import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/data/repository/file_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';

class ProfileEditViewModel extends StateNotifier<User?> {
  ProfileEditViewModel() : super(null);

  final fileRepository = FileRepository();
  final userRepository = UserRepository();

  Future<void> initUserData() async {
    print("사용자 데이터 초기화 시작");
    final userData = await userRepository.getCurrentUserInfo();
    if (userData != null) {
      print("현재 프로필 이미지 URL: ${userData.profileImageUrl}");
      state = userData;
    }
  }

//이미지만 즉시 업데이트할 때 사용하는 메서드
  Future<bool> uploadAndUpdateImage({
    required String filename,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    print("이미지 업로드 및 업데이트 시작");
    try {
      final fileModel = await fileRepository.upload(
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
      );

      if (fileModel != null && state != null) {
        // 이미지 업로드 성공 시 바로 프로필 업데이트
        final result = await userRepository.updateProfile(
          userId: state!.userId,
          nickname: state!.nickname,
          profileImageUrl: fileModel.url,
        );

        if (result) {
          await initUserData(); // 사용자 정보 갱신
          return true;
        }
      }
    } catch (e) {
      print("이미지 업로드 실패: $e");
    }
    return false;
  }

//프로필 전체(닉네임과 이미지)를 업데이트할 때 사용하
  Future<bool> updateProfile({
    required String nickname,
    File? imageFile,
  }) async {
    if (state == null) return false;

    try {
      String profileImageUrl = state!.profileImageUrl;
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        final fileName = imageFile.path.split('/').last;
        final fileModel = await fileRepository.upload(
          bytes: bytes,
          filename: fileName,
          mimeType: 'image/jpeg',
        );
        if (fileModel != null) {
          profileImageUrl = fileModel.url;
        }
      }

      final result = await userRepository.updateProfile(
        userId: state!.userId,
        nickname: nickname,
        profileImageUrl: profileImageUrl,
      );

      if (result) {
        await initUserData();
      }
      return result;
    } catch (e) {
      print("프로필 업데이트 실패: $e");
      return false;
    }
  }
}

final profileEditViewModel =
    StateNotifierProvider<ProfileEditViewModel, User?>((ref) {
  return ProfileEditViewModel();
});
