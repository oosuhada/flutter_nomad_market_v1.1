// chat_tab_app_bar.dart
import 'package:flutter/material.dart';

class ChatTabAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      title: Center(
        child: Text('채팅'),
      ),
    );
  }
}
