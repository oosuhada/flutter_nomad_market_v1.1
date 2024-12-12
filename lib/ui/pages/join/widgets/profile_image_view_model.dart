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

  // 사진업로드
  Future<bool> uploadImage({
    required String title,
    required String content,
    required String writer,
    required String imageUrl,
  }) async {
    final postModel = await postRepository.insert(
      title: title,
      content: content,
      writer: writer,
      imageUrl: imageUrl,
    );
    return postModel;
  }
}

// 3. 뷰모델 관리자 만들기
final profileImageViewModel =
    NotifierProvider.autoDispose<ProfileImageViewModel, Post?>(() {
  return ProfileImageViewModel();
});
