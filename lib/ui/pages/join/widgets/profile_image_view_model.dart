// 1. 상태만들기 FileModel 클래스를 상태클래스로 사용

// 2. 뷰모델만들기

import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/data/repository/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileImageViewModel extends AutoDisposeNotifier<Post?> {
  @override
  Post? build() {
    return null;
  }

  final postRepository = const PostRepository();

  Future<Post?> uploadImage({
    required String title,
    required String content,
    required String writer,
    required String imageUrl,
  }) async {
    try {
      // 데이터 삽입 및 ID 반환
      final id = await postRepository.insert(
        title: title,
        content: content,
        writer: writer,
        imageUrl: imageUrl,
      );
      if (id == null) {
        throw Exception("문서 생성 실패");
      }

      // ID를 기반으로 데이터 가져오기
      final post = await postRepository.getOne(id);
      state = post;
      return post;
    } catch (e) {
      print("업로드 실패: $e");
      return null;
    }
  }
}

// 3. 뷰모델 관리자 만들기
final profileImageViewModel =
    NotifierProvider.autoDispose<ProfileImageViewModel, Post?>(() {
  return ProfileImageViewModel();
});
