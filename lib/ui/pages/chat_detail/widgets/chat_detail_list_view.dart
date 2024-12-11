import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/chat_global_view_model.dart';
import 'package:flutter_market_app/ui/pages/chat_detail/widgets/chat_detail_receive_item.dart';
import 'package:flutter_market_app/ui/pages/chat_detail/widgets/chat_detail_send_item.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatDetailListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final chatRoom = ref.watch(chatGlobalViewModel).chatRoom;
      if (chatRoom == null) {
        return SizedBox();
      }

      final messages = chatRoom.messages;
      final user = ref.watch(userGlobalViewModel)!;

      return Expanded(
        child: ListView.separated(
          itemCount: messages.length,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          separatorBuilder: (context, index) => SizedBox(height: 4),
          itemBuilder: (context, index) {
            final message = messages[index];
            final msgSender = message.messageType == 'SENDER_TO_PRODUCT_OWNER'
                ? chatRoom.sender
                : chatRoom.product.user;

            // 내가보낸메시지 => ChatDetailSendItem
            if (user.id == msgSender.id) {
              return ChatDetailSendItem(
                content: message.content,
                dateTime: message.createdAt,
              );
            }

            // 내가 보낸 메시지가 아닐경우 => ChatDetailReceiveItem;
            bool showProfile = true;
            if (index > 0) {
              final previousMsg = messages[index - 1];
              showProfile = previousMsg.messageType != message.messageType;
            }
            // index => 0 => 이전메시지가 없음=>true
            // 이전메시지의 messageType 이 같으면 false 틀리면 true

            return ChatDetailReceiveItem(
              imgUrl: msgSender.profileImage.url,
              showProfile: showProfile,
              content: message.content,
              dateTime: message.createdAt,
            );
          },
        ),
      );
    });
  }
}
