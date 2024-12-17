// post_detail_bottom_sheet.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/chat_global_view_model.dart';
import 'package:flutter_market_app/ui/pages/chat_detail/chat_detail_page.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_market_app/ui/pages/post_detail/post_detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PostDetailBottomSheet extends StatelessWidget {
  PostDetailBottomSheet(this.bottomPadding, this.postId);

  final double bottomPadding;
  final String postId;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Consumer(builder: (context, ref, child) {
      final post = ref.watch(postDetailViewModel(postId));
      final vm = ref.read(postDetailViewModel(postId).notifier);
      if (post == null) {
        return SizedBox();
      }
      return Container(
        height: 50 + bottomPadding,
        color:
            isDarkTheme ? Colors.grey[900] : Color.fromARGB(255, 254, 248, 245),
        child: Column(
          children: [
            Divider(
                height: 0,
                color: isDarkTheme ? Colors.grey[900] : Colors.grey[900]),
            Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await vm.like();
                      if (result) {
                        ref.read(homeTabViewModel.notifier).fetchPosts();
                      }
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.transparent,
                      child: Icon(
                        post.likes > 0
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 20,
                    indent: 10,
                    endIndent: 10,
                    color: isDarkTheme ? Colors.white : Colors.grey,
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat('#,###${post.price.currency}')
                          .format(post.price.amount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        final chatVm = ref.read(chatGlobalViewModel.notifier);
                        var roomId = chatVm.findChatRoomByPostId(postId);

                        if (roomId == null) {
                          final result = await chatVm.createChat(
                            postId,
                            post.userId, // 판매자 ID 추가
                            post.userNickname,
                          );
                          if (result != null) {
                            roomId = result;
                          }
                        }

                        if (roomId == null) return;

                        chatVm.fetchChatDetail(roomId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailPage(),
                          ),
                        );
                      },
                      child: Text(
                        '채팅하기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
            SizedBox(height: bottomPadding),
          ],
        ),
      );
    });
  }
}
