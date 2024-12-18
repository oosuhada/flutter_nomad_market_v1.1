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
    final userData = await userRepository.getCurrentUserInfo();
    state = userData;
  }

  Future<void> uploadImage({
    required String filename,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final fileModel = await fileRepository.uploadProfileImage(
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
    if (state != null && fileModel != null) {
      state = state!.copyWith(profileImageUrl: fileModel.url);
    }
  }

  Future<bool> updateProfile({
    required String nickname,
    required String profileImageUrl,
  }) async {
    if (state == null) return false;

    final result = await userRepository.updateProfile(
      userId: state!.userId, // Ensure this is a string
      nickname: nickname,
      profileImageUrl: state!.profileImageUrl,
    );
    print('이미지 링크는 $profileImageUrl');
    print('result: $result');

    if (result) {
      await initUserData(); // 업데이트 성공 시 사용자 정보 갱신
      print('프로필 업데이트 성공');
    }

    return result;
  }
}

final profileEditViewModel =
    StateNotifierProvider<ProfileEditViewModel, User?>((ref) {
  return ProfileEditViewModel();
});
