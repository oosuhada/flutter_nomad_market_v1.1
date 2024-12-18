import 'package:flutter/material.dart';

class ChatTabAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Center(
        child: Text('채팅'),
      ),
    );
  }
}
