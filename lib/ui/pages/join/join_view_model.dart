// 1. 상태만들기 FileModel 클래스를 상태클래스로 사용

// 2. 뷰모델만들기
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/repository/file_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_market_app/ui/pages/join/join_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class JoinViewModel extends AutoDisposeNotifier<FileModel?> {
  @override
  FileModel? build() {
    return null;
  }

  final fileRepository = FileRepository();
  final userRepository = UserRepository();

  Future<void> uploadImage(XFile xFile) async {
    try {
      // FirebaseStorage 객체 가지고오기
      FirebaseStorage storage = FirebaseStorage.instance;
      // 스토리지 참조 가지고 오기
      Reference storageRef = storage.ref();
      // 스토리지 참조의 child 메서드를 사용하면 파일 참조 만들어짐
      // 파라미터는 파일 이름!!
      // 중복되면 안되니까 현재시간이랑 기존 파일이름 섞을게요!
      final imageRef = storageRef
          .child('${DateTime.now().microsecondsSinceEpoch}_${xFile.name}');
      // 참조가 만들어졌으니 파일 업로드!!
      await imageRef.putFile(File(xFile.path));
      print('파일 업로드됨');
      // 만들어진 파일의 url 가져오기
      final url = await imageRef.getDownloadURL();
      print(url);
    } catch (e) {
      print(e);
    }
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
      return "사용할 수 없는 이메일입니다";
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
