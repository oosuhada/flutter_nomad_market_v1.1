import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/date_time_utils.dart';
import 'package:flutter_market_app/ui/chat_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatDetailProductArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black, // 컬러 필수!
        ),
        child: Consumer(builder: (context, ref, child) {
          final state = ref.watch(chatGlobalViewModel);
          if (state.chatRoom == null) {
            return SizedBox();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.chatRoom!.product.title),
              SizedBox(height: 2),
              Text(DateTimeUtils.formatString(state.chatRoom!.createdAt)),
            ],
          );
        }),
      ),
    );
  }
}
