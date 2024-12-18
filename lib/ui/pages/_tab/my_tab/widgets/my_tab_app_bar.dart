// my_tab_app_bar.dart
import 'package:flutter/material.dart';

class MyTabAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      title: Text('마이페이지'),
      centerTitle: true,
    );
  }
}
