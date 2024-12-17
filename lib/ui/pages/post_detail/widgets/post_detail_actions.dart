import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_market_app/ui/pages/post_detail/post_detail_view_model.dart';
import 'package:flutter_market_app/ui/pages/post_write/post_write_page.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailActions extends StatelessWidget {
  PostDetailActions(this.postId);
  final String postId;

  @override
  Widget build(BuildContext context) {
    // TODO 자신의 글이 아니면 보여주지 않기!
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(postDetailViewModel(postId));
      final vm = ref.read(postDetailViewModel(postId).notifier);
      final user = ref.read(userGlobalViewModel);
      if (state?.userId != user?.userId) {
        return SizedBox();
      }
      return Row(
        children: [
          GestureDetector(
            onTap: () async {
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
                    return PostWritePage(isRequesting: state != null);
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
    });
  }
}
