import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/date_time_utils.dart';
import 'package:flutter_market_app/data/model/chat_room.dart';
import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/ui/chat_global_view_model.dart';
import 'package:flutter_market_app/ui/pages/chat_detail/chat_detail_page.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_market_app/ui/widgets/user_profile_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatTabListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final chatState = ref.watch(chatGlobalViewModel);
      final chatRooms = chatState.chatRooms;
      final user = ref.watch(userGlobalViewModel);

      if (user == null) {
        return SizedBox();
      }

      return Expanded(
          child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = chatRooms[index];
          return item(chatRoom, user);
        },
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
      ));
    });
  }

  Widget item(ChatRoom room, User user) {
    final displayUser =
        user.id == room.product.user.id ? room.sender : room.product.user;
    final displayDateTime = room.messages.isEmpty
        ? ''
        : DateTimeUtils.formatString(room.messages.last.createdAt);
    final message = room.messages.isEmpty ? '' : room.messages.last.content;

    return Consumer(builder: (context, ref, child) {
      return GestureDetector(
        onTap: () {
          ref.read(chatGlobalViewModel.notifier).fetchChatDetail(room.roomId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ChatDetailPage();
              },
            ),
          );
        },
        child: Container(
          height: 80,
          color: Colors.transparent,
          child: Row(
            children: [
              UserProfileImage(
                dimension: 50,
                imgUrl: displayUser.profileImage.url,
              ),
              SizedBox(width: 16),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${displayUser.nickname}님',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        displayDateTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(message),
                ],
              )),
            ],
          ),
        ),
      );
    });
  }
}
