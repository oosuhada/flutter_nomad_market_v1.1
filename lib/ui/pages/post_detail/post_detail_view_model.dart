import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/data/repository/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Post Detail View Model
class PostDetailViewModel extends AutoDisposeFamilyNotifier<Post?, String> {
  @override
  Post? build(String arg) {
    fetchDetail();
    return null;
  }

  final postRepository = PostRepository();

  Future<void> fetchDetail() async {
    state = await postRepository.getPost(arg);
  }

  Future<bool> like() async {
    final newLike = await postRepository.like(arg);
    state = state?.copyWith(
      likes: state!.likes + 1,
    );
    return newLike;
  }

  Future<bool> delete() async {
    return await postRepository.delete(arg);
  }

  Future<void> incrementViews() async {
    await postRepository.incrementViews(arg);
    if (state != null) {
      state = state!.copyWith(
        views: state!.views + 1,
      );
    }
  }
}

final postDetailViewModel =
    NotifierProvider.autoDispose.family<PostDetailViewModel, Post?, String>(() {
  return PostDetailViewModel();
});
