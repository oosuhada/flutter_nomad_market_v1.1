import 'package:flutter/material.dart';

class MyTabAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text('마이페이지'),
      centerTitle: true,
    );
  }
}
