import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_market_app/ui/pages/post_detail/post_detail_view_model.dart';
import 'package:flutter_market_app/ui/pages/post_write/post_write_page.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailActions extends ConsumerWidget {
  final String postId;

  const PostDetailActions(this.postId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postDetailViewModel(postId));
    final userState = ref.watch(userGlobalViewModel);
    final user = userState.user;

    // 자신의 글이 아니면 액션 버튼 숨김
    if (user == null || postState?.userId != user.userId) {
      return const SizedBox();
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            final vm = ref.read(postDetailViewModel(postId).notifier);
            final result = await vm.delete();
            if (result) {
              ref.read(homeTabViewModel.notifier).fetchPosts();
              Navigator.pop(context);
            }
          },
          child: Container(
            width: 50,
            height: 50,
            color: Colors.transparent,
            child: Icon(Icons.delete),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return PostWritePage(isRequesting: postState != null);
                },
              ),
            );
          },
          child: Container(
            width: 50,
            height: 50,
            color: Colors.transparent,
            child: Icon(Icons.edit),
          ),
        ),
      ],
    );
  }
}
